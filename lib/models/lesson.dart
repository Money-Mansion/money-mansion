class Lesson {
  final String id;
  final String title;
  final String? content;

  const Lesson({
    required this.id,
    required this.title,
    this.content,
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
