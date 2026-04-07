import 'dart:convert';
import 'package:flutter/services.dart';

class LessonQuizService {
  /// Get list of quiz files based on language
  static List<String> _getQuizFiles(String language) {
    final suffix = language == 'sk' ? '_sk' : '_en';
    return [
      'assets/quizes/quiz_database_01$suffix.json',
      'assets/quizes/quiz_database_02$suffix.json',
      'assets/quizes/quiz_database_03$suffix.json',
    ];
  }

  const LessonQuizService();

  /// Load all questions for a specific lesson by lessonId
  /// Returns list of questions from quiz databases
  Future<List<QuizQuestion>> getQuestionsForLesson(
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

  /// Get random N questions from all available questions for lesson
  Future<List<QuizQuestion>> getRandomQuestionsForLesson(
    int lessonId, {
    int count = 5,
    String language = 'en',
  }) async {
    final allQuestions = await getQuestionsForLesson(lessonId, language: language);
    if (allQuestions.isEmpty) {
      return [];
    }

    final random = DateTime.now().millisecond;
    allQuestions.shuffle();

    return allQuestions.take(count.clamp(1, allQuestions.length)).toList();
  }

  /// Get lesson info (name, number) by lessonId
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

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['questionId'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List<dynamic>),
        correctAnswer: json['correctAnswer'] as int,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'questionId': id,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
      };
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
