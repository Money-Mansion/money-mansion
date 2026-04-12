import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/lesson_quiz_service.dart';
import '../../services/quiz_progress_database_service.dart';
import '../../services/streak_service.dart';
import '../../services/app_localizations_provider.dart';
import '../../services/app_localizations.dart';
import '../../models/game_state.dart';

class LessonQuizScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;

  const LessonQuizScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  late Future<List<QuizQuestion>> questionsFuture;
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showFeedback = false;
  bool? isCorrect;
  int? selectedAnswer;
  LessonQuizInfo? quizInfo;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize immediately
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    // Initialize database
    await QuizProgressDatabaseService.initializeDatabase();
    
    // Only update if mounted
    if (!mounted) return;
    
    // Load questions
    setState(() {
      questionsFuture = _loadQuestionsAsync();
      _initialized = true;
    });
  }

  Future<List<QuizQuestion>> _loadQuestionsAsync() async {
    try {
      // Get current language from context
      final l10nProvider = context.read<AppLocalizationsProvider>();
      final language = l10nProvider.currentLanguage;
      
      quizInfo = await const LessonQuizService().getLessonInfo(
        widget.lessonId,
        language: language,
      );
      final loadedQuestions = await const LessonQuizService().getRandomQuestionsForLesson(
        widget.lessonId,
        count: 5, // Random 5 questions
        language: language,
      );
      
      if (!mounted) return [];
      
      setState(() {
        questions = loadedQuestions;
      });
      
      return loadedQuestions;
    } catch (e) {
      print('Error loading questions: $e');
      return [];
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (showFeedback) return; // Prevent multiple answers

    final correctIndex =
        questions[currentQuestionIndex].correctAnswer;
    final correct = selectedIndex == correctIndex;

    setState(() {
      selectedAnswer = selectedIndex;
      isCorrect = correct;
      showFeedback = true;
      if (correct) correctAnswers++;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showFeedback = false;
        selectedAnswer = null;
        isCorrect = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final score = ((correctAnswers / questions.length) * 100).toInt();
    final l10nProvider = context.read<AppLocalizationsProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10nProvider.translate('quizResults')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$correctAnswers/${questions.length}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10nProvider.translate('quizScore')}$score%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _getScoreColor(score),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getScoreColor(score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getScoreMessage(score, l10nProvider),
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save progress
              if (quizInfo != null) {
                await QuizProgressDatabaseService.updateScore(
                  quizInfo!.sectionId,
                  widget.lessonId.toString(),
                  score,
                );
                // Update streak when quiz is completed
                final newStreak = await StreakService.onQuizCompleted();
                // Update GameState so TopBar shows the new streak
                if (mounted) {
                  context.read<GameState>().setCurrentStreak(newStreak);
                }
              }
              Navigator.of(context).pop(); // Close dialog
              // Wait a moment then close the quiz screen
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.of(context).pop(); // Close quiz screen
              });
            },
            child: Text(l10nProvider.translate('quizClose')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog only
              _resetQuiz(); // Reset and restart
            },
            child: Text(l10nProvider.translate('quizRetry')),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      correctAnswers = 0;
      showFeedback = false;
      isCorrect = null;
      selectedAnswer = null;
      questionsFuture = _loadQuestionsAsync();
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFFC107); // Yellow
    return const Color(0xFFF44336); // Red
  }

  String _getScoreMessage(int score, AppLocalizationsProvider l10nProvider) {
    if (score >= 90) return l10nProvider.translate('quizExcellent');
    if (score >= 70) return l10nProvider.translate('quizGood');
    if (score >= 60) return l10nProvider.translate('quizOkay');
    return l10nProvider.translate('quizTryAgain');
  }

  @override
  Widget build(BuildContext context) {
    // Ensure questionsFuture is initialized
    if (!_initialized) {
      questionsFuture = _loadQuestionsAsync();
    }
    
    final l10nProvider = context.watch<AppLocalizationsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || questions.isEmpty) {
            return Center(
              child: Text(questions.isEmpty
                  ? l10nProvider.translate('quizNoQuestions')
                  : '${l10nProvider.translate('quizError')}${snapshot.error}'),
            );
          }

          final question = questions[currentQuestionIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Otázka ${currentQuestionIndex + 1}/${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Správne: $correctAnswers',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  minHeight: 6,
                ),
                const SizedBox(height: 24),

                // Question
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                ...List.generate(
                  question.options.length,
                  (index) {
                    final isSelected = selectedAnswer == index;
                    final isCorrectAnswer =
                        index == question.correctAnswer;
                    final isWrongSelected =
                        isSelected && isCorrect == false;

                    Color backgroundColor = Colors.white;
                    Color borderColor = Colors.grey[300]!;

                    if (showFeedback) {
                      if (isCorrectAnswer) {
                        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
                        borderColor = const Color(0xFF4CAF50);
                      } else if (isWrongSelected) {
                        backgroundColor = const Color(0xFFF44336).withOpacity(0.1);
                        borderColor = const Color(0xFFF44336);
                      }
                    }

                    return GestureDetector(
                      onTap: showFeedback ? null : () => _answerQuestion(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: Border.all(color: borderColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            if (showFeedback && isCorrectAnswer)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              )
                            else if (showFeedback && isWrongSelected)
                              const Icon(
                                Icons.cancel,
                                color: Color(0xFFF44336),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Feedback message
                if (showFeedback) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect!
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCorrect! ? '✓ Správne!' : '✗ Nesprávne.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCorrect!
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vysvetlenie: ${question.explanation}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(currentQuestionIndex == questions.length - 1
                        ? 'Ukončiť kvíz'
                        : 'Ďalšia otázka'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
