import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question_types.dart';

class QuizService {
  static const Map<String, List<String>> _quizFilesByLanguage = {
    'sk': [
      'assets/quizes/quiz_database_01_sk.json',
      'assets/quizes/quiz_database_02_sk.json',
      'assets/quizes/quiz_database_03_sk.json',
      'assets/quizes/quiz_database_04_sk.json',
    ],
    'en': [
      'assets/quizes/quiz_database_01_en.json',
      'assets/quizes/quiz_database_02_en.json',
      'assets/quizes/quiz_database_03_en.json',
      'assets/quizes/quiz_database_04_en.json',
    ],
  };

  const QuizService();

  Future<List<QuizSection>> getAllSections({String language = 'en'}) async {
    final sections = <QuizSection>[];
    final quizFiles =
        _quizFilesByLanguage[language] ?? _quizFilesByLanguage['en']!;

    for (final file in quizFiles) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final quizzes = jsonData['quizzes'] as List<dynamic>;

        for (final quiz in quizzes) {
          sections.add(QuizSection(
            id: quiz['section'].toString(),
            name: quiz['sectionName'] as String,
            lessons: _parseQuizzes(quiz['lessons'] as List<dynamic>),
          ));
        }
      } catch (e) {
        print('Error loading quiz file $file: $e');
      }
    }

    return sections;
  }

  Future<QuizSection?> getSection(String sectionId,
      {String language = 'en'}) async {
    final sections = await getAllSections(language: language);
    try {
      return sections.firstWhere((s) => s.id == sectionId);
    } catch (e) {
      return null;
    }
  }

  List<Quiz> _parseQuizzes(List<dynamic> lessonsData) {
    return lessonsData
        .map((lesson) => Quiz(
              id: lesson['lessonId'].toString(),
              number: lesson['lessonNumber'] as int,
              name: lesson['lessonName'] as String,
              questions:
                  _parseQuestions(lesson['questions'] as List<dynamic>),
            ))
        .toList();
  }

  List<QuizQuestion> _parseQuestions(List<dynamic> questionsData) {
    return questionsData
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
  }
}

class QuizSection {
  final String id;
  final String name;
  final List<Quiz> lessons;

  const QuizSection({
    required this.id,
    required this.name,
    required this.lessons,
  });
}

class Quiz {
  final String id;
  final int number;
  final String name;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.id,
    required this.number,
    required this.name,
    required this.questions,
  });
}