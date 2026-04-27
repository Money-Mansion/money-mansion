import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/item_database_service.dart';
import '../services/financial_database_service.dart';
import '../services/goal_database_service.dart';
import '../services/quiz_progress_database_service.dart';
import '../services/room_layout_database_service.dart';
import '../services/room_component_database_service.dart';
import '../services/streak_service.dart';
import '../services/app_localizations_provider.dart';
import '../services/music_service.dart';
import '../services/tutorial_provider.dart';
import '../services/onboarding_service.dart';
import '../config/items_config.dart';
import '../widgets/top_bar.dart';
import '../widgets/room_viewer.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/chrumko_guide.dart';
import '../widgets/chrumko_learning_overlay.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/tutorial_target.dart';
import 'shop_screen.dart';
import 'goals_screen.dart';
import 'inventory_screen.dart';
import 'financial_management_screen.dart';
import 'room_edit_screen.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameState gameState;
  int selectedNavIndex = -1;
  bool _isInitialized = false;
  int _roomViewerVersion = 0;
  bool _overlayOpen = false;
  bool _wasMusicPlayingBeforePause = false;

  static const bool _DEBUG_MODE = false; // Set to false for production builds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameState = context.read<GameState>();
      _initializeGameState();
      gameState.addListener(_saveGameStateChanges);
      gameState.addListener(_handleMusicStateChange);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    gameState.removeListener(_saveGameStateChanges);
    gameState.removeListener(_handleMusicStateChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 App lifecycle changed: $state');
    switch (state) {
      case AppLifecycleState.paused:
        if (MusicService().isPlayingMusic()) {
          _wasMusicPlayingBeforePause = true;
          print('⏸️ App paused, stopping music');
          MusicService().pauseMusic();
        }
        break;
      case AppLifecycleState.resumed:
        if (_wasMusicPlayingBeforePause && gameState.isMusicEnabled()) {
          print('▶️ App resumed, resuming music');
          MusicService().resumeMusic();
          _wasMusicPlayingBeforePause = false;
        }
        break;
      case AppLifecycleState.detached:
        print('🛑 App detached, stopping music');
        MusicService().stopMusic();
        break;
      default:
        break;
    }
  }

  void _handleMusicStateChange() {
    if (gameState.isMusicEnabled() && !MusicService().isPlayingMusic()) {
      MusicService().startMusic();
    } else if (!gameState.isMusicEnabled() && MusicService().isPlayingMusic()) {
      MusicService().stopMusic();
    }
    MusicService().setVolume(gameState.getMusicVolume());
  }

  Future<void> _initializeGameState() async {
    final coins =
        _DEBUG_MODE ? 100000 : await FinancialDatabaseService.getCoins();
    final money = await FinancialDatabaseService.getMoney();
    final streak = await StreakService.getAndValidateStreak();

    if (mounted) {
      gameState.setCoins(coins);
      gameState.setMoney(money);
      gameState.setCurrentStreak(streak);

      await MusicService().setVolume(gameState.getMusicVolume());
      await Future.delayed(const Duration(milliseconds: 500));

      if (gameState.isMusicEnabled()) {
        print('🎵 Attempting to start background music...');
        await MusicService().startMusic();
      }
    }

    await ItemDatabaseService.syncOwnedItemsWithConfig(GAME_ITEMS);
    await ItemDatabaseService.ensureStarterBrokenItemsOwned(GAME_ITEMS);
    await _loadOwnedItems();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _saveGameStateChanges() {
    FinancialDatabaseService.saveCoins(gameState.coins);
    FinancialDatabaseService.saveMoney(gameState.money);
  }

  Future<void> _loadOwnedItems() async {
    final ownedItems = await ItemDatabaseService.getOwnedItems();
    if (mounted) {
      setState(() {
        gameState.loadOwnedItems(ownedItems);
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      selectedNavIndex = index;
    });
    final tutorial = context.read<TutorialProvider>();
    switch (index) {
      case 0:
        tutorial.registerAction('open_shop');
        break;
      case 1:
        tutorial.registerAction('open_financial');
        break;
      case 2:
        tutorial.registerAction('open_goals');
        break;
      case 3:
        tutorial.registerAction('open_inventory');
        break;
      case 4:
        tutorial.registerAction('open_settings');
        break;
      default:
        break;
    }
  }

  String _currentScreenId() {
    switch (selectedNavIndex) {
      case 0:
        return 'shop';
      case 1:
        return 'financial';
      case 2:
        return 'goals';
      case 3:
        return 'inventory';
      case 4:
        return 'settings';
      default:
        return 'home';
    }
  }

  Widget _getCurrentScreen(AppLocalizationsProvider localizationsProvider) {
    switch (selectedNavIndex) {
      case 0:
        return ShopScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = -1),
        );
      case 1:
        return FinancialManagementScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = -1),
        );
      case 2:
        return GoalsScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = -1),
        );
      case 3:
        return InventoryScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = -1),
        );
      case 4:
        return SettingsScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = -1),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: RoomViewer(
            key: ValueKey(_roomViewerVersion),
            room: gameState.rooms.isNotEmpty ? gameState.rooms[0] : null,
            language: localizationsProvider.currentLanguage,
            gameState: gameState,
            onEditPressed: () {
              context.read<TutorialProvider>().registerAction('open_room_edit');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomEditScreen(
                    room:
                        gameState.rooms.isNotEmpty ? gameState.rooms[0] : null,
                    gameState: gameState,
                  ),
                ),
              ).then((_) {
                setState(() {
                  _roomViewerVersion++;
                });
              });
            },
          ),
        );
    }
  }

  /// Calendar icon styled to match the app's purple aesthetic
  Widget _buildCalendarIcon() {
    final now = DateTime.now();
    final monthNames = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE8D4F0), // matches TopBar background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB8A8D8), // app purple border
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8A8D8).withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month header — purple pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFB8A8D8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Center(
              child: Text(
                monthNames[now.month - 1],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // Day number
          Expanded(
            child: Center(
              child: Text(
                now.day.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5B8C), // app purple text
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationsProvider = context.watch<AppLocalizationsProvider>();
    final tutorialProvider = context.watch<TutorialProvider>();

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If a sub-screen is open in GameScreen body, close it
        if (selectedNavIndex != -1) {
          setState(() => selectedNavIndex = -1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            SafeArea(
              child: Column(
                children: [
                TopBar(gameState: gameState),
                Expanded(child: _getCurrentScreen(localizationsProvider)),
                BottomNavigation(
                  selectedIndex: selectedNavIndex,
                  onItemTapped: _onNavItemTapped,
                ),
              ],
            ),
          ),
          // Calendar icon — only on default game screen
          if (selectedNavIndex == -1)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 100.0, 0, 0),
                  child: TutorialTarget(
                    id: 'open_calendar',
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<TutorialProvider>()
                            .registerAction('open_calendar');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CalendarScreen(date: gameState.date),
                          ),
                        );
                      },
                      child: _buildCalendarIcon(),
                    ),
                  ),
                ),
              ),
            ),
          // Chrumko guide — only on default game screen
          if (selectedNavIndex == -1)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100.0, 0, 0),
                  child: TutorialTarget(
                    id: 'open_lessons',
                    child: ChrumkoGuide(
                      language: localizationsProvider.currentLanguage,
                      autoShowTips: true,
                      isOverlayOpen: _overlayOpen,
                      onClicked: () {
                        setState(() {
                          _overlayOpen = !_overlayOpen;
                        });
                        if (_overlayOpen) {
                          context
                              .read<TutorialProvider>()
                              .registerAction('open_lessons');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          // Chrumko learning overlay
          if (selectedNavIndex == -1 && _overlayOpen)
            ChrumkoLearningOverlay(
              onClose: () {
                context
                    .read<TutorialProvider>()
                    .registerAction('close_lessons');
                setState(() {
                  _overlayOpen = false;
                });
              },
            ),
          TutorialOverlay(currentScreenId: _currentScreenId()),
        ],
      ),
      floatingActionButton: _DEBUG_MODE
          ? FloatingActionButton.small(
              heroTag: 'debug-clear-button',
              backgroundColor: Colors.red[300],
              onPressed: () async {
                await ItemDatabaseService.clearAllOwnedItems();
                await FinancialDatabaseService.clearAllFinancialData();
                await GoalDatabaseService.clearAllGoals();
                await RoomLayoutDatabaseService.clearAllRoomLayouts();
                await RoomComponentDatabaseService.clearAllOwnedComponents();
                await QuizProgressDatabaseService.clearAllProgress();
                await tutorialProvider.restartTutorial();
                await OnboardingService.resetOnboarding();
                await OnboardingService.resetPrivacyConsent();
                gameState.clearOwnedItems();
                gameState.setCoins(0);
                gameState.setMoney(0.0);
                gameState.setCurrentStreak(0);
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'DEBUG: Cleared all user progress + quiz data + privacy consent',
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Icon(Icons.delete, color: Colors.white),
            )
          : null,      ),    );
  }
}
