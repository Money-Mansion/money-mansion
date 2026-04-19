import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../services/lesson_service.dart';
import '../../services/app_localizations_provider.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final categories =
        const LessonService().getCategories(language: l10n.currentLanguage);
    final isSk = l10n.currentLanguage == 'sk';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: const Color(0xFFF5A623),
            title: Text(
              isSk ? 'Lekcie' : 'Lessons',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return _UnitSection(
                  category: category,
                  unitNumber: index + 1,
                  isSk: isSk,
                );
              },
              childCount: categories.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── UNIT SECTION ────────────────────────────────────────────────────────────

class _UnitSection extends StatelessWidget {
  final LessonCategory category;
  final int unitNumber;
  final bool isSk;

  const _UnitSection({
    required this.category,
    required this.unitNumber,
    required this.isSk,
  });

  // Cycle through distinct accent colors per unit
  static const _unitColors = [
    Color(0xFFF5A623), // amber
    Color(0xFF4CAF50), // green
    Color(0xFF2196F3), // blue
    Color(0xFF9C27B0), // purple
    Color(0xFFE91E63), // pink
    Color(0xFF009688), // teal
    Color(0xFFFF5722), // deep orange
    Color(0xFF3F51B5), // indigo
    Color(0xFF795548), // brown
    Color(0xFF00BCD4), // cyan
  ];

  Color get _accentColor => _unitColors[(unitNumber - 1) % _unitColors.length];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Unit header banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSk ? 'Sekcia $unitNumber' : 'Unit $unitNumber',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.lessons.length} ${isSk ? 'lekcií' : 'lessons'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
        ),

        // Lesson path nodes
        _LessonPath(
          lessons: category.lessons,
          categoryTitle: category.title,
          accentColor: _accentColor,
          unitNumber: unitNumber,
        ),
      ],
    );
  }
}

// ─── LESSON PATH (zigzag nodes) ──────────────────────────────────────────────

class _LessonPath extends StatelessWidget {
  final List<Lesson> lessons;
  final String categoryTitle;
  final Color accentColor;
  final int unitNumber;

  const _LessonPath({
    required this.lessons,
    required this.categoryTitle,
    required this.accentColor,
    required this.unitNumber,
  });

  // Horizontal offsets for the zigzag path
  static const _zigzag = [0.5, 0.35, 0.5, 0.65, 0.5, 0.35, 0.65];

  // Icons per lesson index cycling
  static const _nodeIcons = [
    Icons.star_rounded,
    Icons.menu_book_rounded,
    Icons.lightbulb_rounded,
    Icons.check_circle_rounded,
    Icons.emoji_events_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    const double nodeSize = 72.0;
    const double rowHeight = 100.0;

    return SizedBox(
      height: rowHeight * lessons.length + 20,
      child: Stack(
        children: [
          // Draw connector lines between nodes
          ...List.generate(lessons.length - 1, (i) {
            final fromX = _zigzag[i % _zigzag.length];
            final toX = _zigzag[(i + 1) % _zigzag.length];
            final fromY = i * rowHeight + nodeSize / 2 + 10;
            final toY = (i + 1) * rowHeight + nodeSize / 2 + 10;

            return CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  rowHeight * lessons.length + 20),
              painter: _DottedLinePainter(
                fromX: MediaQuery.of(context).size.width * fromX,
                fromY: fromY,
                toX: MediaQuery.of(context).size.width * toX,
                toY: toY,
                color: accentColor.withOpacity(0.25),
              ),
            );
          }),

          // Lesson nodes
          ...List.generate(lessons.length, (i) {
            final lesson = lessons[i];
            final xFraction = _zigzag[i % _zigzag.length];
            final isCompleted = false; // TODO: wire to progress service
            final isCurrent = i == 0;

            return Positioned(
              top: i * rowHeight + 10,
              left:
                  MediaQuery.of(context).size.width * xFraction - nodeSize / 2,
              child: _LessonNode(
                lesson: lesson,
                categoryTitle: categoryTitle,
                accentColor: accentColor,
                icon: _nodeIcons[i % _nodeIcons.length],
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                nodeSize: nodeSize,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── DOTTED LINE PAINTER ─────────────────────────────────────────────────────

class _DottedLinePainter extends CustomPainter {
  final double fromX, fromY, toX, toY;
  final Color color;

  const _DottedLinePainter({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dashLength = 6.0;
    const gapLength = 5.0;
    final total =
        ((toX - fromX) * (toX - fromX) + (toY - fromY) * (toY - fromY));
    final dist = total > 0 ? total / (total == 0 ? 1 : total) : 0;
    final dx = toX - fromX;
    final dy = toY - fromY;
    final len = (dx * dx + dy * dy) > 0
        ? (dx * dx + dy * dy) /
            ((dx * dx + dy * dy) > 0 ? (dx * dx + dy * dy) : 1)
        : 1.0;
    final length =
        (dx * dx + dy * dy > 0) ? (dx * dx + dy * dy).toDouble() : 1.0;
    final realLen = length > 0 ? length.toDouble() : 1.0;

    // Simple dashed line implementation
    final totalLen =
        (dx * dx + dy * dy > 0) ? ((dx * dx + dy * dy) as num).toDouble() : 1.0;
    final magnitude = totalLen > 0 ? totalLen : 1.0;
    // Use sqrt approximation
    double sqrtLen = 1.0;
    double val = (dx * dx + dy * dy).toDouble();
    if (val > 0) {
      sqrtLen = val;
      for (int k = 0; k < 20; k++) {
        sqrtLen = (sqrtLen + val / sqrtLen) / 2;
      }
    }

    final normX = dx / sqrtLen;
    final normY = dy / sqrtLen;

    double traveled = 0;
    bool drawing = true;

    while (traveled < sqrtLen) {
      final segLen = drawing ? dashLength : gapLength;
      final end = (traveled + segLen).clamp(0, sqrtLen);
      if (drawing) {
        canvas.drawLine(
          Offset(fromX + normX * traveled, fromY + normY * traveled),
          Offset(fromX + normX * end, fromY + normY * end),
          paint,
        );
      }
      traveled += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── LESSON NODE ─────────────────────────────────────────────────────────────

class _LessonNode extends StatelessWidget {
  final Lesson lesson;
  final String categoryTitle;
  final Color accentColor;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final double nodeSize;

  const _LessonNode({
    required this.lesson,
    required this.categoryTitle,
    required this.accentColor,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.nodeSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color iconColor;
    final Color borderColor;

    if (isCompleted) {
      bgColor = accentColor;
      iconColor = Colors.white;
      borderColor = accentColor.withOpacity(0.0);
    } else if (isCurrent) {
      bgColor = Colors.white;
      iconColor = accentColor;
      borderColor = accentColor;
    } else {
      bgColor = Colors.white;
      iconColor = Colors.grey[400]!;
      borderColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailScreen(
              lesson: lesson,
              categoryTitle: categoryTitle,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse ring for current lesson
          Container(
            width: nodeSize + (isCurrent ? 10 : 0),
            height: nodeSize + (isCurrent ? 10 : 0),
            decoration: isCurrent
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.15),
                  )
                : null,
            child: Center(
              child: Container(
                width: nodeSize,
                height: nodeSize,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: isCompleted
                          ? accentColor.withOpacity(0.4)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: isCompleted ? 14 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check_rounded, color: iconColor, size: 32)
                      : Icon(icon, color: iconColor, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 90,
            child: Text(
              lesson.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? accentColor : Colors.grey[600],
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
