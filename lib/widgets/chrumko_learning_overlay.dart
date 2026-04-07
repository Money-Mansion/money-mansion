import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/tutorial_provider.dart';
import '../services/lesson_service.dart';
import '../services/quiz_service.dart';
import '../services/quiz_progress_database_service.dart';
import '../models/lesson.dart';
import '../models/quiz_progress.dart';
import '../screens/lessons/lesson_category_screen.dart';
import '../screens/lessons/lesson_quiz_screen.dart';
import '../screens/quizes/quiz_section_screen.dart';
import 'quiz_progress_circle.dart';

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
  State<ChrumkoLearningOverlay> createState() =>
      _ChrumkoLearningOverlayState();
}

class _ChrumkoLearningOverlayState extends State<ChrumkoLearningOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _tabKeys = ['quizes', 'lessons'];

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
    final showReturnBox = tutorial.isActive &&
        tutorial.currentStep?.id == 'lessons_return';

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
            child: Column(
              children: [
                // Empty content area (TabBarView)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Quizes tab
                      _buildTabContent(l10n, 'quizes'),
                      // Lessons tab
                      _buildTabContent(l10n, 'lessons'),
                    ],
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
                          width: showReturnBox ? 148 : 48,
                          child: showReturnBox
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 6, 4, 6),
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 6,
                                    shadowColor:
                                        Colors.deepOrange.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: widget.onClose,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.deepOrange,
                                            width: 2.5,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_back_rounded,
                                              color: Colors.deepOrange,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                l10n.translate('back'),
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.deepOrange,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: widget.onClose,
                                  tooltip: l10n.translate('back'),
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
                              return Tab(
                                text: l10n.translate(key),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          width: showReturnBox ? 148 : 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    final categories = const LessonService().getCategories();

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _LessonCategoryCard(category: category, onClose: onClose);
        },
      ),
    );
  }
}

class _LessonCategoryCard extends StatelessWidget {
  final LessonCategory category;
  final VoidCallback onClose;

  const _LessonCategoryCard({
    required this.category,
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
          // Close the overlay before navigating
          onClose();
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
                      '${category.lessons.length} lekcií',
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

class _QuizzesTabState extends State<_QuizzesTab> {
  late Future<List<QuizSection>> sectionsFuture;
  late Future<List<QuizProgress>> allProgressFuture;
  String _lastLanguage = 'en';

  @override
  void initState() {
    super.initState();
    // Initialize with English by default
    sectionsFuture = const QuizService().getAllSections(language: 'en');
    allProgressFuture = QuizProgressDatabaseService.getAllProgress();
  }

  void _loadSectionsIfLanguageChanged(String currentLanguage) {
    if (_lastLanguage != currentLanguage) {
      _lastLanguage = currentLanguage;
      sectionsFuture = const QuizService().getAllSections(language: currentLanguage);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    
    // Update sections if language changed
    _loadSectionsIfLanguageChanged(l10n.currentLanguage);
    
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
              child: Text('Chyba pri načítaní kvízov: ${sectionsSnapshot.error}'),
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

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
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
                      // GridView with quiz circles
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: section.lessons.length,
                        itemBuilder: (context, quizIndex) {
                          final quiz = section.lessons[quizIndex];
                          final status = _getStatusForQuiz(progressList, quiz.id);
                          final score = _getScoreForQuiz(progressList, quiz.id);

                          return GestureDetector(
                            onTap: () {
                              final lessonId = int.tryParse(quiz.id) ?? 1001;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonQuizScreen(
                                    lessonId: lessonId,
                                    lessonTitle: quiz.name,
                                  ),
                                ),
                              ).then((_) {
                                // Close overlay after returning from quiz
                                widget.onClose();
                              });
                            },
                            child: QuizProgressCircle(
                              title: quiz.name,
                              status: status,
                              score: score,
                            ),
                          );
                        },
                      ),
                    ],
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
          onClose();
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
                child: const Icon(Icons.quiz_rounded,
                    color: Color(0xFFFF9800)),
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
