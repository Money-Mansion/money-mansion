import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import '../models/quiz_progress.dart';

class QuizProgressDatabaseService {
  static const String _tableName = 'quiz_progress';
  static const String _dbName = 'money_mansion.db';
  static const int _dbVersion = 10; // Bumped high to force table recreation

  static Database? _database;
  static bool _initialized = false;



  static Future<void> initializeDatabase() async {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
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
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ensure table exists (in case it was missing)
    await _createTable(db, newVersion);
    
    // Migrate from older versions
    if (oldVersion < 4) {
      try {
        // Check if column already exists
        final info = await db.rawQuery('PRAGMA table_info($_tableName)');
        final hasRewardedColumn = info.any((col) => col['name'] == 'rewardedQuestionIds');
        
        if (!hasRewardedColumn) {
          await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN rewardedQuestionIds TEXT DEFAULT ""'
          );
        }
      } catch (e) {
        print('Error during migration: $e');
      }
    }
  }

  static Future<void> _createTable(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          quizId TEXT NOT NULL,
          sectionId TEXT NOT NULL,
          score INTEGER NOT NULL DEFAULT 0,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          completedDate INTEGER,
          rewardedQuestionIds TEXT DEFAULT "",
          PRIMARY KEY (quizId, sectionId)
        )
      ''');
      print('✓ Quiz progress table created/verified');
    } catch (e) {
      print('Error creating table: $e');
      rethrow; // Re-throw so we know initialization failed
    }
  }

  /// Ensure table exists (defensive check)
  static Future<void> _ensureTableExists() async {
    try {
      final db = await database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          quizId TEXT NOT NULL,
          sectionId TEXT NOT NULL,
          score INTEGER NOT NULL DEFAULT 0,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          completedDate INTEGER,
          rewardedQuestionIds TEXT DEFAULT "",
          PRIMARY KEY (quizId, sectionId)
        )
      ''');
    } catch (e) {
      print('Error ensuring table exists: $e');
    }
  }

  /// Get progress for a specific quiz
  static Future<QuizProgress?> getProgress(
    String sectionId,
    String quizId,
  ) async {
    try {
      await _ensureTableExists(); // Defensive check
      final db = await database;
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
      await _ensureTableExists(); // Defensive check
      final db = await database;
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
      await _ensureTableExists(); // Defensive check
      final db = await database;
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
      await _ensureTableExists(); // Defensive check
      final db = await database;
      
      // Get existing progress to preserve rewarded questions
      var existingProgress = await getProgress(sectionId, quizId);
      final rewardedIds = existingProgress?.rewardedQuestionIds ?? {};
      
      final newProgress = QuizProgress(
        quizId: quizId,
        sectionId: sectionId,
        score: score,
        isCompleted: true,
        completedDate: DateTime.now(),
        rewardedQuestionIds: rewardedIds,
      );
      
      await db.insert(
        _tableName,
        newProgress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✓ Quiz progress saved: $quizId section $sectionId score $score');
    } catch (e) {
      print('Error updating quiz score: $e');
    }
  }

  /// Mark a question as rewarded for a quiz
  static Future<void> markQuestionAsRewarded(
    String sectionId,
    String quizId,
    String questionId,
  ) async {
    try {
      await _ensureTableExists(); // Defensive check
      final db = await database;

      // Get existing progress
      var existingProgress = await getProgress(sectionId, quizId);
      
      // If no progress exists, create new one
      existingProgress ??= QuizProgress(
        quizId: quizId,
        sectionId: sectionId,
      );

      // Add question ID to rewarded set
      final updatedRewardedIds = {...existingProgress.rewardedQuestionIds, questionId};
      final updatedProgress = existingProgress.copyWith(
        rewardedQuestionIds: updatedRewardedIds,
      );

      // Save back to database
      await db.insert(
        _tableName,
        updatedProgress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✓ Question $questionId marked as rewarded');
    } catch (e) {
      print('Error marking question as rewarded: $e');
    }
  }

  /// Check if a question has already been rewarded
  static Future<bool> isQuestionRewarded(
    String sectionId,
    String quizId,
    String questionId,
  ) async {
    try {
      final progress = await getProgress(sectionId, quizId);
      return progress?.rewardedQuestionIds.contains(questionId) ?? false;
    } catch (e) {
      print('Error checking if question is rewarded: $e');
      return false;
    }
  }

  /// Get all progress
  static Future<List<QuizProgress>> getAllProgress() async {
    try {
      await _ensureTableExists(); // Defensive check
      final db = await database;
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
      await _ensureTableExists(); // Defensive check
      final db = await database;
      await db.delete(_tableName);
      print('✓ All quiz progress cleared');
    } catch (e) {
      print('Error clearing progress: $e');
    }
  }
}
