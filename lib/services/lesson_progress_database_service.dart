import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LessonProgressDatabaseService {
  static Database? _db;
  static const _tableName = 'opened_lessons';

  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'lesson_progress.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            lessonQuizId INTEGER PRIMARY KEY
          )
        ''');
      },
    );
    return _db!;
  }

  /// Call this when a user opens/starts a lesson
  static Future<void> markLessonOpened(int lessonQuizId) async {
    final db = await _getDb();
    await db.insert(
      _tableName,
      {'lessonQuizId': lessonQuizId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Returns true if the lesson has been opened at least once
  static Future<bool> hasLessonBeenOpened(int lessonQuizId) async {
    final db = await _getDb();
    final result = await db.query(
      _tableName,
      where: 'lessonQuizId = ?',
      whereArgs: [lessonQuizId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Returns all opened lessonQuizIds
  static Future<Set<int>> getAllOpenedLessonIds() async {
    final db = await _getDb();
    final result = await db.query(_tableName);
    return result.map((r) => r['lessonQuizId'] as int).toSet();
  }
}