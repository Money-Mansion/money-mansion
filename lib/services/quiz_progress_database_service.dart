import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/quiz_progress.dart';

class QuizProgressDatabaseService {
  static const String _tableName = 'quiz_progress';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 3;

  static Database? _database;
  static bool _initialized = false;

  static Future<void> initializeDatabase() async {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    // Initialize database and create table
    _database ??= await _initDatabase();
    _initialized = true;
  }

  // Initialize database
  static Future<Database> get database async {
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
      },
      onOpen: (db) async {
        await _createTable(db, _dbVersion);
      },
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        quizId TEXT NOT NULL,
        sectionId TEXT NOT NULL,
        score INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedDate INTEGER,
        PRIMARY KEY (quizId, sectionId)
      )
    ''');
  }

  /// Get progress for a specific quiz
  static Future<QuizProgress?> getProgress(
    String sectionId,
    String quizId,
  ) async {
    try {
      final db = await database;
      await _createTable(db, _dbVersion);
      final result = await db.query(
        _tableName,
        where: 'sectionId = ? AND quizId = ?',
        whereArgs: [sectionId, quizId],
      );

      if (result.isEmpty) {
        return null;
      }

      return QuizProgress.fromMap(result.first);
    } catch (e) {
      print('Error getting quiz progress: $e');
      return null;
    }
  }

  /// Get all progress for a section
  static Future<List<QuizProgress>> getSectionProgress(
    String sectionId,
  ) async {
    try {
      final db = await database;
      await _createTable(db, _dbVersion);
      final result = await db.query(
        _tableName,
        where: 'sectionId = ?',
        whereArgs: [sectionId],
      );

      return result.map((map) => QuizProgress.fromMap(map)).toList();
    } catch (e) {
      print('Error getting section progress: $e');
      return [];
    }
  }

  /// Save or update quiz progress
  static Future<void> saveProgress(QuizProgress progress) async {
    try {
      final db = await database;
      await _createTable(db, _dbVersion);
      await db.insert(
        _tableName,
        progress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving quiz progress: $e');
    }
  }

  /// Update score for a quiz
  static Future<void> updateScore(
    String sectionId,
    String quizId,
    int score,
  ) async {
    try {
      // Ensure table exists before trying to insert
      final db = await database;
      await _createTable(db, _dbVersion);
      
      final newProgress = QuizProgress(
        quizId: quizId,
        sectionId: sectionId,
        score: score,
        isCompleted: true,
        completedDate: DateTime.now(),
      );
      
      await db.insert(
        _tableName,
        newProgress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error updating quiz score: $e');
    }
  }

  /// Get all quiz progress
  static Future<List<QuizProgress>> getAllProgress() async {
    try {
      final db = await database;
      await _createTable(db, _dbVersion);
      final result = await db.query(_tableName);
      return result.map((map) => QuizProgress.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all progress: $e');
      return [];
    }
  }

  /// Clear all progress (for testing)
  static Future<void> clearAllProgress() async {
    try {
      final db = await database;
      await _createTable(db, _dbVersion);
      await db.delete(_tableName);
    } catch (e) {
      print('Error clearing progress: $e');
    }
  }
}
