import 'package:flutter/material.dart';
import '../models/quiz_progress.dart';

class QuizProgressCircle extends StatelessWidget {
  final String title;
  final QuizStatus status;
  final int score;

  const QuizProgressCircle({
    super.key,
    required this.title,
    required this.status,
    this.score = 0,
  });

  Color _getStatusColor() {
    switch (status) {
      case QuizStatus.excellent:
        return const Color(0xFF4CAF50); // Green (zelený - 90%+)
      case QuizStatus.good:
        return const Color(0xFFFFC107); // Yellow (žltý - 60%-89%)
      case QuizStatus.poor:
        return const Color(0xFFF44336); // Red (červený - <60%)
      case QuizStatus.notDone:
        return const Color(0xFFBDBDBD); // Gray (sivý - neurobený)
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case QuizStatus.excellent:
        return Icons.check;
      case QuizStatus.good:
        return Icons.check;
      case QuizStatus.poor:
        return Icons.check;
      case QuizStatus.notDone:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$title${status != QuizStatus.notDone ? ' - ${score}%' : ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getStatusIcon(),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 85,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
