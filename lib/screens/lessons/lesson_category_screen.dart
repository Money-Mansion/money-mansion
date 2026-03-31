import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import 'lesson_detail_screen.dart';

class LessonCategoryScreen extends StatelessWidget {
  final LessonCategory category;

  const LessonCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: category.lessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final lesson = category.lessons[index];
          return Material(
            color: Colors.white,
            elevation: 1,
            borderRadius: BorderRadius.circular(10),
            child: ListTile(
              title: Text(
                lesson.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonDetailScreen(
                      categoryTitle: category.title,
                      lesson: lesson,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
