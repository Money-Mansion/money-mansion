import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

import '../models/room_item_placement.dart';

class RoomLayoutDatabaseService {
  static const String defaultRoomId = 'default_room';

  static const String _tableName = 'room_layout';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 3;

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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL
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
      });
    }

    await batch.commit(noResult: true);
  }
}

