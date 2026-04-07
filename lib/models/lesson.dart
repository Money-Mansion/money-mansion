class Lesson {
  final String id;
  final String title;
  final String? content;
  final int? quizLessonId; // Map to quiz_database lessonId (e.g., 1001, 1002, etc.)

  const Lesson({
    required this.id,
    required this.title,
    this.content,
    this.quizLessonId,
  });
}

class LessonCategory {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const LessonCategory({
    required this.id,
    required this.title,
    required this.lessons,
  });
}
