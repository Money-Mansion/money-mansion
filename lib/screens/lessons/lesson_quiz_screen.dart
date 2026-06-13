// ============================================================
// UPDATED: lib/screens/lessons/lesson_quiz_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:money_mansion/models/quiz_question_types.dart';
import 'package:provider/provider.dart';
import '../../services/lesson_quiz_service.dart';
import '../../services/quiz_progress_database_service.dart';
import '../../services/quiz_service.dart';
import '../../services/streak_service.dart';
import '../../services/app_localizations_provider.dart';
import '../../models/game_state.dart';
import '../../models/quiz_progress.dart';
import '../../widgets/quiz_question_widgets.dart' hide QuizQuestion, QuestionType;

class LessonQuizScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final VoidCallback? onQuizCompleted;

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
  LessonQuizInfo? quizInfo;
  bool _initialized = false;
  bool _isQuizLocked = false;
  bool _quizFinished = false;

  // Score required to unlock the next quiz.
  static const int _unlockThreshold = 100;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await QuizProgressDatabaseService.initializeDatabase();
    if (!mounted) return;
    setState(() {
      questionsFuture = _loadQuestionsAsync();
      _initialized = true;
    });
  }

  Future<List<QuizQuestion>> _loadQuestionsAsync() async {
    try {
      final l10nProvider = context.read<AppLocalizationsProvider>();
      final language = l10nProvider.currentLanguage;

      quizInfo = await const LessonQuizService().getLessonInfo(
        widget.lessonId,
        language: language,
      );
      if (!mounted) return [];

      if (quizInfo != null) {
        _isQuizLocked = await _checkIfQuizLocked(
          quizInfo!.sectionId,
          widget.lessonId.toString(),
          language,
        );
        if (!mounted) return [];
      }

      final loadedQuestions =
          await const LessonQuizService().getRandomQuestionsForLesson(
        widget.lessonId,
        count: 5,
        language: language,
      );
      if (!mounted) return [];

      questions = loadedQuestions;
      return loadedQuestions;
    } catch (e) {
      print('Error loading questions: $e');
      return [];
    }
  }

  Future<bool> _checkIfQuizLocked(
    String sectionId,
    String quizId,
    String language,
  ) async {
    try {
      final sections =
          await const QuizService().getAllSections(language: language);
      final sectionIndex =
          sections.indexWhere((s) => s.id == sectionId);
      if (sectionIndex == -1) return true;

      final section = sections[sectionIndex];
      final quizIndex =
          section.lessons.indexWhere((q) => q.id == quizId);
      if (quizIndex == -1) return true;

      final allProgress =
          await QuizProgressDatabaseService.getAllProgress();

      // First quiz of the first section is always unlocked.
      if (quizIndex == 0) {
        if (sectionIndex == 0) return false;

        // First quiz of a later section: all quizzes in the previous
        // section must have been passed at >= _unlockThreshold.
        final previousSection = sections[sectionIndex - 1];
        for (final prevSectionQuiz in previousSection.lessons) {
          final prevProgress = _findProgress(
            allProgress,
            prevSectionQuiz.id,
            previousSection.id,
          );
          if (prevProgress == null ||
              prevProgress.score < _unlockThreshold) {
            return true;
          }
        }
        return false;
      }

      // Any other quiz: all preceding quizzes in the same section must
      // have been passed at >= _unlockThreshold.
      for (int i = 0; i < quizIndex; i++) {
        final prevQuizId = section.lessons[i].id;
        final prevProgress = _findProgress(
          allProgress,
          prevQuizId,
          sectionId,
        );
        if (prevProgress == null ||
            prevProgress.score < _unlockThreshold) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking quiz lock: $e');
      return true;
    }
  }

  /// Null-safe helper — avoids the try/catch firstWhere pattern.
  QuizProgress? _findProgress(
    List<QuizProgress> allProgress,
    String quizId,
    String sectionId,
  ) {
    for (final p in allProgress) {
      if (p.quizId == quizId && p.sectionId == sectionId) return p;
    }
    return null;
  }

  // ── Called by QuestionWidgetFactory widgets ──────────────
  Future<void> _answerQuestion(bool correct) async {
    if (showFeedback) return;

    setState(() {
      isCorrect = correct;
      showFeedback = true;
      if (correct) correctAnswers++;
    });

    if (quizInfo != null && !_isQuizLocked && mounted) {
      if (correct) {
        final question = questions[currentQuestionIndex];
        final isAlreadyRewarded =
            await QuizProgressDatabaseService.isQuestionRewarded(
          quizInfo!.sectionId,
          widget.lessonId.toString(),
          question.id,
        );
        if (!isAlreadyRewarded) {
          const coinsPerCorrectAnswer = 4;
          context
              .read<GameState>()
              .awardQuizQuestionCoins(coinsPerCorrectAnswer);
          await QuizProgressDatabaseService.markQuestionAsRewarded(
            quizInfo!.sectionId,
            widget.lessonId.toString(),
            question.id,
          );
          _showCoinRewardNotification(coinsPerCorrectAnswer);
        }
      } else {
        const coinsPerWrongAnswer = 2;
        context.read<GameState>().spendCoins(coinsPerWrongAnswer);
        _showCoinPenaltyNotification(coinsPerWrongAnswer);
      }
    }
  }

  void _showCoinRewardNotification(int coins) {
    final l10nProvider = context.read<AppLocalizationsProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        margin:
            const EdgeInsets.only(bottom: 160, left: 16, right: 16),
        backgroundColor: const Color(0xFF4CAF50),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on,
                color: Color(0xFFFFD700), size: 20),
            const SizedBox(width: 8),
            Text(
              l10nProvider.translate('quizCoinReward',
                  replacements: {'coins': '$coins'}),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showCoinPenaltyNotification(int coins) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin:
            const EdgeInsets.only(bottom: 160, left: 16, right: 16),
        backgroundColor: const Color(0xFFE53935),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_circle,
                color: Color(0xFFFFCDD2), size: 20),
            const SizedBox(width: 8),
            Text(
              '-$coins coins',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
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
        isCorrect = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final score =
        ((correctAnswers / questions.length) * 100).toInt();
    final l10nProvider = context.read<AppLocalizationsProvider>();
    setState(() => _quizFinished = true);

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
                  fontSize: 32, fontWeight: FontWeight.bold),
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
                        const Icon(Icons.lock,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10nProvider
                                .translate('quizLockedNoCoins'),
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
                        const Icon(Icons.info,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10nProvider
                                .translate('quizLockedNoProgress'),
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[700]),
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
              await _saveAndClose();
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.of(context).pop();
              });
            },
            child: Text(l10nProvider.translate('quizClose')),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveAndClose();
              Navigator.pop(dialogContext);
              _resetQuiz();
            },
            child: Text(l10nProvider.translate('quizRetry')),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndClose() async {
    if (quizInfo != null && !_isQuizLocked) {
      final score =
          ((correctAnswers / questions.length) * 100).toInt();
      await QuizProgressDatabaseService.updateScore(
        quizInfo!.sectionId,
        widget.lessonId.toString(),
        score,
      );
      final newStreak = await StreakService.onQuizCompleted();
      if (mounted) {
        context.read<GameState>().setCurrentStreak(newStreak);
      }
    }
    widget.onQuizCompleted?.call();
  }

  void _resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      correctAnswers = 0;
      showFeedback = false;
      isCorrect = null;
      _quizFinished = false;
      questionsFuture = _loadQuestionsAsync();
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  String _getScoreMessage(
      int score, AppLocalizationsProvider l10nProvider) {
    if (score >= 90) return l10nProvider.translate('quizExcellent');
    if (score >= 70) return l10nProvider.translate('quizGood');
    if (score >= 60) return l10nProvider.translate('quizOkay');
    return l10nProvider.translate('quizTryAgain');
  }

  Widget _buildTypeBadge(
      QuizQuestion question, AppLocalizationsProvider l10n) {
    final (key, color) = switch (question.questionType) {
      QuestionType.multipleChoice =>
        ('quizTypeMC',    const Color(0xFF2196F3)),
      QuestionType.trueFalse =>
        ('quizTypeTF',    const Color(0xFF9C27B0)),
      QuestionType.ordering =>
        ('quizTypeOrder', const Color(0xFFFF9800)),
      QuestionType.matching =>
        ('quizTypeMatch', const Color(0xFF009688)),
      QuestionType.dragDrop =>
        ('quizTypeDrag',  const Color(0xFFE91E63)),
    };

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.translate(key),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) questionsFuture = _loadQuestionsAsync();
    final l10nProvider = context.watch<AppLocalizationsProvider>();
    final language = l10nProvider.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nProvider.translate('quizQuestion',
                          replacements: {
                            'current': '${currentQuestionIndex + 1}',
                            'total': '${questions.length}',
                          }),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      l10nProvider.translate('quizCorrectCount',
                          replacements: {
                            'count': '$correctAnswers'
                          }),
                      style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _quizFinished
                      ? 1.0
                      : currentQuestionIndex / questions.length,
                  minHeight: 6,
                ),
                const SizedBox(height: 20),
                _buildTypeBadge(question, l10nProvider),
                const SizedBox(height: 10),
                Text(
                  question.question,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                KeyedSubtree(
                  key: ValueKey(
                      'q_${currentQuestionIndex}_${question.id}'),
                  child: QuestionWidgetFactory.build(
                    question: question,
                    showFeedback: showFeedback,
                    onAnswered: _answerQuestion,
                    language: language,
                  ),
                ),
                if (showFeedback) ...[
                  const SizedBox(height: 20),
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
                              ? l10nProvider
                                  .translate('quizAnswerCorrect')
                              : l10nProvider
                                  .translate('quizAnswerWrong'),
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
                          l10nProvider.translate('quizExplanation',
                              replacements: {
                                'text': question.explanation
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
                          : l10nProvider
                              .translate('quizNextQuestion'),
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