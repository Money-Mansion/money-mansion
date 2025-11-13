import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MoneyMansionApp());
}

class MoneyMansionApp extends StatelessWidget {
  const MoneyMansionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Mansion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
      ),
      home: const GameScreen(),
    );
  }
}
