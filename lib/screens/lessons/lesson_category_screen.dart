import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../services/lesson_progress_database_service.dart';
import 'lesson_detail_screen.dart';

class LessonCategoryScreen extends StatefulWidget {
  final LessonCategory category;

  const LessonCategoryScreen({super.key, required this.category});

  @override
  State<LessonCategoryScreen> createState() => _LessonCategoryScreenState();
}

class _LessonCategoryScreenState extends State<LessonCategoryScreen> {
  Set<int> _openedIds = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final ids = await LessonProgressDatabaseService.getAllOpenedLessonIds();
    if (mounted) setState(() => _openedIds = ids);
  }

  bool _isOpened(Lesson lesson) =>
      lesson.quizLessonId != null && _openedIds.contains(lesson.quizLessonId);

  int get _completedCount =>
      widget.category.lessons.where(_isOpened).length;

  int get _totalCount => widget.category.lessons.length;

  double get _progressFraction =>
      _totalCount > 0 ? _completedCount / _totalCount : 0.0;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_progressFraction * 100).round();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 232, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 130, 98, 206),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white),
            ),
            Text(
              '$_completedCount / $_totalCount lessons · $progressPercent%',
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: ClipRRect(
            child: LinearProgressIndicator(
              value: _progressFraction,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: widget.category.lessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final lesson = widget.category.lessons[index];
          final opened = _isOpened(lesson);

          return Material(
            color: Colors.white,
            elevation: opened ? 0 : 1,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonDetailScreen(
                      categoryTitle: widget.category.title,
                      lesson: lesson,
                    ),
                  ),
                );
                _loadProgress();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: opened
                        ? const Color(0xFF4CAF50).withOpacity(0.4)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: opened
                          ? const Color(0xFF4CAF50).withOpacity(0.12)
                          : const Color.fromARGB(255, 165, 134, 206).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: opened
                          ? const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF4CAF50), size: 22)
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 111, 71, 185),
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: opened
                          ? Colors.grey[700]
                          : const Color(0xFF1A1A1A),
                      decoration: opened
                          ? TextDecoration.none
                          : null,
                    ),
                  ),
                  subtitle: opened
                      ? Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : null,
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}