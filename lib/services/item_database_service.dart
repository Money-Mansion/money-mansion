import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/item.dart';
import '../config/items_config.dart';

class ItemDatabaseService {
  static const String _ownedItemsTable = 'owned_items';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 5;

  static List<String> _zniceneItemIdsFromConfig(List<Item> configItems) {
    final ids = <String>[];
    for (final item in configItems) {
      final id = item.id.toLowerCase();
      if (id.contains('zniceny') || id.contains('znicena')) {
        ids.add(item.id);
      }
    }
    ids.sort();
    return ids;
  }

  static const List<String> _starterDecorItemIds = [
    'hoblub',
    'morca',
  ];

  static Database? _database;
  static bool _initialized = false;

  static Future<void> initializeDatabase() async {
    if (_initialized) {
      print('ItemDatabaseService already initialized');
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print('FFI initialized for desktop');
    } else {
      print('INFO: Mobile platform - FFI not needed');
    }
    _initialized = true;
    print('ItemDatabaseService initialized');
  }

  static Future<Database> get database async {
    await initializeDatabase();
    if (_database != null) {
      print('INFO: Reusing existing database connection');
      return _database!;
    }
    print('Opening database...');
    _database = await _initDatabase();
    print('Database opened successfully');
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    print('INFO: Database path: $path');
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTable,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $_ownedItemsTable (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                name_en TEXT NOT NULL DEFAULT '',
                type TEXT NOT NULL,
                texture TEXT NOT NULL,
                cost INTEGER NOT NULL,
                quantity INTEGER NOT NULL DEFAULT 1
              )
            ''');
            try {
              await db.execute('''
                INSERT OR IGNORE INTO $_ownedItemsTable (id, name, name_en, type, texture, cost, quantity)
                SELECT id, name, name, type, texture, cost, 1 FROM items WHERE owned = 1
              ''');
            } catch (e) {}
            try {
              await db.execute('DROP TABLE IF EXISTS items');
            } catch (e) {}
          } catch (e) {
            print('Migration error: $e');
          }
        }

        if (oldVersion < 4) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS owned_room_components (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                texture TEXT NOT NULL,
                cost INTEGER NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS room_selected_components (
                role TEXT PRIMARY KEY,
                selected_component_id TEXT NOT NULL,
                FOREIGN KEY(selected_component_id) REFERENCES owned_room_components(id)
              )
            ''');
            await db.insert(
              'room_selected_components',
              {'role': 'wall', 'selected_component_id': 'none'},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
            await db.insert(
              'room_selected_components',
              {'role': 'floor', 'selected_component_id': 'none'},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
            print('Room component tables created during migration');
          } catch (e) {
            print('Room component migration error: $e');
          }
        }

        // v5: add name_en column to owned_items
        if (oldVersion < 5) {
          try {
            final columns = await db.rawQuery('PRAGMA table_info($_ownedItemsTable)');
            final hasNameEn = columns.any((c) => c['name'] == 'name_en');
            if (!hasNameEn) {
              await db.execute(
                'ALTER TABLE $_ownedItemsTable ADD COLUMN name_en TEXT NOT NULL DEFAULT ""',
              );
              print('Added name_en column to owned_items');
            }
            // Backfill name_en from config for existing rows
            final configMap = {for (var item in GAME_ITEMS) item.id: item};
            final rows = await db.query(_ownedItemsTable, columns: ['id']);
            for (final row in rows) {
              final id = row['id'] as String;
              final configItem = configMap[id];
              if (configItem != null) {
                await db.update(
                  _ownedItemsTable,
                  {'name_en': configItem.nameEn},
                  where: 'id = ?',
                  whereArgs: [id],
                );
              }
            }
            print('Backfilled name_en for existing owned items');
          } catch (e) {
            print('v5 migration error: $e');
          }
        }

