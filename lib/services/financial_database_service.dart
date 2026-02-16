import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/transaction.dart';

class FinancialDatabaseService {
  static const _dbName = 'money_mansion.db';
  static const _transactionsTable = 'transactions';
  static const _gameStateTable = 'game_state';
  static const _dbVersion = 3;

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
    _database ??= await _initDatabase();
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
        if (oldVersion < 3) {
          // Create game_state table if upgrading to v3
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_gameStateTable (
              key TEXT PRIMARY KEY,
              value REAL NOT NULL
            )
          ''');
        }
        await _ensureGoalIdColumn(db);
      },
      onOpen: (db) async {
        // Ensure all tables exist
        await _ensureTransactionsTable(db);
        await _ensureGameStateTable(db);
        await _ensureGoalIdColumn(db);
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
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
    
    // Create game_state table (v3+)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_gameStateTable (
        key TEXT PRIMARY KEY,
        value REAL NOT NULL
      )
    ''');
  }

  // Ensure transactions table exists before any operation
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
    final columnNames =
        columns.map((c) => c['name'] as String).toSet();
    if (!columnNames.contains('goalId')) {
      await db.execute(
        'ALTER TABLE $_transactionsTable ADD COLUMN goalId TEXT',
      );
    }
  }

  // ===== COINS & MONEY PERSISTENCE (v3+) =====

  /// Save coins to database
  static Future<void> saveCoins(int coins) async {
    final db = await database;
    await db.insert(
      _gameStateTable,
      {'key': 'coins', 'value': coins.toDouble()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load coins from database (returns 0 if not found)
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
        if (value is num) {
          return value.toInt();
        } else if (value is String) {
          // Try parsing as double first (in case it's "10.0"), then convert to int
          try {
            return int.parse(value);
          } catch (e) {
            // If int parsing fails, try double then convert
            return double.parse(value).toInt();
          }
        }
        return 0;
      }
      return 0;
    } catch (e) {
      print('Error loading coins: $e');
      return 0;
    }
  }

  /// Save money to database
  static Future<void> saveMoney(double money) async {
    final db = await database;
    await db.insert(
      _gameStateTable,
      {'key': 'money', 'value': money},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load money from database (returns 0 if not found)
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
        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          return double.parse(value);
        }
        return 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error loading money: $e');
      return 0.0;
    }
  }

  // ===== TRANSACTIONS =====
  static Future<List<TransactionModel>> getAll() async {
    await ensureTable(); // ⚡ important
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

  // Insert
  static Future<void> insert(TransactionModel t) async {
    await ensureTable();
    final db = await database;
    await db.insert(_transactionsTable, t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update
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

  // Delete
  static Future<void> delete(String id) async {
    await ensureTable();
    final db = await database;
    await db.delete(_transactionsTable, where: 'id = ?', whereArgs: [id]);
  }
}
