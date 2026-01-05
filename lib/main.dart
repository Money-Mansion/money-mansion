import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'screens/game_screen.dart';
import 'services/item_database_service.dart';
import 'config/items_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize item database and load defaults
  await ItemDatabaseService.initializeDatabase();
  await _initializeDefaultItems();
  
  runApp(const MoneyMansionApp());
}

Future<void> _initializeDefaultItems() async {
  final existingItems = await ItemDatabaseService.getAllItems();
  
  // Only initialize items if database is empty
  if (existingItems.isEmpty) {
    for (final item in GAME_ITEMS) {
      await ItemDatabaseService.createItem(item);
    }
  }
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
