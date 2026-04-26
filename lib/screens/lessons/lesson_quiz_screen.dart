import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/lesson_quiz_service.dart';
import '../../services/quiz_progress_database_service.dart';
import '../../services/quiz_service.dart' hide QuizQuestion;
import '../../services/streak_service.dart';
import '../../services/app_localizations_provider.dart';
import '../../services/app_localizations.dart';
import '../../models/game_state.dart';
import '../../models/quiz_progress.dart';

class LessonQuizScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final VoidCallback? onQuizCompleted; // Callback to refresh parent when quiz is done

  const LessonQuizScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.onQuizCompleted,
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
  bool _isQuizLocked = false; // Track if quiz is locked in progression

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
      
      // Determine if this quiz is locked (not yet unlocked in sequence)
      if (quizInfo != null) {
        _isQuizLocked = await _checkIfQuizLocked(
          quizInfo!.sectionId,
          widget.lessonId.toString(),
          language,
        );
        print('✓ Quiz locked status: $_isQuizLocked for quiz ${widget.lessonId}');
      }
      
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

  /// Determine if this quiz is locked (not yet unlocked in the progression sequence)
  /// Returns true if quiz should not award coins yet
  Future<bool> _checkIfQuizLocked(
    String sectionId,
    String quizId,
    String language,
  ) async {
    try {
      // Get all sections to find this quiz's position
      final sections = await const QuizService().getAllSections(language: language);
      final sectionIndex = sections.indexWhere((s) => s.id == sectionId);
      
      if (sectionIndex == -1) {
        print('⚠ Section not found: $sectionId');
        return true; // Assume locked if section not found
      }

      final section = sections[sectionIndex];

      // Find quiz index in section
      final quizIndex = section.lessons.indexWhere((q) => q.id == quizId);
      if (quizIndex == -1) {
        print('⚠ Quiz not found in section: $quizId');
        return true; // Assume locked if not found
      }

      // Get progress to check if quizzes are completed
      final allProgress = await QuizProgressDatabaseService.getAllProgress();

      // If it's the first quiz in section
      if (quizIndex == 0) {
        // First quiz of first section is always unlocked
        if (sectionIndex == 0) {
          return false;
        }

        // For first quiz of other sections: check if ALL quizzes in PREVIOUS section are completed
        final previousSection = sections[sectionIndex - 1];
        for (final prevSectionQuiz in previousSection.lessons) {
          QuizProgress? prevProgress;
          try {
            prevProgress = allProgress.firstWhere(
              (p) => p.quizId == prevSectionQuiz.id && p.sectionId == previousSection.id,
            );
          } catch (e) {
            prevProgress = null;
          }

          // If any quiz in previous section is not completed, this quiz is locked
          if (prevProgress == null || prevProgress.getStatus() == QuizStatus.notDone) {
            return true; // Quiz is locked - previous section not completed
          }
        }

        return false; // All quizzes in previous section are completed
      }

      // For non-first quizzes: check if all previous quizzes in THIS section are completed
      for (int i = 0; i < quizIndex; i++) {
        final prevQuizId = section.lessons[i].id;
        QuizProgress? prevProgress;
        try {
          prevProgress = allProgress.firstWhere(
            (p) => p.quizId == prevQuizId && p.sectionId == sectionId,
          );
        } catch (e) {
          prevProgress = null;
        }

        // If previous quiz not completed, current quiz is locked
        if (prevProgress == null || prevProgress.getStatus() == QuizStatus.notDone) {
          return true; // Quiz is locked
        }
      }

      return false; // Quiz is unlocked (all previous completed)
    } catch (e) {
      print('Error checking if quiz is locked: $e');
      return true; // Assume locked on error
    }
  }

  void _answerQuestion(int selectedIndex) async {
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

    // If correct, check if we should award coins
    if (correct && quizInfo != null) {
      final question = questions[currentQuestionIndex];
      final isAlreadyRewarded = await QuizProgressDatabaseService.isQuestionRewarded(
        quizInfo!.sectionId,
        widget.lessonId.toString(),
        question.id,
      );

      // Only award coins if:
      // 1. Question hasn't been rewarded yet
      // 2. Quiz is NOT locked (quiz is in the unlocked progression sequence)
      if (!isAlreadyRewarded && !_isQuizLocked && mounted) {
        // Award coins
        const coinsPerQuestion = 2;
        context.read<GameState>().awardQuizQuestionCoins(coinsPerQuestion);
        print('✓ Awarded $coinsPerQuestion coins for question (quiz unlocked)');
        
        // Mark as rewarded
        await QuizProgressDatabaseService.markQuestionAsRewarded(
          quizInfo!.sectionId,
          widget.lessonId.toString(),
          question.id,
        );

        // Show reward animation/notification
        _showCoinRewardNotification(coinsPerQuestion);
      }
    }
  }

  void _showCoinRewardNotification(int coins) {
    final l10nProvider = context.read<AppLocalizationsProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 160, left: 16, right: 16),
        backgroundColor: const Color(0xFF4CAF50),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
            const SizedBox(width: 8),
            Text(
              l10nProvider.translate('quizCoinReward', replacements: {'coins': '$coins'}),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
            // Show note if quiz is locked (coins not earned)
            if (_isQuizLocked)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10nProvider.translate('quizLockedNoCoins'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10nProvider.translate('quizLockedNoProgress'),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save progress ONLY if quiz is not locked
              if (quizInfo != null && !_isQuizLocked) {
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
              } else if (_isQuizLocked) {
                print('⚠ Quiz is locked - progress NOT saved');
              }
              // Notify parent that quiz is complete so it can refresh
              widget.onQuizCompleted?.call();
              Navigator.of(context).pop(); // Close dialog
              // Wait a moment then close the quiz screen
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.of(context).pop(); // Close quiz screen
              });
            },
            child: Text(l10nProvider.translate('quizClose')),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save progress FIRST (same as Close), then restart quiz
              if (quizInfo != null && !_isQuizLocked) {
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
              // Notify parent that quiz is complete
              widget.onQuizCompleted?.call();
              Navigator.pop(dialogContext); // Close dialog only
              _resetQuiz(); // Reset and restart quiz
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                      l10nProvider.translate('quizQuestion', replacements: {
                        'current': '${currentQuestionIndex + 1}',
                        'total': '${questions.length}',
                      }),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      l10nProvider.translate('quizCorrectCount', replacements: {
                        'count': '$correctAnswers',
                      }),
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
                          isCorrect!
                              ? l10nProvider.translate('quizAnswerCorrect')
                              : l10nProvider.translate('quizAnswerWrong'),
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
                          l10nProvider.translate('quizExplanation', replacements: {
                            'text': question.explanation,
                          }),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(
                      currentQuestionIndex == questions.length - 1
                          ? l10nProvider.translate('quizFinish')
                          : l10nProvider.translate('quizNextQuestion'),
                    ),
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