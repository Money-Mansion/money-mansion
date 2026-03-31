import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/item_database_service.dart';
import '../services/financial_database_service.dart';
import '../services/goal_database_service.dart';
import '../services/room_layout_database_service.dart';
import '../services/room_component_database_service.dart';
import '../services/app_localizations_provider.dart';
import '../services/music_service.dart';
import '../config/items_config.dart';
import '../widgets/top_bar.dart';
import '../widgets/room_viewer.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/chrumko_guide.dart';
import '../widgets/chrumko_learning_overlay.dart';
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

  static const bool _DEBUG_MODE = true;

  @override
  void initState() {
    super.initState();
    // Register this widget as a lifecycle observer
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
    // Unregister lifecycle observer
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
        // App is in background — automatically stop music
        if (MusicService().isPlayingMusic()) {
          _wasMusicPlayingBeforePause = true;
          print('⏸️ App paused, stopping music');
          MusicService().pauseMusic();
        }
        break;
      case AppLifecycleState.resumed:
        // App is back in foreground — resume music if it was playing
        if (_wasMusicPlayingBeforePause && gameState.isMusicEnabled()) {
          print('▶️ App resumed, resuming music');
          MusicService().resumeMusic();
          _wasMusicPlayingBeforePause = false;
        }
        break;
      case AppLifecycleState.detached:
        // App is closing — stop music
        print('🛑 App detached, stopping music');
        MusicService().stopMusic();
        break;
      default:
        break;
    }
  }

  void _handleMusicStateChange() {
    // Handle music enabled/disabled toggle from settings
    if (gameState.isMusicEnabled() && !MusicService().isPlayingMusic()) {
      MusicService().startMusic();
    } else if (!gameState.isMusicEnabled() && MusicService().isPlayingMusic()) {
      MusicService().stopMusic();
    }
    
    // Update volume whenever settings change
    MusicService().setVolume(gameState.getMusicVolume());
  }

  Future<void> _initializeGameState() async {
    final coins = _DEBUG_MODE ? 100000 : await FinancialDatabaseService.getCoins();
    final money = await FinancialDatabaseService.getMoney();
    final chrumka = await FinancialDatabaseService.getChrumka(); // ← load chrumka

    if (mounted) {
      gameState.setCoins(coins);
      gameState.setMoney(money);
      gameState.setChrumka(chrumka); // ← restore chrumka
      
      // Set music volume
      await MusicService().setVolume(gameState.getMusicVolume());
      
      // Small delay to ensure assets are loaded
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Start background music if enabled
      if (gameState.isMusicEnabled()) {
        print('🎵 Attempting to start background music...');
        await MusicService().startMusic();
      }
    }

    // Sync owned items with latest config values (useful for development)
    await ItemDatabaseService.syncOwnedItemsWithConfig(GAME_ITEMS);

    await _loadOwnedItems();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _saveGameStateChanges() {
    // Auto-save coins, money and chrumka whenever GameState notifies
    FinancialDatabaseService.saveCoins(gameState.coins);
    FinancialDatabaseService.saveMoney(gameState.money);
    FinancialDatabaseService.saveChrumka(gameState.chrumka); // ← save chrumka
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomEditScreen(
                    room: gameState.rooms.isNotEmpty ? gameState.rooms[0] : null,
                    gameState: gameState,
                  ),
                ),
              ).then((_) {
                // Force RoomViewer (and its RoomWorld) to rebuild and reload layout
                setState(() {
                  _roomViewerVersion++;
                });
              });
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationsProvider = context.watch<AppLocalizationsProvider>();

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 227, 241),
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
          // Calendar button — only on default game screen
          if (selectedNavIndex == -1)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 100.0, 0, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CalendarScreen(date: gameState.date),
                        ),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE74C3C),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            child: Center(
                              child: Builder(
                                builder: (context) {
                                  final now = DateTime.now();
                                  final monthNames = [
                                    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
                                  ];
                                  return Text(
                                    monthNames[now.month - 1],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Builder(
                                builder: (context) {
                                  return Text(
                                    DateTime.now().day.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  child: ChrumkoGuide(
                    language: localizationsProvider.currentLanguage,
                    autoShowTips: true,
                    onClicked: () {
                      setState(() {
                        _overlayOpen = !_overlayOpen;
                      });
                    },
                  ),
                ),
              ),
            ),
          // Chrumko learning overlay — only on default game screen when open
          if (selectedNavIndex == -1 && _overlayOpen)
            ChrumkoLearningOverlay(
              onClose: () {
                setState(() {
                  _overlayOpen = false;
                });
              },
            ),
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
                gameState.clearOwnedItems();
                gameState.setCoins(0);
                gameState.setMoney(0.0);
                gameState.setChrumka(0);
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('DEBUG: Cleared all user progress'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Icon(Icons.delete, color: Colors.white),
            )
          : null,
    );
  }
}