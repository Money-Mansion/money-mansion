import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../my_flutter_app_icons.dart';
import '../screens/settings_screen.dart';
import '../services/tutorial_provider.dart';
import '../services/streak_service.dart';
import 'tutorial_target.dart';

class TopBar extends StatefulWidget {
  final GameState gameState;

  const TopBar({
    super.key,
    required this.gameState,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String _formatMoney(double money) {
    if (money % 1 == 0) {
      return money.toStringAsFixed(0);
    }
    return money.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.gameState, // listens to coins/money/streak changes
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8D4F0),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(30)),
            border: Border.all(
              color: const Color(0xFFB8A8D8),
              width: 3,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Settings icon
              TutorialTarget(
                id: 'open_settings',
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<TutorialProvider>()
                        .registerAction('open_settings');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          gameState: widget.gameState,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700] ?? Colors.grey,
                        BlendMode.srcATop,
                      ),
                      child: MyFlutterApp.settings,
                    ),
                  ),
                ),
              ),

              // Coins
              _ResourceDisplay(
                icon: MyFlutterApp.kojn,
                color: const Color.fromARGB(62, 255, 153, 0),
                value: widget.gameState.coins.toString(),
              ),

              // Money (real-world financial tracking)
              _ResourceDisplay(
                icon: MyFlutterApp.shop,
                color: const Color.fromARGB(0, 76, 175, 79),
                value: _formatMoney(widget.gameState.money),
              ),

              // Streak counter — shows current daily quiz streak (no bubble)
              _StreakDisplay(
                value: widget.gameState.currentStreak.toString(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResourceDisplay extends StatelessWidget {
  final Widget icon;
  final Color color;
  final String value;

  const _ResourceDisplay({
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        border: Border.all(
          color: const Color(0xFFB8A8D8),
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcATop,
              ),
              child: icon,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: _calculateFontSize(value),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B5B8C),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate responsive font size based on value length
  double _calculateFontSize(String value) {
    final length = value.length;
    if (length <= 3) {
      return 18;
    } else if (length <= 5) {
      return 16;
    } else if (length <= 7) {
      return 14;
    } else if (length <= 9) {
      return 12;
    } else {
      return 10;
    }
  }
}

class _StreakDisplay extends StatelessWidget {
  final String value;

  const _StreakDisplay({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department,
          color: Color(0xFF9575CD),
          size: 24,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9575CD),
          ),
        ),
      ],
    );
  }
}
