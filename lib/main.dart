import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'screens/game_screen.dart';
import 'services/item_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize item database
  await ItemDatabaseService.initializeDatabase();
  
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 227, 241),
      ),
      home: const GameScreen(),
    );
  }
}
