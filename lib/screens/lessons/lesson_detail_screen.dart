import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../services/app_localizations_provider.dart';
import 'lesson_content_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  final String categoryTitle;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.read<AppLocalizationsProvider>();
    final isSk = l10n.currentLanguage == 'sk';
    final hasSlides = lessonSlides.containsKey(lesson.id);

    if (hasSlides) {
      return LessonContentScreen(
        lesson: lesson,
        categoryTitle: categoryTitle,
        isSlovak: isSk,
      );
    }

    return _ComingSoonScreen(lesson: lesson, categoryTitle: categoryTitle, isSk: isSk);
  }
}

// ─────────────────────────────────────────────
// COMING SOON SCREEN
// ─────────────────────────────────────────────

class _ComingSoonScreen extends StatelessWidget {
  final Lesson lesson;
  final String categoryTitle;
  final bool isSk;

  const _ComingSoonScreen({
    required this.lesson,
    required this.categoryTitle,
    required this.isSk,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor =
        Theme.of(context).textTheme.labelMedium?.color?.withOpacity(0.7) ??
            Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lesson.title),
            Text(
              categoryTitle,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚧', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              Text(
                lesson.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF5A623).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Text(
                  isSk
                      ? 'Táto lekcia sa pripravuje. Príď čoskoro! 🌱'
                      : 'This lesson is being prepared. Check back soon! 🌱',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}