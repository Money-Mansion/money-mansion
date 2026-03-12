import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../services/app_localizations_provider.dart';
import '../services/room_layout_database_service.dart';
import '../widgets/room_viewer.dart';
import '../games/room_world.dart';

class RoomEditScreen extends StatefulWidget {
  final Room? room;
  final GameState? gameState;

  const RoomEditScreen({
    super.key,
    this.room,
    this.gameState,
  });

  @override
  State<RoomEditScreen> createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends State<RoomEditScreen> {
  RoomWorld? roomWorld;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLocalizationsProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Flame canvas filling the screen
          RoomViewer(
            room: widget.room,
            language: language,
            gameState: widget.gameState,
            onEditPressed: null, // Disable edit button in edit mode
            onRoomWorldReady: (RoomWorld world) {
              setState(() {
                roomWorld = world;
              });
            },
          ),
          // Top-left buttons (Checkmark and X)
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                // Checkmark button
                FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Colors.purple.shade300,
                  onPressed: _onConfirmPressed,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(width: 10),
                // X button
                FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Colors.pink.shade300,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Bottom-left inventory button
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              heroTag: null,
              backgroundColor: Colors.blue.shade300,
              onPressed: () => _showInventorySheet(context),
              child: const Icon(Icons.inventory_2, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirmPressed() async {
    if (roomWorld == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final placements = roomWorld!.getCurrentLayout(
      RoomLayoutDatabaseService.defaultRoomId,
    );

    await RoomLayoutDatabaseService.saveRoomLayout(
      RoomLayoutDatabaseService.defaultRoomId,
      placements,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showInventorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.33,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Inventory items grid
            Expanded(
              child: widget.gameState?.ownedItems.isEmpty ?? true
                  ? Center(
                      child: Text(
                        'No items yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: widget.gameState?.ownedItems.length ?? 0,
                        itemBuilder: (context, index) {
                          final item = widget.gameState!.ownedItems[index];
                          return _buildItemCard(context, item);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    return GestureDetector(
      onTap: () {
        if (roomWorld != null) {
          roomWorld!.addItemToRoom(item);
          Navigator.pop(context);
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6.0),
                child: item.texture.isNotEmpty
                    ? Image.asset(
                        item.texture,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.type.toDisplayString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}