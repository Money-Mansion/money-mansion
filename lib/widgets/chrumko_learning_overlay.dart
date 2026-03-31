import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/lesson_service.dart';
import '../models/lesson.dart';
import '../screens/lessons/lesson_category_screen.dart';

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
                        // Back button (bottom-left)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: widget.onClose,
                          tooltip: l10n.translate('back'),
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
                        // Spacer to balance back button
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
        ],
      ),
    );
  }

  /// Builds a placeholder content widget for a tab.
  Widget _buildTabContent(AppLocalizationsProvider l10n, String tabKey) {
    if (tabKey == 'lessons') {
      return const _LessonsTab();
    }
    // Placeholder for quizzes
    return _PlaceholderTab(
      icon: Icons.quiz_outlined,
      title: l10n.translate(tabKey),
      subtitle: 'Coming soon...',
    );
  }
}

class _LessonsTab extends StatelessWidget {
  const _LessonsTab();

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
          return _LessonCategoryCard(category: category);
        },
      ),
    );
  }
}

class _LessonCategoryCard extends StatelessWidget {
  final LessonCategory category;

  const _LessonCategoryCard({required this.category});

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
