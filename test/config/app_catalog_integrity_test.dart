import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_mansion/config/items_config.dart';
import 'package:money_mansion/config/lessons_config.dart';
import 'package:money_mansion/config/room_components_config.dart';

void main() {
  group('app catalog integrity', () {
    test('shop items have unique ids and valid bundled assets', () {
      final ids = <String>{};

      for (final item in GAME_ITEMS) {
        expect(item.id.trim(), isNotEmpty, reason: 'Item has an empty id.');
        expect(
          ids.add(item.id),
          isTrue,
          reason: 'Duplicate item id: ${item.id}',
        );
        expect(item.name.trim(), isNotEmpty, reason: item.id);
        expect(item.nameEn.trim(), isNotEmpty, reason: item.id);
        expect(item.cost, greaterThanOrEqualTo(0), reason: item.id);
        expect(item.quantity, greaterThan(0), reason: item.id);
        expect(item.scale, greaterThan(0), reason: item.id);
        expect(
          File(item.texture).existsSync(),
          isTrue,
          reason: 'Missing texture for ${item.id}: ${item.texture}',
        );

        final hitboxId = item.hitboxId;
        if (hitboxId != null) {
          final hitboxPath = 'assets/hitboxes/$hitboxId.convexshape';
          expect(
            File(hitboxPath).existsSync(),
            isTrue,
            reason: 'Missing hitbox for ${item.id}: $hitboxPath',
          );
        }
      }
    });

    test('room components have unique ids and valid bundled assets', () {
      final ids = <String>{};

      for (final component in ROOM_COMPONENTS) {
        expect(component.id.trim(), isNotEmpty);
        expect(
          ids.add(component.id),
          isTrue,
          reason: 'Duplicate room component id: ${component.id}',
        );
        expect(component.name.trim(), isNotEmpty, reason: component.id);
        expect(component.nameEn.trim(), isNotEmpty, reason: component.id);
        expect(component.cost, greaterThanOrEqualTo(0), reason: component.id);
        expect(component.scale, greaterThan(0), reason: component.id);
        expect(
          File(component.texture).existsSync(),
          isTrue,
          reason: 'Missing texture for ${component.id}: ${component.texture}',
        );
      }
    });

    test('lesson ids are unique and quiz lesson ids exist in bundled quizzes',
        () {
      final categoryIds = <String>{};
      final lessonIds = <String>{};
      final quizLessonIds = _loadQuizLessonIds();

      for (final category in LESSON_CATEGORIES) {
        expect(category.id.trim(), isNotEmpty);
        expect(
          categoryIds.add(category.id),
          isTrue,
          reason: 'Duplicate lesson category id: ${category.id}',
        );
        expect(category.title.trim(), isNotEmpty, reason: category.id);
        expect(category.lessons, isNotEmpty, reason: category.id);

        for (final lesson in category.lessons) {
          expect(lesson.id.trim(), isNotEmpty, reason: category.id);
          expect(
            lessonIds.add(lesson.id),
            isTrue,
            reason: 'Duplicate lesson id: ${lesson.id}',
          );
          expect(lesson.title.trim(), isNotEmpty, reason: lesson.id);

          final quizLessonId = lesson.quizLessonId;
          if (quizLessonId != null) {
            expect(
              quizLessonIds,
              contains(quizLessonId),
              reason: 'Missing quiz data for lesson ${lesson.id}.',
            );
          }
        }
      }
    });

    test('quiz json files are parseable and internally consistent', () {
      final quizFiles = Directory('assets/quizes')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      expect(quizFiles, isNotEmpty);

      final questionIds = <String>{};
      for (final file in quizFiles) {
        final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final quizzes = data['quizzes'] as List<dynamic>;
        expect(quizzes, isNotEmpty, reason: file.path);

        for (final quiz in quizzes.cast<Map<String, dynamic>>()) {
          final lessons = quiz['lessons'] as List<dynamic>;
          expect(lessons, isNotEmpty, reason: file.path);

          for (final lesson in lessons.cast<Map<String, dynamic>>()) {
            expect(lesson['lessonId'], isA<int>(), reason: file.path);
            expect(lesson['lessonName'], isA<String>(), reason: file.path);
            final questions = lesson['questions'] as List<dynamic>;
            expect(questions, isNotEmpty, reason: file.path);

            for (final question in questions.cast<Map<String, dynamic>>()) {
              final questionId = question['questionId'];
              final questionType = question['questionType'];
              final prompt = question['question'];
              final options = question['options'] as List<dynamic>? ?? [];
              final correctAnswer = question['correctAnswer'];

              expect(questionId, isA<String>(), reason: file.path);
              expect(
                questionIds.add('$file::$questionId'),
                isTrue,
                reason: 'Duplicate question id $questionId in ${file.path}',
              );
              if (questionType != null) {
                expect(
                  questionType,
                  isA<String>(),
                  reason: '$file $questionId',
                );
              }
              expect(prompt, isA<String>(), reason: '$file $questionId');
              expect(
                (prompt as String).trim(),
                isNotEmpty,
                reason: '$file $questionId',
              );
              expect(
                correctAnswer,
                isA<int>(),
                reason: '$file $questionId',
              );

              if (questionType == 'multipleChoice' || options.isNotEmpty) {
                expect(
                  options.length,
                  greaterThan(1),
                  reason: '$file $questionId',
                );
                expect(
                  correctAnswer as int,
                  inInclusiveRange(0, options.length - 1),
                  reason: '$file $questionId',
                );
              }
            }
          }
        }
      }
    });
  });
}

Set<int> _loadQuizLessonIds() {
  final ids = <int>{};
  final quizFiles = Directory('assets/quizes')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'));

  for (final file in quizFiles) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final quizzes = data['quizzes'] as List<dynamic>;
    for (final quiz in quizzes.cast<Map<String, dynamic>>()) {
      final lessons = quiz['lessons'] as List<dynamic>;
      for (final lesson in lessons.cast<Map<String, dynamic>>()) {
        ids.add(lesson['lessonId'] as int);
      }
    }
  }

  return ids;
}
