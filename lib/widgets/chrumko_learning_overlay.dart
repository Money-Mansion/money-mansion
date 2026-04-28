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

/// ChrumkoLearningOverlay displays a modal overlay with Quizes and Lessons tabs.
///
/// Features:
/// - Bottom-tabbed interface (TabBar at bottom)
/// - Frosted/cloudy background (semi-transparent grey)
/// - Empty placeholder tabs ready for content
/// - Back button (bottom-left) to close overlay
/// - Localization-ready tab labels
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
          // Frosted background (click to close)
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          // Overlay panel with tabs at bottom
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Empty content area (TabBarView)
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: lockLearningContent,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Lessons tab
                          _buildTabContent(l10n, 'lessons'),
                          // Quizes tab
                          _buildTabContent(l10n, 'quizes'),
                        ],
                      ),
                    ),
                  ),
                  // Bottom bar with TabBar and back button
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
                          // TabBar (centered, flexible)
                          Expanded(
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.deepPurple,
                              unselectedLabelColor: Colors.grey[600],
                              indicatorColor: Colors.deepPurple,
                              indicatorWeight: 3,
                              tabs: _tabKeys.map((key) {
                                final targetId = key == 'quizes'
                                    ? 'tab_quizes'
                                    : 'tab_lessons';
                                return TutorialTarget(
                                  id: targetId,
                                  child: Tab(
                                    text: l10n.translate(key),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                          ),
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

  /// Builds a placeholder content widget for a tab.
  Widget _buildTabContent(AppLocalizationsProvider l10n, String tabKey) {
    if (tabKey == 'lessons') {
      return _LessonsTab(onClose: widget.onClose);
    }
    return _QuizzesTab(onClose: widget.onClose);
  }
}

class _LessonsTab extends StatelessWidget {
  final VoidCallback onClose;

  const _LessonsTab({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final categories =
        const LessonService().getCategories(language: l10n.currentLanguage);
    final isSk = l10n.currentLanguage == 'sk';

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _LessonCategoryCard(
            category: category,
            isSk: isSk,
            onClose: onClose,
          );
        },
      ),
    );
  }
}

class _LessonCategoryCard extends StatelessWidget {
  final LessonCategory category;
  final bool isSk;
  final VoidCallback onClose;

  const _LessonCategoryCard({
    required this.category,
    required this.isSk,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonCategoryScreen(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Color(0xFF7E57C2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.lessons.length} ${isSk ? 'lekcií' : 'lessons'}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

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

  // Section colors - each section gets a unique color
  static const List<Color> sectionColors = [
    Color(0xFF7E57C2), // Purple
    Color(0xFF26A69A), // Teal
    Color(0xFFEC407A), // Pink
    Color(0xFFFFA726), // Orange
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF66BB6A), // Green
    Color(0xFFAB47BC), // Deep Purple
    Color(0xFF29B6F6), // Light Blue
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
      print('✓ Quiz tab resumed - refreshing progress data');
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

  QuizStatus _getStatusForQuiz(
    List<QuizProgress> progressList,
    String quizId,
  ) {
    try {
      final progress = progressList.firstWhere(
        (p) => p.quizId == quizId,
      );
      return progress.getStatus();
    } catch (e) {
      return QuizStatus.notDone;
    }
  }

  int _getScoreForQuiz(
    List<QuizProgress> progressList,
    String quizId,
  ) {
    try {
      final progress = progressList.firstWhere(
        (p) => p.quizId == quizId,
      );
      return progress.score;
    } catch (e) {
      return 0;
    }
  }

  /// Determine which quiz index should be unlocked in a section.
  ///
  /// A quiz at [quizIndex] is unlocked only when BOTH conditions are true:
  ///   1. All previous quizzes are completed (existing sequential rule).
  ///   2. The lesson whose id matches the quiz has been opened at least once.
  ///
  /// Returns the index of the first quiz that fails either condition,
  /// or the last index when everything is done.
  int _getUnlockedQuizIndex(
    List<Quiz> quizzes,
    List<QuizProgress> progressList,
    Set<int> openedLessonIds,
  ) {
    for (int i = 0; i < quizzes.length; i++) {
      final quiz = quizzes[i];
      final lessonQuizId = int.tryParse(quiz.id) ?? -1;

      // Gate 1: lesson must have been opened
      final lessonOpened = openedLessonIds.contains(lessonQuizId);

      // Gate 2: quiz must not already be done (sequential unlock)
      final status = _getStatusForQuiz(progressList, quiz.id);
      final quizDone = status != QuizStatus.notDone;

      if (!lessonOpened || !quizDone) {
        // This is the first quiz that isn't fully cleared — unlock it only if
        // the lesson has been opened; otherwise lock it too.
        return lessonOpened ? i : i - 1 < 0 ? -1 : i - 1;
      }
    }
    // All quizzes done and lessons opened — stay on last one
    return quizzes.length - 1;
  }

  /// Check if all quizzes in a section are completed
  bool _isSectionCompleted(
      List<Quiz> quizzes, List<QuizProgress> progressList) {
    if (quizzes.isEmpty) return false;
    for (final quiz in quizzes) {
      final status = _getStatusForQuiz(progressList, quiz.id);
      if (status == QuizStatus.notDone) {
        return false;
      }
    }
    return true;
  }

  /// Determine which section the user should currently be on
  int _getCurrentSectionIndex(
      List<QuizSection> sections, List<QuizProgress> progressList) {
    for (int i = 0; i < sections.length; i++) {
      if (!_isSectionCompleted(sections[i].lessons, progressList)) {
        return i;
      }
    }
    return sections.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();

    _loadSectionsIfLanguageChanged(l10n.currentLanguage);

    // Refresh on every build to reflect latest completions immediately
    allProgressFuture = QuizProgressDatabaseService.getAllProgress();
    openedLessonsFuture =
        LessonProgressDatabaseService.getAllOpenedLessonIds();

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
              child:
                  Text('Chyba pri načítaní kvízov: ${sectionsSnapshot.error}'),
            );
          }

          final sections = sectionsSnapshot.data ?? [];

          if (sections.isEmpty) {
            return const Center(
              child: Text('Žiadne kvízy k dispozícii'),
            );
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
                  final currentSectionColor = sectionColors[
                      currentSectionIndex % sectionColors.length];
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
                      final section = currentSection;
                      final sectionColor = currentSectionColor;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 12),
                            child: Text(
                              section.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          if (section.lessons.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Text(
                                '🚧 Quizzes coming soon...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: List.generate(
                                section.lessons.length,
                                (quizIndex) {
                                  final quiz = section.lessons[quizIndex];
                                  final status = _getStatusForQuiz(
                                      progressList, quiz.id);
                                  final score =
                                      _getScoreForQuiz(progressList, quiz.id);
                                  // A quiz is locked if its index exceeds the
                                  // unlocked index (which already accounts for
                                  // whether the lesson has been opened).
                                  final isLocked = quizIndex > unlockedIndex;

                                  final offsets = [
                                    -50.0,
                                    -30.0,
                                    -10.0,
                                    10.0,
                                    30.0,
                                    50.0
                                  ];
                                  final horizontalOffset = offsets[
                                      (quiz.id.hashCode + quizIndex).abs() %
                                          offsets.length];

                                  final prevHorizontalOffset = quizIndex > 0
                                      ? offsets[(section
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
                                              prevOffset: prevHorizontalOffset,
                                              currOffset: horizontalOffset,
                                              color: sectionColor,
                                            ),
                                            size:
                                                const Size(double.infinity, 40),
                                          ),
                                        ),
                                      Transform.translate(
                                        offset: Offset(horizontalOffset, 0),
                                        child: GestureDetector(
                                          onTap: isLocked
                                              ? null
                                              : () {
                                                  final lessonId =
                                                      int.tryParse(quiz.id) ??
                                                          1001;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LessonQuizScreen(
                                                        lessonId: lessonId,
                                                        lessonTitle: quiz.name,
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
                                            sectionColor: sectionColor,
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

class _QuizSectionCard extends StatelessWidget {
  final QuizSection section;
  final VoidCallback onClose;

  const _QuizSectionCard({
    required this.section,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizSectionScreen(section: section),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz_rounded, color: Color(0xFFFF9800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${section.lessons.length} kvízov',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.deepPurple.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
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