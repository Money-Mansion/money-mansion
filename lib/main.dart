import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'screens/game_screen.dart';
import 'services/item_database_service.dart';
import 'services/financial_database_service.dart';
import 'services/goal_database_service.dart';
import 'services/quiz_progress_database_service.dart';
import 'services/room_component_database_service.dart';
import 'services/app_localizations_provider.dart';
import 'services/music_service.dart';
import 'services/onboarding_service.dart';
import 'services/tutorial_provider.dart';
import 'models/game_state.dart';
import 'models/room.dart';
import 'screens/onboarding_screen.dart';
import 'screens/privacy_consent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== App Starting ===');
  if (!kIsWeb) {
    print('→ Platform: ${Platform.operatingSystem}');
  }

  // Initialize FFI for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    print('→ Desktop platform detected, initializing FFI...');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('✓ FFI initialized');
  } else if (!kIsWeb) {
    print('ℹ Mobile platform detected');
  }

  // Initialize all database services
  print('→ Initializing database services...');
  try {
    await ItemDatabaseService.initializeDatabase();
    print('✓ ItemDatabaseService ready');

    await RoomComponentDatabaseService.ensureDefaultComponentsOwned();
    await RoomComponentDatabaseService.ensureStarterRuinedFloorsOwned();
    print('✓ RoomComponentDatabaseService defaults ensured');

    await FinancialDatabaseService.initializeDatabase();
    // Ensure database is fully initialized by accessing it once
    try {
      await FinancialDatabaseService.database;
      print('✓ FinancialDatabaseService ready');
    } catch (e) {
      print(
          '⚠ FinancialDatabaseService initialization error, attempting recovery: $e');
      await FinancialDatabaseService.clearAndReinitialize();
      print('✓ FinancialDatabaseService recovered');
    }

    await GoalDatabaseService.initializeDatabase();
    print('✓ GoalDatabaseService ready');

    await QuizProgressDatabaseService.initializeDatabase();
    print('✓ QuizProgressDatabaseService ready');

    // Ensure quiz progress table exists
    try {
      final allProgress = await QuizProgressDatabaseService.getAllProgress();
      print(
          '✓ Quiz progress table verified - ${allProgress.length} records found');
    } catch (e) {
      print('⚠ Quiz progress table check failed: $e');
    }

    // Initialize music service
    final musicService = MusicService();
    // Default list of available music tracks (no "assets/" prefix - AssetSource adds it)
    musicService.initializeTracks([
      'music/track1.mp3',
      'music/track2.mp3',
      'music/track3.mp3',
      'music/track4.mp3',
    ]);
    print('✓ MusicService ready');

    print('=== App ready to launch ===');
  } catch (e) {
    print('ERROR during initialization: $e');
    rethrow;
  }

  // Detect and handle fresh installs (app uninstalled/reinstalled)
  // This resets SharedPreferences if databases were cleared but prefs were backed up
  final isFreshInstall = await OnboardingService.detectFreshInstall();
  if (isFreshInstall) {
    await OnboardingService.resetAllOnboardingAndTutorialData();
    print('✓ Fresh install detected and cleaned');
  }

  // Load music preferences from database
  final musicEnabled = await FinancialDatabaseService.getMusicEnabled();
  final musicVolume = await FinancialDatabaseService.getMusicVolume();
  final isFirstLaunch = await OnboardingService.isFirstLaunch();
  final hasPrivacyConsent = await OnboardingService.hasPrivacyConsent();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameState(
            coins: 111,
            money: 0.0,
            date: 7.7,
            musicEnabled: musicEnabled,
            musicVolume: musicVolume,
            rooms: [Room()],
          ),
        ),
        ChangeNotifierProvider(create: (_) => AppLocalizationsProvider()),
        ChangeNotifierProvider(create: (_) => TutorialProvider()),
      ],
      child: MoneyMansionApp(
        isFirstLaunch: isFirstLaunch,
        hasPrivacyConsent: hasPrivacyConsent,
      ),
    ),
  );
}

class MoneyMansionApp extends StatefulWidget {
  final bool isFirstLaunch;
  final bool hasPrivacyConsent;

  const MoneyMansionApp({
    super.key,
    required this.isFirstLaunch,
    required this.hasPrivacyConsent,
  });

  @override
  State<MoneyMansionApp> createState() => _MoneyMansionAppState();
}

class _MoneyMansionAppState extends State<MoneyMansionApp> {
  late bool _hasPrivacyConsent;

  @override
  void initState() {
    super.initState();
    _hasPrivacyConsent = widget.hasPrivacyConsent;
  }

  void _onPrivacyAccepted() {
    setState(() {
      _hasPrivacyConsent = true;
    });
  }

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
      home: _hasPrivacyConsent
          ? (widget.isFirstLaunch
              ? const OnboardingScreen()
              : const GameScreen())
          : PrivacyConsentScreen(onAccepted: _onPrivacyAccepted),
    );
  }
}
