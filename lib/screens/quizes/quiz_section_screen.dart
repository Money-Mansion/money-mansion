import 'package:flutter/material.dart';
import '../../services/quiz_service.dart';
import '../../services/quiz_progress_database_service.dart';
import '../../models/quiz_progress.dart';
import '../../widgets/quiz_progress_circle.dart';
import '../lessons/lesson_quiz_screen.dart';

class QuizSectionScreen extends StatefulWidget {
  final QuizSection section;

  const QuizSectionScreen({super.key, required this.section});

  @override
  State<QuizSectionScreen> createState() => _QuizSectionScreenState();
}

class _QuizSectionScreenState extends State<QuizSectionScreen> {
  late Future<List<QuizProgress>> progressFuture;

  @override
  void initState() {
    super.initState();
    progressFuture = QuizProgressDatabaseService.getSectionProgress(widget.section.id);
  }

  QuizStatus _getStatusForQuiz(
    List<QuizProgress> progressList,
    String quizId,
  ) {
    try {
      final progress = progressList.firstWhere(
        (p) => p.quizId == quizId,
      );
      return progress.getStatus();
    } catch (e) {
      return QuizStatus.notDone;
    }
  }

  int _getScoreForQuiz(
    List<QuizProgress> progressList,
    String quizId,
  ) {
    try {
      final progress = progressList.firstWhere(
        (p) => p.quizId == quizId,
      );
      return progress.score;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.name),
      ),
      body: FutureBuilder<List<QuizProgress>>(
        future: progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Chyba: ${snapshot.error}'),
                ],
              ),
            );
          }

          final progressList = snapshot.data ?? [];
          final lessons = widget.section.lessons;

          if (lessons.isEmpty) {
            return const Center(
              child: Text('Žiadne kvízy v tejto sekcii'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final quiz = lessons[index];
              final status = _getStatusForQuiz(progressList, quiz.id);
              final score = _getScoreForQuiz(progressList, quiz.id);

              return GestureDetector(
                onTap: () {
                  // Navigate to quiz gameplay screen
                  final lessonId = int.tryParse(quiz.id) ?? int.parse(quiz.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonQuizScreen(
                        lessonId: lessonId,
                        lessonTitle: quiz.name,
                      ),
                    ),
                  ).then((_) {
                    // Refresh progress after returning from quiz
                    setState(() {
                      progressFuture = QuizProgressDatabaseService.getSectionProgress(
                        widget.section.id,
                      );
                    });
                  });
                },
                child: QuizProgressCircle(
                  title: quiz.name,
                  status: status,
                  score: score,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
