import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tabKey == 'quizes'
                ? Icons.quiz_outlined
                : Icons.school_outlined,
            size: 48,
            color: Colors.deepPurple.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate(tabKey),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
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
