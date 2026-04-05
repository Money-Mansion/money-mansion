import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../services/app_localizations_provider.dart';
import '../services/room_layout_database_service.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_target.dart';

class InventoryScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const InventoryScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  Set<String> _placedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadPlacedItems();
  }

  Future<void> _loadPlacedItems() async {
    final placements = await RoomLayoutDatabaseService.getRoomLayout(
      RoomLayoutDatabaseService.defaultRoomId,
    );
    setState(() {
      _placedItemIds = {for (final p in placements) p.itemId};
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('inventory')),
        leading: TutorialTarget(
          id: 'nav_back',
          child: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () {
              context.read<TutorialProvider>().registerAction('go_back');
              widget.onBack();
            },
          ),
        ),
      ),
      body: widget.gameState.ownedItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('noItemsYet'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('yourItemsWillAppearHere'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.gameState.ownedItems.length,
                itemBuilder: (context, index) {
                  final item = widget.gameState.ownedItems[index];
                  final isPlaced = _placedItemIds.contains(item.id);
                  return _buildItemCard(item, isPlaced);
                },
              ),
            ),
    );
  }

  Widget _buildItemCard(Item item, bool isPlaced) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isPlaced ? Colors.grey[300] : Colors.white,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: isPlaced ? 0.5 : 1.0,
                    child: item.texture.isNotEmpty
                        ? Image.asset(
                            item.texture,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPlaced ? Colors.grey[600] : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlaced ? Colors.grey[400] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.type.toDisplayString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isPlaced ? Colors.grey[700] : Colors.blue[900],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          if (isPlaced)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Placed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
