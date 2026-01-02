import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/transaction.dart';

class FinancialDatabaseService {
  static const _dbName = 'money_mansion.db';
  static const _tableName = 'transactions';
  static const _dbVersion = 1;

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
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // ⚡ Create transactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date INTEGER NOT NULL
      )
    ''');
  }

  // Ensure table exists before any operation
  static Future<void> ensureTable() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date INTEGER NOT NULL
      )
    ''');
  }

  // Get all transactions
  static Future<List<TransactionModel>> getAll() async {
    await ensureTable(); // ⚡ important
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'date DESC');
    return maps.map((m) => TransactionModel(
      id: m['id'] as String,
      type: m['type'] as String,
      amount: m['amount'] as double,
      note: m['note'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
    )).toList();
  }

  // Insert
  static Future<void> insert(TransactionModel t) async {
    await ensureTable();
    final db = await database;
    await db.insert(_tableName, t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update
  static Future<void> update(TransactionModel t) async {
    await ensureTable();
    final db = await database;
    await db.update(
      _tableName,
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  // Delete
  static Future<void> delete(String id) async {
    await ensureTable();
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
