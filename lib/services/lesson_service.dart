import '../config/lessons_config.dart';
import '../models/lesson.dart';

class LessonService {
  const LessonService();

  List<LessonCategory> getCategories() {
    return LESSON_CATEGORIES;
  }

  LessonCategory? findCategoryById(String id) {
    for (final category in LESSON_CATEGORIES) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  Lesson? findLessonById(String categoryId, String lessonId) {
    final category = findCategoryById(categoryId);
    if (category == null) return null;
    for (final lesson in category.lessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }
}
