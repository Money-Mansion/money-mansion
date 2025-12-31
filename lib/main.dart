import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'services/goal_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize database on app startup
  await GoalDatabaseService.initializeDatabase();
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
