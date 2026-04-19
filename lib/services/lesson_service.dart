import '../config/lesson_localizations.dart';
import '../config/lessons_config.dart';
import '../models/lesson.dart';

class LessonService {
  const LessonService();

  List<LessonCategory> getCategories({String language = 'sk'}) {
    if (language == 'sk') {
      return LESSON_CATEGORIES;
    }

    return LESSON_CATEGORIES.map((category) {
      return LessonCategory(
        id: category.id,
        title: lessonCategoryTitlesEn[category.id] ?? category.title,
        lessons: category.lessons
            .map(
              (lesson) => Lesson(
                id: lesson.id,
                title: lessonTitlesEn[lesson.id] ?? lesson.title,
                content: lesson.content,
                quizLessonId: lesson.quizLessonId,
              ),
            )
            .toList(growable: false),
      );
    }).toList(growable: false);
  }

  LessonCategory? findCategoryById(String id, {String language = 'sk'}) {
    for (final category in getCategories(language: language)) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  Lesson? findLessonById(
    String categoryId,
    String lessonId, {
    String language = 'sk',
  }) {
    final category = findCategoryById(categoryId, language: language);
    if (category == null) return null;
    for (final lesson in category.lessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }
}
