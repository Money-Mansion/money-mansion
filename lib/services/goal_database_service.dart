import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/goal.dart';

class GoalDatabaseService {
  static const String _tableName = 'goals';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 2;

  static Database? _database;
  static bool _initialized = false;

  // Initialize the database factory (required for Windows/Desktop)
  static Future<void> initializeDatabase() async {
    if (_initialized) return;
    
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  // Initialize database
  static Future<Database> get database async {
    await initializeDatabase();
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTable,
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTable(db, newVersion);
        await _ensureGoalColumns(db);
      },
      onOpen: (db) async {
        // Ensure tables exist on every app start
        await _createTable(db, _dbVersion);
        await _ensureGoalColumns(db);
      },
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    // Create goals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        rewardCoins INTEGER NOT NULL,
        targetMoney REAL NOT NULL DEFAULT 0,
        allocatedMoney REAL NOT NULL DEFAULT 0,
        dueDate INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Also create items table to ensure it exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        texture TEXT NOT NULL,
        cost INTEGER NOT NULL,
        owned INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _ensureGoalColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info($_tableName)');
    final columnNames =
        columns.map((c) => c['name'] as String).toSet();

    if (!columnNames.contains('targetMoney')) {
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN targetMoney REAL NOT NULL DEFAULT 0',
      );
    }
    if (!columnNames.contains('allocatedMoney')) {
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN allocatedMoney REAL NOT NULL DEFAULT 0',
      );
    }
  }

  // Get all goals
  static Future<List<Goal>> getAllGoals() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName);

      return List.generate(maps.length, (i) {
        return Goal(
          id: maps[i]['id'] as String,
          title: maps[i]['title'] as String,
          description: maps[i]['description'] as String,
          rewardCoins: maps[i]['rewardCoins'] as int,
          targetMoney:
              (maps[i]['targetMoney'] as num?)?.toDouble() ?? 0.0,
          allocatedMoney:
              (maps[i]['allocatedMoney'] as num?)?.toDouble() ?? 0.0,
          dueDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['dueDate'] as int),
          isCompleted: (maps[i]['isCompleted'] as int) == 1,
        );
      });
    } catch (e) {
      print('Error loading goals: $e');
      return [];
    }
  }

  // Create new goal
  static Future<bool> createGoal(Goal goal) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        {
          'id': goal.id,
          'title': goal.title,
          'description': goal.description,
          'rewardCoins': goal.rewardCoins,
          'targetMoney': goal.targetMoney,
          'allocatedMoney': goal.allocatedMoney,
          'dueDate': goal.dueDate.millisecondsSinceEpoch,
          'isCompleted': goal.isCompleted ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error creating goal: $e');
      return false;
    }
  }

  // Update goal
  static Future<bool> updateGoal(Goal goal) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {
          'id': goal.id,
          'title': goal.title,
          'description': goal.description,
          'rewardCoins': goal.rewardCoins,
          'targetMoney': goal.targetMoney,
          'allocatedMoney': goal.allocatedMoney,
          'dueDate': goal.dueDate.millisecondsSinceEpoch,
          'isCompleted': goal.isCompleted ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      return true;
    } catch (e) {
      print('Error updating goal: $e');
      return false;
    }
  }

  // Complete goal
  static Future<bool> completeGoal(String goalId) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [goalId],
      );
      return true;
    } catch (e) {
      print('Error completing goal: $e');
      return false;
    }
  }

  // Delete goal
  static Future<bool> deleteGoal(String goalId) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [goalId],
      );
      return true;
    } catch (e) {
      print('Error deleting goal: $e');
      return false;
    }
  }

  // Close database
  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  // DEBUG: Clear all goals
  static Future<void> clearAllGoals() async {
    final db = await database;
    await db.delete(_tableName);
    print('Cleared all goals from database');
  }
}
