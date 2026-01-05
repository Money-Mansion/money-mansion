import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import 'screens/game_screen.dart';
import 'services/task_database_service.dart';
import 'services/item_database_service.dart';
import 'models/item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize databases
  await TaskDatabaseService.initializeDatabase();
  await ItemDatabaseService.initializeDatabase();
  
  // Ensure both tables exist
  await _ensureDatabaseTables();
  
  // Initialize items if they don't exist yet
  await _initializeDefaultItems();
  
  runApp(const MoneyMansionApp());
}

Future<void> _ensureDatabaseTables() async {
  try {
    final db = await ItemDatabaseService.database;
    
    // Create tasks table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        rewardCoins INTEGER NOT NULL,
        dueDate INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Create items table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        texture TEXT NOT NULL,
        cost INTEGER NOT NULL,
        owned INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    print('Database tables initialized successfully');
  } catch (e) {
    print('Error initializing database tables: $e');
  }
}

Future<void> _initializeDefaultItems() async {
  final existingItems = await ItemDatabaseService.getAllItems();
  
  // Only create basic_door if no items exist yet
  if (existingItems.isEmpty) {
    final basicDoor = Item(
      id: 'basic_door',
      name: 'Basic Door',
      type: ItemType.door,
      texture: 'assets/images/basic_door.png',
      cost: 1,
      owned: true,
    );
    await ItemDatabaseService.createItem(basicDoor);
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
