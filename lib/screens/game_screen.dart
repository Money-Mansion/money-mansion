import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/room.dart';
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
    // Inicializácia herného stavu
    gameState = GameState(
      coins: 111,
      emeralds: 780,
      date: 7.7,
      rooms: [
        Room(
          id: 'room1',
          type: RoomType.living,
          walls: [
            Wall(style: WallStyle.basic, direction: Direction.north),
            Wall(style: WallStyle.basic, direction: Direction.south),
            Wall(style: WallStyle.basic, direction: Direction.east),
            Wall(style: WallStyle.basic, direction: Direction.west),
          ],
          floor: Floor(type: FloorType.tile),
          furniture: [
            Furniture(
              id: 'door1',
              type: FurnitureType.door,
              position: Position(x: 0, y: 2),
            ),
            Furniture(
              id: 'window1',
              type: FurnitureType.window,
              position: Position(x: 3, y: 2),
            ),
          ],
        ),
      ],
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      selectedNavIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (selectedNavIndex) {
      case 0:
        return ShopScreen(gameState: gameState);
      case 1:
        return FinancialManagementScreen(gameState: gameState);
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
        return TasksScreen(gameState: gameState);
      case 4:
        return InventoryScreen(gameState: gameState);
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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            // Horná lišta s coinmi, emeraldmi a dátumom
            TopBar(gameState: gameState),
            
            // Hlavný herný priestor
            Expanded(
              child: _getCurrentScreen(),
            ),
            
            // Spodná navigácia
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
