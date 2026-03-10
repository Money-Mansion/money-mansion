import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../my_flutter_app_icons.dart';
import '../screens/settings_screen.dart';

class TopBar extends StatelessWidget {
  final GameState gameState;

  const TopBar({
    super.key,
    required this.gameState,
  });

  String _formatMoney(double money) {
    if (money % 1 == 0) {
      return money.toStringAsFixed(0);
    }
    return money.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gameState, // listens to coins/money changes
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(gameState: gameState),
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

              // Coins
              _ResourceDisplay(
                icon: MyFlutterApp.coins,
                color: Colors.orange,
                value: gameState.coins.toString(),
              ),

              // Money (real-world financial tracking)
              _ResourceDisplay(
                icon: MyFlutterApp.money,
                color: Colors.green,
                value: _formatMoney(gameState.money),
              ),

              // Chrumka — shows real earned chrumka count (not coins)
              _ResourceDisplay(
                icon: MyFlutterApp.chrumka,
                color: const Color.fromARGB(0, 220, 100, 180),
                value: gameState.chrumka.toString(),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B5B8C),
            ),
          ),
        ],
      ),
    );
  }
}