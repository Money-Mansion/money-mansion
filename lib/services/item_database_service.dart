import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/item.dart';

class ItemDatabaseService {
  static const String _ownedItemsTable = 'owned_items';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 3;

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
        // Migrate from v2 to v3: rename old items table to owned_items and remove owned column
        if (oldVersion < 3) {
          try {
            // Check if old 'items' table exists and migrate it
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $_ownedItemsTable (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                texture TEXT NOT NULL,
                cost INTEGER NOT NULL
              )
            ''');
            
            // Try to migrate data from old items table if it has owned=1
            try {
              await db.execute('''
                INSERT OR IGNORE INTO $_ownedItemsTable (id, name, type, texture, cost)
                SELECT id, name, type, texture, cost FROM items WHERE owned = 1
              ''');
            } catch (e) {
              // Old table might not exist, ignore
            }
            
            // Drop old items table
            try {
              await db.execute('DROP TABLE IF EXISTS items');
            } catch (e) {
              // Ignore if table doesn't exist
            }
          } catch (e) {
            print('Migration error: $e');
          }
        }
        
        // Ensure goals table exists
        await _createGoalsTable(db);
      },
      onOpen: (db) async {
        // Ensure tables exist on every app start
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await _createTables(db);
  }

  static Future<void> _createTables(Database db) async {
    // Create owned_items table (v3 schema - only stores owned items)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_ownedItemsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        texture TEXT NOT NULL,
        cost INTEGER NOT NULL
      )
    ''');
    
    await _createGoalsTable(db);
  }

  static Future<void> _createGoalsTable(Database db) async {
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

    // Ensure new columns exist
    final columns = await db.rawQuery('PRAGMA table_info(goals)');
    final columnNames = columns.map((c) => c['name'] as String).toSet();

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

  // Get all owned items from database
  static Future<List<Item>> getOwnedItems() async {
    try {
      final db = await database;
      final maps = await db.query(_ownedItemsTable);

      return List.generate(maps.length, (i) {
        return Item(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          type: _stringToItemType(maps[i]['type'] as String),
          texture: maps[i]['texture'] as String,
          cost: maps[i]['cost'] as int,
        );
      });
    } catch (e) {
      print('Error loading owned items: $e');
      return [];
    }
  }

  // Check if item is owned
  static Future<bool> isItemOwned(String itemId) async {
    try {
      final db = await database;
      final result = await db.query(
        _ownedItemsTable,
        where: 'id = ?',
        whereArgs: [itemId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking item ownership: $e');
      return false;
    }
  }

  // Add item to owned items
  static Future<bool> addOwnedItem(Item item) async {
    try {
      final db = await database;
      await db.insert(
        _ownedItemsTable,
        {
          'id': item.id,
          'name': item.name,
          'type': _itemTypeToString(item.type),
          'texture': item.texture,
          'cost': item.cost,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding owned item: $e');
      return false;
    }
  }

  // Remove item from owned items
  static Future<bool> removeOwnedItem(String itemId) async {
    try {
      final db = await database;
      await db.delete(
        _ownedItemsTable,
        where: 'id = ?',
        whereArgs: [itemId],
      );
      return true;
    } catch (e) {
      print('Error removing owned item: $e');
      return false;
    }
  }

  // DEBUG: Clear all owned items (for testing)
  static Future<bool> clearAllOwnedItems() async {
    try {
      final db = await database;
      await db.delete(_ownedItemsTable);
      print('Cleared all owned items from database');
      return true;
    } catch (e) {
      print('Error clearing owned items: $e');
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
