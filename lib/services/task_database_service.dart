import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/task.dart';

class TaskDatabaseService {
  static const String _tableName = 'tasks';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 1;

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
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        rewardCoins INTEGER NOT NULL,
        dueDate INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Get all tasks
  static Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName);

      return List.generate(maps.length, (i) {
        return Task(
          id: maps[i]['id'] as String,
          title: maps[i]['title'] as String,
          description: maps[i]['description'] as String,
          rewardCoins: maps[i]['rewardCoins'] as int,
          dueDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['dueDate'] as int),
          isCompleted: (maps[i]['isCompleted'] as int) == 1,
        );
      });
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  // Create new task
  static Future<bool> createTask(Task task) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'rewardCoins': task.rewardCoins,
          'dueDate': task.dueDate.millisecondsSinceEpoch,
          'isCompleted': task.isCompleted ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  // Update task
  static Future<bool> updateTask(Task task) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'rewardCoins': task.rewardCoins,
          'dueDate': task.dueDate.millisecondsSinceEpoch,
          'isCompleted': task.isCompleted ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );
      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Complete task
  static Future<bool> completeTask(String taskId) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [taskId],
      );
      return true;
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }

  // Delete task
  static Future<bool> deleteTask(String taskId) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [taskId],
      );
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Close database
  static Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }
}
