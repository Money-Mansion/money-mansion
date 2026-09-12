import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question_types.dart';

class LessonQuizService {
  static List<String> _getQuizFiles(String language) {
    final suffix = language == 'sk' ? '_sk' : '_en';
    return [
      'assets/quizes/quiz_database_01$suffix.json',
      'assets/quizes/quiz_database_02$suffix.json',
      'assets/quizes/quiz_database_03$suffix.json',
      'assets/quizes/quiz_database_04$suffix.json',
      'assets/quizes/quiz_database_05$suffix.json',
    ];
  }

  const LessonQuizService();

  Future<List<QuizQuestion>> getQuestionsForLesson(
    int lessonId, {
    String language = 'en',
  }) async {
    final quizFiles = _getQuizFiles(language);

    for (final file in quizFiles) {
      try {
        final jsonString = await rootBundle.loadString(file, cache: false);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final quizzes = jsonData['quizzes'] as List<dynamic>;

        for (final quiz in quizzes) {
          final lessons = quiz['lessons'] as List<dynamic>;
          for (final lesson in lessons) {
            if (lesson['lessonId'] == lessonId) {
              final questions = lesson['questions'] as List<dynamic>;
              return questions
                  .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      } catch (e) {
        print('Error loading quiz file $file: $e');
      }
    }
    return [];
  }

  Future<List<QuizQuestion>> getRandomQuestionsForLesson(
    int lessonId, {
    int count = 5,
    String language = 'en',
  }) async {
    final allQuestions =
        await getQuestionsForLesson(lessonId, language: language);
    if (allQuestions.isEmpty) return [];

    allQuestions.shuffle();
    return allQuestions.take(count.clamp(1, allQuestions.length)).toList();
  }

  Future<LessonQuizInfo?> getLessonInfo(
    int lessonId, {
    String language = 'en',
  }) async {
    final quizFiles = _getQuizFiles(language);

    for (final file in quizFiles) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final quizzes = jsonData['quizzes'] as List<dynamic>;

        for (final quiz in quizzes) {
          final lessons = quiz['lessons'] as List<dynamic>;
          for (final lesson in lessons) {
            if (lesson['lessonId'] == lessonId) {
              return LessonQuizInfo(
                id: lessonId,
                name: lesson['lessonName'] as String,
                number: lesson['lessonNumber'] as int,
                sectionName: quiz['sectionName'] as String,
                sectionId: quiz['section'].toString(),
              );
            }
          }
        }
      } catch (e) {
        print('Error loading quiz file $file: $e');
      }
    }
    return null;
  }
}

class LessonQuizInfo {
  final int id;
  final String name;
  final int number;
  final String sectionName;
  final String sectionId;

  const LessonQuizInfo({
    required this.id,
    required this.name,
    required this.number,
    required this.sectionName,
    required this.sectionId,
  });
}