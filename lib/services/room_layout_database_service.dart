import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

import '../models/room_item_placement.dart';

class RoomLayoutDatabaseService {
  static const String defaultRoomId = 'default_room';

  static const String _tableName = 'room_layout';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 4;

  static Database? _database;
  static bool _initialized = false;

  static Future<void> _initializeDatabase() async {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static Future<Database> get _databaseInstance async {
    await _initializeDatabase();
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTable(db);
      },
      onOpen: (db) async {
        await _createTable(db);
      },
    );
  }

  static Future<void> _createTable(Database db) async {
    // First, check if the table exists and has the isFlipped column
    try {
      final result = await db.rawQuery(
        "PRAGMA table_info($_tableName)",
      );
      final hasIsFlippedColumn = result.any((col) => col['name'] == 'isFlipped');
      
      if (!hasIsFlippedColumn) {
        // Add isFlipped column if it doesn't exist
        await db.execute(
          'ALTER TABLE $_tableName ADD COLUMN isFlipped INTEGER DEFAULT 0',
        );
        print('✓ Added isFlipped column to room_layout table');
      }
    } catch (e) {
      // Table might not exist yet, which is fine
    }
    
    // Create table with new schema
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        isFlipped INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<List<RoomItemPlacement>> getRoomLayout(String roomId) async {
    final db = await _databaseInstance;
    await _createTable(db);

    final maps = await db.query(
      _tableName,
      where: 'roomId = ?',
      whereArgs: [roomId],
    );

    return maps
        .map(
          (m) => RoomItemPlacement(
            roomId: m['roomId'] as String,
            itemId: m['itemId'] as String,
            x: (m['x'] as num).toDouble(),
            y: (m['y'] as num).toDouble(),
            isFlipped: (m['isFlipped'] as int?) == 1,
          ),
        )
        .toList();
  }

  static Future<void> saveRoomLayout(
    String roomId,
    List<RoomItemPlacement> placements,
  ) async {
    final db = await _databaseInstance;
    await _createTable(db);

    final batch = db.batch();

    // Clear existing layout for this room
    batch.delete(
      _tableName,
      where: 'roomId = ?',
      whereArgs: [roomId],
    );

    // Insert new layout
    for (final p in placements) {
      batch.insert(_tableName, {
        'roomId': p.roomId,
        'itemId': p.itemId,
        'x': p.x,
        'y': p.y,
        'isFlipped': p.isFlipped ? 1 : 0,
      });
    }

    await batch.commit(noResult: true);
  }

  static Future<void> clearAllRoomLayouts() async {
    final db = await _databaseInstance;
    await db.delete(_tableName);
  }
}

