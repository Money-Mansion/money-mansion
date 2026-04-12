import 'package:sqflite/sqflite.dart';
import 'financial_database_service.dart';

/// StreakService manages the daily quiz streak system.
/// 
/// Tracks:
/// - Current streak (consecutive days with at least one quiz)
/// - Max streak (personal best)
/// - Last quiz date (to check if today already has a quiz)
class StreakService {
  /// Check if today is a new day (no quiz completed yet)
  static Future<bool> isNewDay() async {
    final lastQuizDate = await _getLastQuizDate();
    if (lastQuizDate == null) {
      return true; // Never completed a quiz
    }

    final today = DateTime.now();
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastQuizDate);
    
    // Compare just the date part (ignore time)
    return lastDate.year != today.year ||
        lastDate.month != today.month ||
        lastDate.day != today.day;
  }

  /// Called when a quiz is completed
  /// If it's a new day, increments streak and marks today as quiz-completed
  /// Returns the new streak count
  static Future<int> onQuizCompleted() async {
    final isNew = await isNewDay();
    
    if (!isNew) {
      // Already completed a quiz today, don't change streak
      return await getCurrentStreak();
    }

    // This is a new day! Increment streak
    int currentStreak = await getCurrentStreak();
    
    // Check if streak should be reset (gap of more than 1 day)
    if (currentStreak > 0) {
      final lastQuizDate = await _getLastQuizDate();
      if (lastQuizDate != null) {
        final lastDate = DateTime.fromMillisecondsSinceEpoch(lastQuizDate);
        final today = DateTime.now();
        
        // Calculate days difference
        final difference = today.difference(lastDate).inDays;
        
        if (difference > 1) {
          // More than 1 day gap - reset to 1
          currentStreak = 0;
        }
      }
    }

    // Increment streak
    currentStreak++;
    
    // Update in database
    await _saveCurrentStreak(currentStreak);
    await _saveLastQuizDate(DateTime.now().millisecondsSinceEpoch);

    // Update max streak if current is higher
    final maxStreak = await getMaxStreak();
    if (currentStreak > maxStreak) {
      await _saveMaxStreak(currentStreak);
    }

    return currentStreak;
  }

  /// Get current streak count
  static Future<int> getCurrentStreak() async {
    final db = await FinancialDatabaseService.database;
    try {
      final result = await db.query(
        'game_state',
        where: 'key = ?',
        whereArgs: ['currentStreak'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value.toInt();
        if (value is String) return int.parse(value);
      }
      return 0;
    } catch (e) {
      print('Error getting current streak: $e');
      return 0;
    }
  }

  /// Get max streak (personal best)
  static Future<int> getMaxStreak() async {
    final db = await FinancialDatabaseService.database;
    try {
      final result = await db.query(
        'game_state',
        where: 'key = ?',
        whereArgs: ['maxStreak'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value.toInt();
        if (value is String) return int.parse(value);
      }
      return 0;
    } catch (e) {
      print('Error getting max streak: $e');
      return 0;
    }
  }

  /// Get last quiz completion date (milliseconds since epoch)
  static Future<int?> _getLastQuizDate() async {
    final db = await FinancialDatabaseService.database;
    try {
      final result = await db.query(
        'game_state',
        where: 'key = ?',
        whereArgs: ['lastQuizDate'],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final value = result[0]['value'];
        if (value is num) return value.toInt();
        if (value is String) return int.parse(value);
      }
      return null;
    } catch (e) {
      print('Error getting last quiz date: $e');
      return null;
    }
  }

  /// Save current streak
  static Future<void> _saveCurrentStreak(int streak) async {
    final db = await FinancialDatabaseService.database;
    await db.insert(
      'game_state',
      {'key': 'currentStreak', 'value': streak.toDouble()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Save max streak
  static Future<void> _saveMaxStreak(int maxStreak) async {
    final db = await FinancialDatabaseService.database;
    await db.insert(
      'game_state',
      {'key': 'maxStreak', 'value': maxStreak.toDouble()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Save last quiz date
  static Future<void> _saveLastQuizDate(int millisecondsSinceEpoch) async {
    final db = await FinancialDatabaseService.database;
    await db.insert(
      'game_state',
      {'key': 'lastQuizDate', 'value': millisecondsSinceEpoch.toDouble()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Reset streak (for testing or if user misses a day intentionally)
  static Future<void> resetStreak() async {
    await _saveCurrentStreak(0);
    await _saveLastQuizDate(0);
  }
}
