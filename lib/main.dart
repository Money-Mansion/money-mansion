import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'screens/game_screen.dart';
import 'services/item_database_service.dart';
import 'services/financial_database_service.dart';
import 'services/goal_database_service.dart';
import 'services/app_localizations_provider.dart';
import 'models/game_state.dart';
import 'models/room.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== App Starting ===');
  print('→ Platform: ${Platform.operatingSystem}');
  
  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    print('→ Desktop platform detected, initializing FFI...');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('✓ FFI initialized');
  } else {
    print('ℹ Mobile platform detected');
  }
  
  // Initialize all database services
  print('→ Initializing database services...');
  try {
    await ItemDatabaseService.initializeDatabase();
    print('✓ ItemDatabaseService ready');
    
    await FinancialDatabaseService.initializeDatabase();
    print('✓ FinancialDatabaseService ready');
    
    await GoalDatabaseService.initializeDatabase();
    print('✓ GoalDatabaseService ready');
    
    print('=== App ready to launch ===');
  } catch (e) {
    print('ERROR during initialization: $e');
    rethrow;
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameState(
            coins: 111,
            money: 0.0,
            date: 7.7,
            rooms: [Room()],
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppLocalizationsProvider()),
      ],
      child: const MoneyMansionApp(),
    ),
  );
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