        await _createGoalsTable(db);
      },
      onOpen: (db) async {
        print('Database onOpen callback triggered');
        try {
          await _createTables(db);
          print('onOpen: Tables verified');
        } catch (e) {
          print('ERROR in onOpen callback: $e');
          rethrow;
        }
      },
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    print('Database onCreate triggered (v$version)');
    try {
      await _createTables(db);
      print('onCreate: Tables created successfully');
    } catch (e) {
      print('ERROR in onCreate: $e');
      rethrow;
    }
  }

  static Future<void> ensureTablesExist(Database db) async {
    try {
      print('Ensuring tables exist...');
      await _createTables(db);
      print('Tables verified');
    } catch (e) {
      print('ERROR ensuring tables: $e');
      rethrow;
    }
  }

  static Future<void> _createTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_ownedItemsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          name_en TEXT NOT NULL DEFAULT '',
          type TEXT NOT NULL,
          texture TEXT NOT NULL,
          cost INTEGER NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await _ensureOwnedItemsColumns(db);
      print('Created/verified owned_items table');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS owned_room_components (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          texture TEXT NOT NULL,
          cost INTEGER NOT NULL
        )
      ''');
      print('Created/verified owned_room_components table');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS room_selected_components (
          role TEXT PRIMARY KEY,
          selected_component_id TEXT NOT NULL
        )
      ''');
      print('Created/verified room_selected_components table');

      try {
        await db.insert(
          'room_selected_components',
          {'role': 'wall', 'selected_component_id': 'none'},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {}

      try {
        await db.insert(
          'room_selected_components',
          {'role': 'floor', 'selected_component_id': 'none'},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {}

      await _createGoalsTable(db);
      print('Created/verified goals table');
    } catch (e) {
      print('ERROR in _createTables: $e');
      rethrow;
    }
  }

  static Future<void> _ensureOwnedItemsColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info($_ownedItemsTable)');
    final names = columns.map((c) => c['name'] as String).toSet();

    if (!names.contains('quantity')) {
      await db.execute(
        'ALTER TABLE $_ownedItemsTable ADD COLUMN quantity INTEGER NOT NULL DEFAULT 1',
      );
      print('Added quantity column to owned_items table');
    }
    if (!names.contains('name_en')) {
      await db.execute(
        'ALTER TABLE $_ownedItemsTable ADD COLUMN name_en TEXT NOT NULL DEFAULT ""',
      );
      print('Added name_en column to owned_items table');
      // Backfill from config
      final configMap = {for (var item in GAME_ITEMS) item.id: item};
      final rows = await db.query(_ownedItemsTable, columns: ['id']);
      for (final row in rows) {
        final id = row['id'] as String;
        final configItem = configMap[id];
        if (configItem != null) {
          await db.update(
            _ownedItemsTable,
            {'name_en': configItem.nameEn},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
      print('Backfilled name_en for existing rows');
    }
  }

  static Future<void> _createGoalsTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS goals (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          challengeScore INTEGER NOT NULL DEFAULT 50,
          rewardCoins INTEGER NOT NULL,
          targetMoney REAL NOT NULL DEFAULT 0,
          allocatedMoney REAL NOT NULL DEFAULT 0,
          milestonesAwarded INTEGER NOT NULL DEFAULT 0,
          dueDate INTEGER NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      final columns = await db.rawQuery('PRAGMA table_info(goals)');
      final columnNames = columns.map((c) => c['name'] as String).toSet();

      if (!columnNames.contains('targetMoney')) {
        await db.execute('ALTER TABLE goals ADD COLUMN targetMoney REAL NOT NULL DEFAULT 0');
      }
      if (!columnNames.contains('allocatedMoney')) {
        await db.execute('ALTER TABLE goals ADD COLUMN allocatedMoney REAL NOT NULL DEFAULT 0');
      }
      if (!columnNames.contains('challengeScore')) {
        await db.execute('ALTER TABLE goals ADD COLUMN challengeScore INTEGER NOT NULL DEFAULT 50');
      }
      if (!columnNames.contains('milestonesAwarded')) {
        await db.execute('ALTER TABLE goals ADD COLUMN milestonesAwarded INTEGER NOT NULL DEFAULT 0');
      }
    } catch (e) {
      print('ERROR in _createGoalsTable: $e');
      rethrow;
    }
  }

  static Future<List<Item>> getOwnedItems() async {
    try {
      final db = await database;
      await ensureTablesExist(db);
      final maps = await db.query(_ownedItemsTable);

      final configMap = {for (var item in GAME_ITEMS) item.id: item};

      return List.generate(maps.length, (i) {
        final map = maps[i];
        final id = map['id'] as String;
        final configItem = configMap[id];

        final quantityValue = map['quantity'];
        final quantity = quantityValue is int
            ? quantityValue
            : (quantityValue as num?)?.toInt() ?? 1;

        final nameEn = (map['name_en'] as String?)?.isNotEmpty == true
            ? map['name_en'] as String
            : configItem?.nameEn ?? map['name'] as String;

        return Item(
          id: id,
          name: map['name'] as String,
          nameEn: nameEn,
          type: _stringToItemType(map['type'] as String),
          texture: map['texture'] as String,
          cost: map['cost'] as int,
          quantity: quantity,
          hitboxId: configItem?.hitboxId,
          scale: configItem?.scale ?? 1.0,
        );
      });
    } catch (e) {
      print('Error loading owned items: $e');
      return [];
    }
  }

  static Future<bool> isItemOwned(String itemId) async {
    try {
      final db = await database;
      await ensureTablesExist(db);
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

  static Future<bool> addOwnedItem(Item item) async {
    try {
      final db = await database;
      await ensureTablesExist(db);
      final existing = await db.query(
        _ownedItemsTable,
        columns: ['quantity'],
        where: 'id = ?',
        whereArgs: [item.id],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final currentQuantity = (existing.first['quantity'] as num?)?.toInt() ?? 1;
        await db.update(
          _ownedItemsTable,
          {'quantity': currentQuantity + 1},
          where: 'id = ?',
          whereArgs: [item.id],
        );
      } else {
        await db.insert(
          _ownedItemsTable,
          {
            'id': item.id,
            'name': item.name,
            'name_en': item.nameEn,
            'type': _itemTypeToString(item.type),
            'texture': item.texture,
            'cost': item.cost,
            'quantity': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      return true;
    } catch (e) {
      print('Error adding owned item: $e');
      return false;
    }
  }

  static Future<bool> removeOwnedItem(String itemId) async {
    try {
      final db = await database;
      await ensureTablesExist(db);
      await db.delete(_ownedItemsTable, where: 'id = ?', whereArgs: [itemId]);
      return true;
    } catch (e) {
      print('Error removing owned item: $e');
      return false;
    }
  }

  static Future<bool> clearAllOwnedItems() async {
    try {
      final db = await database;
      await ensureTablesExist(db);
      await db.delete(_ownedItemsTable);
      print('Cleared all owned items from database');
      return true;
    } catch (e) {
      print('Error clearing owned items: $e');
      return false;
    }
  }

  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  static Future<int> syncOwnedItemsWithConfig(List<Item> configItems) async {
    try {
      final db = await database;
      await ensureTablesExist(db);

      final configMap = {for (var item in configItems) item.id: item};
      final ownedItems = await getOwnedItems();
      int syncedCount = 0;

      for (final ownedItem in ownedItems) {
        if (configMap.containsKey(ownedItem.id)) {
          final configItem = configMap[ownedItem.id]!;
          await db.update(
            _ownedItemsTable,
            {
              'name': configItem.name,
              'name_en': configItem.nameEn,
              'type': _itemTypeToString(configItem.type),
              'texture': configItem.texture,
              'cost': configItem.cost,
            },
            where: 'id = ?',
            whereArgs: [ownedItem.id],
          );
          syncedCount++;
          print('Synced owned item: ${ownedItem.id}');
        }
      }

      if (syncedCount > 0) print('Synced $syncedCount owned items with config');
      return syncedCount;
    } catch (e) {
      print('Error syncing owned items: $e');
      return 0;
    }
  }

  static Future<void> ensureStarterBrokenItemsOwned(List<Item> configItems) async {
    try {
      final db = await database;
      await ensureTablesExist(db);

      final toOwn = _zniceneItemIdsFromConfig(configItems);
      if (toOwn.isEmpty) return;

      final existingIds = (await getOwnedItems()).map((i) => i.id).toSet();
      for (final id in toOwn) {
        if (existingIds.contains(id)) continue;
        Item? configItem;
        try {
          configItem = configItems.firstWhere((item) => item.id == id);
        } catch (_) {
          continue;
        }
        await db.insert(
          _ownedItemsTable,
          {
            'id': configItem.id,
            'name': configItem.name,
            'name_en': configItem.nameEn,
            'type': _itemTypeToString(configItem.type),
            'texture': configItem.texture,
            'cost': configItem.cost,
            'quantity': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Starter znicene item granted: $id');
      }
    } catch (e) {
      print('Error ensuring starter broken items: $e');
    }
  }

  static Future<void> ensureStarterDecorItemsOwned(List<Item> configItems) async {
    try {
      final db = await database;
      await ensureTablesExist(db);

      final existingIds = (await getOwnedItems()).map((i) => i.id).toSet();
      for (final id in _starterDecorItemIds) {
        if (existingIds.contains(id)) continue;
        Item? configItem;
        try {
          configItem = configItems.firstWhere((item) => item.id == id);
        } catch (_) {
          continue;
        }
        await db.insert(
          _ownedItemsTable,
          {
            'id': configItem.id,
            'name': configItem.name,
            'name_en': configItem.nameEn,
            'type': _itemTypeToString(configItem.type),
            'texture': configItem.texture,
            'cost': configItem.cost,
            'quantity': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print('Error ensuring starter decor items: $e');
    }
  }

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