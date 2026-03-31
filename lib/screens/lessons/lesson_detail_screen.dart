import 'package:flutter/material.dart';
import '../../models/lesson.dart';

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
    final content = (lesson.content ?? '').trim().isEmpty
        ? 'Obsah tejto lekcie pripravujeme.'
        : lesson.content!.trim();
    final secondaryTextColor =
        Theme.of(context).textTheme.labelMedium?.color?.withOpacity(0.8) ??
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
