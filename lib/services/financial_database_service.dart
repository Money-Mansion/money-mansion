import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform, File;
import '../models/transaction.dart';

class FinancialDatabaseService {
  static const _dbName = 'money_mansion.db';
  static const _transactionsTable = 'transactions';
  static const _gameStateTable = 'game_state';
  static const _dbVersion = 4;

  static Database? _database;
  static bool _initialized = false;

  // Initialize DB factory
  static Future<void> initializeDatabase() async {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }

  // Get database instance
  static Future<Database> get database async {
    await initializeDatabase();
    if (_database == null) {
      _database = await _initDatabase();
      // Ensure all tables exist after opening
      await _ensureAllTables(_database!);
    }
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Ensure all tables exist for any upgrade
        await _ensureTransactionsTable(db);
        await _ensureGameStateTable(db);
        await _ensureGoalIdColumn(db);
      },
      onOpen: (db) async {
        await _ensureTransactionsTable(db);
        await _ensureGameStateTable(db);
        await _ensureGoalIdColumn(db);
      },
    );
  }

  static Future<void> _ensureAllTables(Database db) async {
    await _ensureTransactionsTable(db);
    await _ensureGameStateTable(db);
    await _ensureGoalIdColumn(db);
  }

  static Future<void> clearAndReinitialize() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    // Delete the corrupted database file
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('Deleted corrupted database file');
    }
    
    // Reinitialize
    _database = await _initDatabase();
    await _ensureAllTables(_database!);
    print('Database reinitialized successfully');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_transactionsTable (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date INTEGER NOT NULL,
        goalId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_gameStateTable (
        key TEXT PRIMARY KEY,
        value REAL NOT NULL
      )
    ''');
  }

  static Future<void> ensureTable() async {
    final db = await database;
    await _ensureTransactionsTable(db);
  }

  static Future<void> _ensureTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_transactionsTable (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date INTEGER NOT NULL,
        goalId TEXT
      )
    ''');
  }

  static Future<void> _ensureGameStateTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_gameStateTable (
        key TEXT PRIMARY KEY,
        value REAL NOT NULL
      )
    ''');
  }

  static Future<void> _ensureGoalIdColumn(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info($_transactionsTable)');
    final columnNames = columns.map((c) => c['name'] as String).toSet();
    if (!columnNames.contains('goalId')) {
      await db.execute(
        'ALTER TABLE $_transactionsTable ADD COLUMN goalId TEXT',
      );
    }
  }

  // ===== COINS =====

  static Future<void> saveCoins(int coins) async {
    final db = await database;
    await db.insert(
      _gameStateTable,
      {'key': 'coins', 'value': coins.toDouble()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> getCoins() async {
    final db = await database;
    try {
      final result = await db.query(
        _gameStateTable,
        where: 'key = ?',
        whereArgs: ['coins'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value.toInt();
        if (value is String) {
          try {
            return int.parse(value);
          } catch (_) {
            return double.parse(value).toInt();
          }
        }
      }
      return 0;
    } catch (e) {
      print('Error loading coins: $e');
      return 0;
    }
  }

  // ===== MONEY =====

  static Future<void> saveMoney(double money) async {
    final db = await database;
    await db.insert(
      _gameStateTable,
      {'key': 'money', 'value': money},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<double> getMoney() async {
    final db = await database;
    try {
      final result = await db.query(
        _gameStateTable,
        where: 'key = ?',
        whereArgs: ['money'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value.toDouble();
        if (value is String) return double.parse(value);
      }
      return 0.0;
    } catch (e) {
      print('Error loading money: $e');
      return 0.0;
    }
  }

  // ===== MUSIC ENABLED =====

  static Future<void> saveMusicEnabled(bool enabled) async {
    final db = await database;
    await db.insert(
      _gameStateTable,
      {'key': 'musicEnabled', 'value': enabled ? 1.0 : 0.0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> getMusicEnabled() async {
    final db = await database;
    try {
      final result = await db.query(
        _gameStateTable,
        where: 'key = ?',
        whereArgs: ['musicEnabled'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value != 0;
        if (value is String) return value != '0';
      }
      return true; // Default to enabled
    } catch (e) {
      print('Error loading musicEnabled: $e');
      return true;
    }
  }

  // ===== MUSIC VOLUME =====

  static Future<void> saveMusicVolume(double volume) async {
    final db = await database;
    await db.insert(
      _gameStateTable,
      {'key': 'musicVolume', 'value': volume},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<double> getMusicVolume() async {
    final db = await database;
    try {
      final result = await db.query(
        _gameStateTable,
        where: 'key = ?',
        whereArgs: ['musicVolume'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value.toDouble();
        if (value is String) return double.parse(value);
      }
      return 0.5; // Default volume
    } catch (e) {
      print('Error loading musicVolume: $e');
      return 0.5;
    }
  }

  // ===== TRANSACTIONS =====

  static Future<List<TransactionModel>> getAll() async {
    await ensureTable();
    final db = await database;
    final maps = await db.query(_transactionsTable, orderBy: 'date DESC');
    return maps.map((m) => TransactionModel(
      id: m['id'] as String,
      type: m['type'] as String,
      amount: (m['amount'] as num).toDouble(),
      note: m['note'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      goalId: m['goalId'] as String?,
    )).toList();
  }

  static Future<void> insert(TransactionModel t) async {
    await ensureTable();
    final db = await database;
    await db.insert(_transactionsTable, t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> update(TransactionModel t) async {
    await ensureTable();
    final db = await database;
    await db.update(
      _transactionsTable,
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  static Future<void> delete(String id) async {
    await ensureTable();
    final db = await database;
    await db.delete(_transactionsTable, where: 'id = ?', whereArgs: [id]);
  }

  // DEBUG: Clear all financial data (coins, money, and transactions)
  static Future<void> clearAllFinancialData() async {
    final db = await database;
    await db.delete(_transactionsTable);
    await db.delete(_gameStateTable);
    print('Cleared all financial data from database');
  }
}