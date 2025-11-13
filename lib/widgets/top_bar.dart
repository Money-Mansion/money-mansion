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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border(
          bottom: BorderSide(color: Colors.grey[600]!, width: 2),
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
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.grey[300],
                    appBar: AppBar(
                      title: const Text('Settings'),
                      backgroundColor: Colors.grey[400],
                    ),
                    body: SettingsScreen(gameState: gameState),
                  ),
                ),
              );
            },
            child: Icon(
              MyFlutterApp.settings,
              size: 32,
              color: Colors.grey[700],
            ),
          ),
          
          // Coins
          _ResourceDisplay(
            icon: MyFlutterApp.coins,
            color: Colors.orange,
            value: gameState.coins.toString(),
          ),
          
          // Emeralds
          _ResourceDisplay(
            icon: MyFlutterApp.money,
            color: Colors.green,
            value: gameState.emeralds.toString(),
          ),
          
          // Date - Calendar icon
          _CalendarWidget(date: gameState.date),
        ],
      ),
    );
  }
}

class _ResourceDisplay extends StatelessWidget {
  final IconData icon;
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
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  final double date;

  const _CalendarWidget({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Header (month bar)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFE74C3C), // Červená ako v kalendároch
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: const Center(
              child: Text(
                'JUL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Day number
          Expanded(
            child: Center(
              child: Text(
                date.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
