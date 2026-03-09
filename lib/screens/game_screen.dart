import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/item_database_service.dart';
import '../services/financial_database_service.dart';
import '../services/goal_database_service.dart';
import '../services/app_localizations_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/room_viewer.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/chrumko_guide.dart';
import 'shop_screen.dart';
import 'goals_screen.dart';
import 'inventory_screen.dart';
import 'financial_management_screen.dart';
import 'room_edit_screen.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  int selectedNavIndex = -1; // -1 = Room viewer (home), 0-3 = nav buttons
  bool _isInitialized = false;
  
  // DEBUG FLAG: Set to true to show debug buttons
  static const bool _DEBUG_MODE = false;

  @override
  void initState() {
    super.initState();
    // Get gameState from Provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gameState = context.read<GameState>();
      _initializeGameState();
      gameState.addListener(_saveGameStateChanges);
    });
  }

  @override
  void dispose() {
    gameState.removeListener(_saveGameStateChanges);
    super.dispose();
  }

  Future<void> _initializeGameState() async {
    final coins = await FinancialDatabaseService.getCoins();
    final money = await FinancialDatabaseService.getMoney();
    
    if (mounted) {
      gameState.setCoins(coins);
      gameState.setMoney(money);
    }
    
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
            room: gameState.rooms.isNotEmpty
                ? gameState.rooms[0]
                : null,
            language: localizationsProvider.currentLanguage, // ← passes 'en' or 'sk'
            onEditPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomEditScreen(
                    room: gameState.rooms.isNotEmpty
                        ? gameState.rooms[0]
                        : null,
                    gameState: gameState,
                  ),
                ),
              );
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
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
                // Top bar with coins, money, and date
                TopBar(gameState: gameState),
                
                // Main game area
                Expanded(
                  child: _getCurrentScreen(localizationsProvider),
                ),
                
                // Bottom navigation
                BottomNavigation(
                  selectedIndex: selectedNavIndex,
                  onItemTapped: _onNavItemTapped,
                ),
              ],
            ),
          ),
          // Chrumko guide - floating overlay (top-right corner) - only on default game screen
          if (selectedNavIndex == -1)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100.0, 0, 0),
                  child: ChrumkoGuide(
                    language: localizationsProvider.currentLanguage,
                    autoShowTips: true,
                  ),
                ),
              ),
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
                gameState.clearOwnedItems();
                gameState.setCoins(0);
                gameState.setMoney(0.0);
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