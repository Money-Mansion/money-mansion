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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: List.generate(
                lessons.length,
                (index) {
                  final quiz = lessons[index];
                  final status = _getStatusForQuiz(progressList, quiz.id);
                  final score = _getScoreForQuiz(progressList, quiz.id);
                  
                  // Create zigzag effect: alternate between left, center, right
                  final horizontalOffset = index % 2 == 0 ? -30.0 : 30.0;

                  return Column(
                    children: [
                      // Draw connecting line between circles (except for first item)
                      if (index > 0)
                        SizedBox(
                          height: 40,
                          child: CustomPaint(
                            painter: _PathPainter(),
                            size: const Size(double.infinity, 40),
                          ),
                        ),
                      Transform.translate(
                        offset: Offset(horizontalOffset, 0),
                        child: GestureDetector(
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw curved connector line from top center to bottom center
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.cubicTo(
      size.width / 2,
      size.height / 2,
      size.width / 2,
      size.height / 2,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
