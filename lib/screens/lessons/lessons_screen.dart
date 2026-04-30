import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../services/lesson_service.dart';
import '../../services/app_localizations_provider.dart';
import '../../services/lesson_progress_database_service.dart';
import 'lesson_category_screen.dart';

const _purple = Color(0xFF6B5B8C);
const _purpleLight = Color(0xFFB8A8D8);
const _purpleBg = Color(0xFFE8D4F0);

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  Set<int> _openedLessonIds = {};
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
        _openedLessonIds = ids;
        _progressLoaded = true;
      });
    }
  }

  int _completedCount(LessonCategory category) {
    return category.lessons
        .where((l) =>
            l.quizLessonId != null &&
            _openedLessonIds.contains(l.quizLessonId))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final categories =
        const LessonService().getCategories(language: l10n.currentLanguage);
    final isSk = l10n.currentLanguage == 'sk';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: _purple,
        elevation: 0,
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
      body: ListView.separated(
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
                    builder: (_) => LessonCategoryScreen(category: category),
                  ),
                );
                _loadProgress();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                    style:
                                        TextStyle(color: Colors.grey[400])),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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

                    // Right side: badge or arrow
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