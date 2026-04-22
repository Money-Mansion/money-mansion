import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_progress.dart';
import '../services/app_localizations_provider.dart';

class QuizProgressCircle extends StatelessWidget {
  final String title;
  final QuizStatus status;
  final int score;
  final bool locked;
  final Color sectionColor;

  const QuizProgressCircle({
    super.key,
    required this.title,
    required this.status,
    this.score = 0,
    this.locked = false,
    this.sectionColor = const Color(0xFFBDBDBD),
  });

  Color _getCircleColor() {
    // Always use section color, only icon changes based on status
    return sectionColor;
  }

  IconData _getStatusIcon() {
    if (locked) {
      return Icons.lock;
    }
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
    final loc = Provider.of<AppLocalizationsProvider>(context, listen: false);
    final lockedLabel = loc.translate('locked');

    return Tooltip(
      message: locked 
        ? '$title - $lockedLabel' 
        : '$title${status != QuizStatus.notDone ? ' - ${score}%' : ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _getCircleColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getCircleColor().withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: locked ? Colors.grey[700] : Colors.white,
                    size: 32,
                  ),
                  if (locked)
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[600]!,
                          width: 2,
                        ),
                      ),
                    ),
                ],
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