import 'dart:convert';
import 'package:flutter/services.dart';

class QuizService {
  /// Loading the NEW improved quiz files (1 file per section)
  /// All legacy files are disconnected and kept on disk as backup only:
  /// - quiz_database_1.json, 2.json, 3.json (old plain versions)
  /// - quiz_database_*_sk01.json, quiz_database_*_en01.json (old renamed versions)
  static const Map<String, List<String>> _quizFilesByLanguage = {
    'sk': [
      'assets/quizes/quiz_database_01_sk.json',
      'assets/quizes/quiz_database_02_sk.json',
      'assets/quizes/quiz_database_03_sk.json',
    ],
    'en': [
      'assets/quizes/quiz_database_01_en.json',
      'assets/quizes/quiz_database_02_en.json',
      'assets/quizes/quiz_database_03_en.json',
    ],
  };

  const QuizService();

  /// Load all quiz sections for a specific language
  /// Defaults to 'en' if language is not supported
  Future<List<QuizSection>> getAllSections({String language = 'en'}) async {
    final sections = <QuizSection>[];
    
    // Use provided language if available, otherwise fall back to 'en'
    final quizFiles = _quizFilesByLanguage[language] ?? _quizFilesByLanguage['en']!;
    
    for (final file in quizFiles) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        final quizzes = jsonData['quizzes'] as List<dynamic>;
        
        for (final quiz in quizzes) {
          final section = QuizSection(
            id: quiz['section'].toString(),
            name: quiz['sectionName'] as String,
            lessons: _parseQuizzes(quiz['lessons'] as List<dynamic>),
          );
          sections.add(section);
        }
      } catch (e) {
        print('Error loading quiz file $file: $e');
      }
    }
    
    return sections;
  }

  /// Get section by ID for a specific language
  Future<QuizSection?> getSection(String sectionId, {String language = 'en'}) async {
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
              questions: _parseQuestions(lesson['questions'] as List<dynamic>),
            ))
        .toList();
  }

  List<QuizQuestion> _parseQuestions(List<dynamic> questionsData) {
    return questionsData
        .map((question) => QuizQuestion(
              id: question['questionId'] as String,
              question: question['question'] as String,
              options:
                  List<String>.from(question['options'] as List<dynamic>),
              correctAnswer: question['correctAnswer'] as int,
              explanation: question['explanation'] as String,
            ))
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
}
