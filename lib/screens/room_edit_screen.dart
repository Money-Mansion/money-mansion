import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../services/app_localizations_provider.dart';
import '../services/room_layout_database_service.dart';
import '../widgets/room_viewer.dart';
import '../widgets/room_components_sheet.dart';
import '../widgets/zoom_slider.dart';
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
  bool _hasSelectedItem = false;

  @override
  void dispose() {
    if (roomWorld != null) {
      roomWorld!.onSelectionChanged = null;
    }
    super.dispose();
  }

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
                // Set up callback for selection changes
                roomWorld!.onSelectionChanged = () {
                  setState(() {
                    _hasSelectedItem = roomWorld!.getSelectedItem() != null;
                  });
                };
              });
            },
          ),
          // Top-left button (Checkmark only)
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              heroTag: null,
              backgroundColor: Colors.purple.shade300,
              onPressed: _onConfirmPressed,
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ),
          // Top-right button (X close)
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              heroTag: null,
              backgroundColor: Colors.pink.shade300,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          // Bottom-left buttons (Room Components above Inventory)
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Room Components button
                FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Colors.amber.shade300,
                  onPressed: () => _showRoomComponentsSheet(context),
                  child: const Icon(Icons.home_work, color: Colors.white),
                ),
                const SizedBox(height: 10),
                // Inventory button
                FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Colors.blue.shade300,
                  onPressed: () => _showInventorySheet(context),
                  child: const Icon(Icons.inventory_2, color: Colors.white),
                ),
              ],
            ),
          ),
          // Bottom-right item control buttons (appears when item is selected)
          if (_hasSelectedItem)
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Move to front button (arrow up)
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.green[400],
                    onPressed: _onMoveToFront,
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                    tooltip: 'Move to front',
                  ),
                  const SizedBox(height: 10),
                  // Flip button
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.blue[400],
                    onPressed: _onFlipItem,
                    child: const Icon(Icons.flip, color: Colors.white),
                    tooltip: 'Flip horizontally',
                  ),
                  const SizedBox(height: 10),
                  // Move to back button (arrow down)
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.orange[400],
                    onPressed: _onMoveToBack,
                    child: const Icon(Icons.arrow_downward, color: Colors.white),
                    tooltip: 'Move to back',
                  ),
                  const SizedBox(height: 10),
                  // Delete button
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.red[400],
                    onPressed: _onDeleteSelectedItem,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ],
              ),
            ),
          // Right-side zoom slider
          if (roomWorld != null)
            ZoomSlider(gameWorld: roomWorld!),
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

  void _onDeleteSelectedItem() {
    if (roomWorld == null) return;
    roomWorld!.removeSelectedItem();
  }

  void _onMoveToFront() {
    if (roomWorld == null) return;
    roomWorld!.moveSelectedItemToFront();
  }

  void _onMoveToBack() {
    if (roomWorld == null) return;
    roomWorld!.moveSelectedItemToBack();
  }

  void _onFlipItem() {
    if (roomWorld == null) return;
    roomWorld!.flipSelectedItem();
  }

  void _showRoomComponentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => RoomComponentsSheet(
        onComponentsChanged: () {
          // Reload room components when user changes them
          if (roomWorld != null) {
            setState(() {
              // Trigger room reload by forcing a rebuild
              roomWorld!.reloadComponents();
            });
          }
        },
      ),
    );
  }

  void _showInventorySheet(BuildContext context) {
    final placedItemIds = roomWorld?.getPlacedItemIds() ?? {};

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
                          final isPlaced = placedItemIds.contains(item.id);
                          return _buildItemCard(context, item, isPlaced);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item, bool isPlaced) {
    return GestureDetector(
      onTap: isPlaced
          ? null
          : () {
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
        color: isPlaced ? Colors.grey[300] : Colors.white,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    child: Opacity(
                      opacity: isPlaced ? 0.5 : 1.0,
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
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPlaced ? Colors.grey[600] : Colors.black,
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
                      color: isPlaced ? Colors.grey[400] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.type.toDisplayString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: isPlaced ? Colors.grey[700] : Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            if (isPlaced)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Placed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}