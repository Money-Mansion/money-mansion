import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/item.dart';

class ItemDatabaseService {
  static const String _tableName = 'items';
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
    // Create items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        texture TEXT NOT NULL,
        cost INTEGER NOT NULL,
        owned INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Also create goals table to ensure it exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
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
  }

  static Future<void> _ensureGoalColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(goals)');
    final columnNames =
        columns.map((c) => c['name'] as String).toSet();

    if (!columnNames.contains('targetMoney')) {
      await db.execute(
        'ALTER TABLE goals ADD COLUMN targetMoney REAL NOT NULL DEFAULT 0',
      );
    }
    if (!columnNames.contains('allocatedMoney')) {
      await db.execute(
        'ALTER TABLE goals ADD COLUMN allocatedMoney REAL NOT NULL DEFAULT 0',
      );
    }
  }

  // Get all items
  static Future<List<Item>> getAllItems() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName);

      return List.generate(maps.length, (i) {
        return Item(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          type: _stringToItemType(maps[i]['type'] as String),
          texture: maps[i]['texture'] as String,
          cost: maps[i]['cost'] as int,
          owned: (maps[i]['owned'] as int) == 1,
        );
      });
    } catch (e) {
      print('Error loading items: $e');
      return [];
    }
  }

  // Get only owned items
  static Future<List<Item>> getOwnedItems() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'owned = ?',
        whereArgs: [1],
      );

      return List.generate(maps.length, (i) {
        return Item(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          type: _stringToItemType(maps[i]['type'] as String),
          texture: maps[i]['texture'] as String,
          cost: maps[i]['cost'] as int,
          owned: (maps[i]['owned'] as int) == 1,
        );
      });
    } catch (e) {
      print('Error loading owned items: $e');
      return [];
    }
  }

  // Create or insert item
  static Future<bool> createItem(Item item) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        {
          'id': item.id,
          'name': item.name,
          'type': _itemTypeToString(item.type),
          'texture': item.texture,
          'cost': item.cost,
          'owned': item.owned ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error creating item: $e');
      return false;
    }
  }

  // Update item ownership
  static Future<bool> updateItemOwnership(String itemId, bool owned) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {'owned': owned ? 1 : 0},
        where: 'id = ?',
        whereArgs: [itemId],
      );
      return true;
    } catch (e) {
      print('Error updating item ownership: $e');
      return false;
    }
  }

  // Delete item
  static Future<bool> deleteItem(String itemId) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [itemId],
      );
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }

  // Close database
  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  // Helper methods
  static String _itemTypeToString(ItemType type) {
    return type.toString().split('.').last;
  }

  static ItemType _stringToItemType(String typeString) {
    return ItemType.values.firstWhere(
      (type) => type.toString().split('.').last == typeString,
      orElse: () => ItemType.decoration,
    );
  }
}
