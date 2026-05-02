import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/tutorial_provider.dart';
import '../services/lesson_service.dart';
import '../services/quiz_service.dart';
import '../services/quiz_progress_database_service.dart';
import '../services/lesson_progress_database_service.dart';
import '../models/lesson.dart';
import '../models/quiz_progress.dart';
import '../screens/lessons/lesson_category_screen.dart';
import '../screens/lessons/lesson_quiz_screen.dart';
import '../screens/quizes/quiz_section_screen.dart';
import 'quiz_progress_circle.dart';
import 'tutorial_target.dart';

const _purple = Color(0xFF6B5B8C);
const _purpleLight = Color(0xFFB8A8D8);
const _purpleBg = Color(0xFFE8D4F0);

class ChrumkoLearningOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const ChrumkoLearningOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<ChrumkoLearningOverlay> createState() => _ChrumkoLearningOverlayState();
}

class _ChrumkoLearningOverlayState extends State<ChrumkoLearningOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _tabKeys = ['lessons', 'quizes'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final tutorial = context.watch<TutorialProvider>();
    final lockLearningContent =
        tutorial.isActive && tutorial.currentStep?.id == 'lessons_return';

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.grey.withOpacity(0.6)),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: lockLearningContent,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _LessonsTab(onClose: widget.onClose),
                          _QuizzesTab(onClose: widget.onClose),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: TutorialTarget(
                              id: 'close_lessons',
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: widget.onClose,
                                tooltip: l10n.translate('back'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBar(
                              controller: _tabController,
                              labelColor: _purple,
                              unselectedLabelColor: Colors.grey[600],
                              indicatorColor: _purple,
                              indicatorWeight: 3,
                              tabs: _tabKeys.map((key) {
                                final targetId = key == 'quizes'
                                    ? 'tab_quizes'
                                    : 'tab_lessons';
                                return TutorialTarget(
                                  id: targetId,
                                  child: Tab(text: l10n.translate(key)),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── LESSONS TAB ───────────────────────────────────────────────────────────────

class _LessonsTab extends StatefulWidget {
  final VoidCallback onClose;
  const _LessonsTab({required this.onClose});

  @override
  State<_LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<_LessonsTab> {
  Set<int> _openedIds = {};
  bool _progressLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final ids = await LessonProgressDatabaseService.getAllOpenedLessonIds();
    if (mounted) {
      setState(() {
        _openedIds = ids;
        _progressLoaded = true;
      });
    }
  }

  int _completedCount(LessonCategory category) {
    return category.lessons
        .where((l) =>
            l.quizLessonId != null && _openedIds.contains(l.quizLessonId))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final categories =
        const LessonService().getCategories(language: l10n.currentLanguage);
    final isSk = l10n.currentLanguage == 'sk';

    return Container(
      color: const Color(0xFFF5F0E8),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final completed = _completedCount(category);
          final total = category.lessons.length;
          final fraction =
              _progressLoaded && total > 0 ? completed / total : 0.0;
          final percent = (fraction * 100).round();
          final isComplete = completed == total && total > 0;

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            elevation: 1,
            shadowColor: _purple.withOpacity(0.08),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LessonCategoryScreen(category: category),
                  ),
                );
                _loadProgress();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Purple icon box
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _purpleBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isComplete
                          ? const Icon(Icons.check_circle_rounded,
                              color: _purple, size: 26)
                          : const Icon(Icons.menu_book_rounded,
                              color: _purple, size: 24),
                    ),
                    const SizedBox(width: 14),

                    // Title + progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$total ${isSk ? 'lekcií' : 'lessons'}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                              if (_progressLoaded && completed > 0) ...[
                                const SizedBox(width: 6),
                                Text('·',
                                    style: TextStyle(
                                        color: Colors.grey[400])),
                                const SizedBox(width: 6),
                                Text(
                                  isComplete
                                      ? (isSk ? 'Hotovo ✓' : 'Done ✓')
                                      : '$percent%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isComplete
                                        ? const Color(0xFF4CAF50)
                                        : _purple,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_progressLoaded && completed > 0) ...[
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 4,
                                backgroundColor: _purpleBg,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  isComplete
                                      ? const Color(0xFF4CAF50)
                                      : _purple,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Right badge or arrow
                    if (_progressLoaded && completed > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : _purpleBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$completed/$total',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isComplete
                                ? const Color(0xFF4CAF50)
                                : _purple,
                          ),
                        ),
                      )
                    else
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── QUIZZES TAB ───────────────────────────────────────────────────────────────

class _QuizzesTab extends StatefulWidget {
  final VoidCallback onClose;

  const _QuizzesTab({required this.onClose});

  @override
  State<_QuizzesTab> createState() => _QuizzesTabState();
}

class _QuizzesTabState extends State<_QuizzesTab> with WidgetsBindingObserver {
  late Future<List<QuizSection>> sectionsFuture;
  late Future<List<QuizProgress>> allProgressFuture;
  late Future<Set<int>> openedLessonsFuture;
  String _lastLanguage = 'en';

  static const List<Color> sectionColors = [
    Color(0xFF7E57C2),
    Color(0xFF26A69A),
    Color(0xFFEC407A),
    Color(0xFFFFA726),
    Color(0xFF5C6BC0),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFF29B6F6),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sectionsFuture = const QuizService().getAllSections(language: 'en');
    allProgressFuture = QuizProgressDatabaseService.getAllProgress();
    openedLessonsFuture = LessonProgressDatabaseService.getAllOpenedLessonIds();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  void _refreshData() {
    setState(() {
      allProgressFuture = QuizProgressDatabaseService.getAllProgress();
      openedLessonsFuture =
          LessonProgressDatabaseService.getAllOpenedLessonIds();
    });
  }

  void _loadSectionsIfLanguageChanged(String currentLanguage) {
    if (_lastLanguage != currentLanguage) {
      _lastLanguage = currentLanguage;
      sectionsFuture =
          const QuizService().getAllSections(language: currentLanguage);
    }
  }

  QuizStatus _getStatusForQuiz(List<QuizProgress> progressList, String quizId) {
    try {
      return progressList.firstWhere((p) => p.quizId == quizId).getStatus();
    } catch (e) {
      return QuizStatus.notDone;
    }
  }

  int _getScoreForQuiz(List<QuizProgress> progressList, String quizId) {
    try {
      return progressList.firstWhere((p) => p.quizId == quizId).score;
    } catch (e) {
      return 0;
    }
  }

  int _getUnlockedQuizIndex(
    List<Quiz> quizzes,
    List<QuizProgress> progressList,
    Set<int> openedLessonIds,
  ) {
    for (int i = 0; i < quizzes.length; i++) {
      final quiz = quizzes[i];
      final lessonQuizId = int.tryParse(quiz.id) ?? -1;
      final lessonOpened = openedLessonIds.contains(lessonQuizId);
      final score = _getScoreForQuiz(progressList, quiz.id);
      final quizCompletedPerfectly = score == 100; // Require 100% to unlock next
      if (!lessonOpened || !quizCompletedPerfectly) {
        return lessonOpened ? i : i - 1 < 0 ? -1 : i - 1;
      }
    }
    return quizzes.length - 1;
  }

  bool _isSectionCompleted(
      List<Quiz> quizzes, List<QuizProgress> progressList) {
    if (quizzes.isEmpty) return false;
    for (final quiz in quizzes) {
      if (_getStatusForQuiz(progressList, quiz.id) == QuizStatus.notDone) {
        return false;
      }
    }
    return true;
  }

  int _getCurrentSectionIndex(
      List<QuizSection> sections, List<QuizProgress> progressList) {
    for (int i = 0; i < sections.length; i++) {
      if (!_isSectionCompleted(sections[i].lessons, progressList)) return i;
    }
    return sections.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    _loadSectionsIfLanguageChanged(l10n.currentLanguage);
    allProgressFuture = QuizProgressDatabaseService.getAllProgress();
    openedLessonsFuture = LessonProgressDatabaseService.getAllOpenedLessonIds();

    return Container(
      color: Colors.white,
      child: FutureBuilder<List<QuizSection>>(
        future: sectionsFuture,
        builder: (context, sectionsSnapshot) {
          if (sectionsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sectionsSnapshot.hasError) {
            return Center(
                child: Text(
                    'Chyba pri načítaní kvízov: ${sectionsSnapshot.error}'));
          }
          final sections = sectionsSnapshot.data ?? [];
          if (sections.isEmpty) {
            return const Center(child: Text('Žiadne kvízy k dispozícii'));
          }

          return FutureBuilder<List<QuizProgress>>(
            future: allProgressFuture,
            builder: (context, progressSnapshot) {
              final progressList = progressSnapshot.data ?? [];
              return FutureBuilder<Set<int>>(
                future: openedLessonsFuture,
                builder: (context, openedSnapshot) {
                  final openedLessonIds = openedSnapshot.data ?? {};
                  final currentSectionIndex =
                      _getCurrentSectionIndex(sections, progressList);
                  final currentSection = sections[currentSectionIndex];
                  final currentSectionColor =
                      sectionColors[currentSectionIndex % sectionColors.length];
                  final unlockedIndex = _getUnlockedQuizIndex(
                    currentSection.lessons,
                    progressList,
                    openedLessonIds,
                  );

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8, bottom: 12),
                            child: Text(
                              currentSection.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          if (currentSection.lessons.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Text(
                                '🚧 Quizzes coming soon...',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          else
                            Column(
                              children: List.generate(
                                currentSection.lessons.length,
                                (quizIndex) {
                                  final quiz =
                                      currentSection.lessons[quizIndex];
                                  final status = _getStatusForQuiz(
                                      progressList, quiz.id);
                                  final score = _getScoreForQuiz(
                                      progressList, quiz.id);
                                  final isLocked =
                                      quizIndex > unlockedIndex;
                                  final offsets = [
                                    -50.0, -30.0, -10.0, 10.0, 30.0, 50.0
                                  ];
                                  final horizontalOffset = offsets[
                                      (quiz.id.hashCode + quizIndex).abs() %
                                          offsets.length];
                                  final prevHorizontalOffset = quizIndex > 0
                                      ? offsets[(currentSection
                                                      .lessons[quizIndex - 1]
                                                      .id
                                                      .hashCode +
                                                  quizIndex -
                                                  1)
                                              .abs() %
                                          offsets.length]
                                      : 0.0;

                                  return Column(
                                    children: [
                                      if (quizIndex > 0)
                                        SizedBox(
                                          height: 40,
                                          child: CustomPaint(
                                            painter: _PathPainter(
                                              prevOffset:
                                                  prevHorizontalOffset,
                                              currOffset: horizontalOffset,
                                              color: currentSectionColor,
                                            ),
                                            size: const Size(
                                                double.infinity, 40),
                                          ),
                                        ),
                                      Transform.translate(
                                        offset: Offset(horizontalOffset, 0),
                                        child: GestureDetector(
                                          onTap: isLocked
                                              ? null
                                              : () {
                                                  final lessonId =
                                                      int.tryParse(
                                                              quiz.id) ??
                                                          1001;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LessonQuizScreen(
                                                        lessonId: lessonId,
                                                        lessonTitle:
                                                            quiz.name,
                                                        onQuizCompleted:
                                                            _refreshData,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          child: QuizProgressCircle(
                                            title: quiz.name,
                                            status: status,
                                            score: score,
                                            locked: isLocked,
                                            sectionColor:
                                                currentSectionColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final double prevOffset;
  final double currOffset;
  final Color color;

  _PathPainter({
    required this.prevOffset,
    required this.currOffset,
    this.color = const Color(0xFFBDBDBD),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2 + prevOffset, 0);
    path.cubicTo(
      size.width / 2 + prevOffset,
      size.height / 3,
      size.width / 2 + currOffset,
      size.height * 2 / 3,
      size.width / 2 + currOffset,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}