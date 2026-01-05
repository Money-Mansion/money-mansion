import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/room.dart';
import '../services/item_database_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/room_viewer.dart';
import '../widgets/bottom_navigation.dart';
import 'shop_screen.dart';
import 'tasks_screen.dart';
import 'inventory_screen.dart';
import 'financial_management_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  int selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    gameState = GameState(
      coins: 111,
      money: 0,
      date: 7.7,
      rooms: [
        // Single room
        Room(
          walls: [
            Wall(style: WallStyle.basic, direction: Direction.north),
            Wall(style: WallStyle.basic, direction: Direction.south),
            Wall(style: WallStyle.basic, direction: Direction.east),
            Wall(style: WallStyle.basic, direction: Direction.west),
          ],
          floor: Floor(type: FloorType.tile),
          furniture: [
            Furniture(
              type: FurnitureType.door,
              position: Position(x: 0, y: 2),
              cost: 0,
            ),
            Furniture(
              type: FurnitureType.window,
              position: Position(x: 3, y: 2),
              cost: 0,
            ),
          ],
        ),
      ],
    );
    _loadOwnedItems();
  }

  Future<void> _loadOwnedItems() async {
    final ownedItems = await ItemDatabaseService.getOwnedItems();
    gameState.loadOwnedItems(ownedItems);
  }

  void _onNavItemTapped(int index) {
    // This is where you update the selected index, 
    // ensuring that no new screen is pushed.
    setState(() {
      selectedNavIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (selectedNavIndex) {
      case 0:
        return ShopScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = 2), // Go back to main view (RoomViewer)
        );
      case 1:
        return FinancialManagementScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = 2), // Go back to main view (RoomViewer)
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: RoomViewer(
            room: gameState.rooms.isNotEmpty
                ? gameState.rooms[0]
                : null,
          ),
        );
      case 3:
        return TasksScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = 2), // Go back to main view (RoomViewer)
        );
      case 4:
        return InventoryScreen(
          gameState: gameState,
          onBack: () => setState(() => selectedNavIndex = 2), // Go back to main view (RoomViewer)
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: RoomViewer(
            room: gameState.rooms.isNotEmpty
                ? gameState.rooms[0]
                : null,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 227, 241),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with coins, money, and date
            TopBar(gameState: gameState),
            
            // Main game area
            Expanded(
              child: _getCurrentScreen(),
            ),
            
            // Bottom navigation
            BottomNavigation(
              selectedIndex: selectedNavIndex,
              onItemTapped: _onNavItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}