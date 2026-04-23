import 'package:flutter/material.dart';
import 'package:money_mansion/models/room_component.dart';
import 'package:money_mansion/screens/category.dart';
import 'package:money_mansion/services/room_component_service.dart';
import 'package:money_mansion/widgets/scrollable_tab_bar_wrapper.dart';
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

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  Set<String> _placedItemIds = {};
  late TabController _tabController;
  bool _isLoading = true;
  List<RoomComponent> _inventoryRoomComponents = [];

  static const List<Category> _categories = [
    Category(labelKey: 'all'),
    Category(
        labelKey: 'floors',
        isRoomComponent: true,
        componentType: RoomComponentType.floor),
    Category(
        labelKey: 'walls',
        isRoomComponent: true,
        componentType: RoomComponentType.wall),
    Category(labelKey: 'beds', itemSubtype: ItemSubtype.beds),
    Category(labelKey: 'seating', itemSubtype: ItemSubtype.seating),
    Category(labelKey: 'tables', itemSubtype: ItemSubtype.tables),
    Category(labelKey: 'storage', itemSubtype: ItemSubtype.storage),
    Category(labelKey: 'carpets', itemSubtype: ItemSubtype.carpets),
    Category(labelKey: 'wallDecor', itemSubtype: ItemSubtype.wallDecor),
    Category(labelKey: 'plants', itemSubtype: ItemSubtype.plants),
    Category(labelKey: 'lighting', itemSubtype: ItemSubtype.lighting),
    Category(labelKey: 'doors', itemType: ItemType.door),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadInventoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryData() async {
    final results = await Future.wait<dynamic>([
      RoomLayoutDatabaseService.getRoomLayout(
        RoomLayoutDatabaseService.defaultRoomId,
      ),
      RoomComponentService.getOwnedComponents(),
    ]);

    final placements = results[0] as List;
    final ownedComponents = results[1] as List<RoomComponent>;

    setState(() {
      _placedItemIds = {for (final p in placements) p.itemId};
      _inventoryRoomComponents = ownedComponents;
      _isLoading = false;
    });
  }

  String _getItemTypeLabel(ItemType type, AppLocalizationsProvider l10n) {
    switch (type) {
      case ItemType.door:
        return l10n.translate('itemTypeDoor');
      case ItemType.window:
        return l10n.translate('itemTypeWindow');
      case ItemType.furniture:
        return l10n.translate('itemTypeFurniture');
      case ItemType.flooring:
        return l10n.translate('itemTypeFlooring');
      case ItemType.wallpaper:
        return l10n.translate('itemTypeWallpaper');
      case ItemType.decoration:
        return l10n.translate('itemTypeDecoration');
    }
  }

  String _getRoomComponentTypeLabel(
      RoomComponentType type, AppLocalizationsProvider l10n) {
    switch (type) {
      case RoomComponentType.wall:
        return l10n.translate('roomComponentWall');
      case RoomComponentType.floor:
        return l10n.translate('roomComponentFloor');
    }
  }

  bool _matchesSubtype(Item item, ItemSubtype subtype) {
    final id = item.id;
    switch (subtype) {
      case ItemSubtype.beds:
        return id.startsWith('postel_') ||
            id.startsWith('posteľ_') ||
            id == 'postel_znicena';
      case ItemSubtype.seating:
        return id.startsWith('gauc_');
      case ItemSubtype.tables:
        return id.startsWith('stol_');
      case ItemSubtype.storage:
        return id.startsWith('polica') ||
            id.startsWith('police') ||
            id.startsWith('skriňa') ||
            id.startsWith('skrina') ||
            id == 'polica_kniznica_cierna';
      case ItemSubtype.carpets:
        return id.startsWith('koberec_');
      case ItemSubtype.wallDecor:
        return id.startsWith('obraz_') ||
            id.startsWith('okno_') ||
            id == 'okno_zrkadlo';
      case ItemSubtype.plants:
        return id.startsWith('kvietok_');
      case ItemSubtype.lighting:
        return id.startsWith('lampa_') || id.startsWith('svetlo_');
    }
  }

  List<dynamic> _itemsForCategory(Category category) {
    final ownedItems = widget.gameState.ownedItems;

    if (category.isRoomComponent) {
      if (category.componentType == null) return _inventoryRoomComponents;
      return _inventoryRoomComponents
          .where((c) => c.type == category.componentType)
          .toList();
    }

    if (category.labelKey == 'all') {
      return [...ownedItems, ..._inventoryRoomComponents];
    }

    if (category.itemSubtype != null) {
      return ownedItems
          .where((i) => _matchesSubtype(i, category.itemSubtype!))
          .toList();
    }

    if (category.itemType != null) {
      return ownedItems.where((i) => i.type == category.itemType).toList();
    }

    return [];
  }

  IconData _categoryIcon(String labelKey) {
    switch (labelKey) {
      case 'all':
        return Icons.grid_view;
      case 'beds':
        return Icons.bed;
      case 'seating':
        return Icons.chair;
      case 'tables':
        return Icons.table_restaurant;
      case 'storage':
        return Icons.shelves;
      case 'carpets':
        return Icons.square_foot;
      case 'wallDecor':
        return Icons.image;
      case 'plants':
        return Icons.local_florist;
      case 'lighting':
        return Icons.lightbulb_outline;
      case 'doors':
        return Icons.door_front_door;
      default:
        return Icons.grid_view;
    }
  }

  IconData _roomComponentIcon(RoomComponentType? type) {
    switch (type) {
      case RoomComponentType.wall:
        return Icons.wallpaper;
      case RoomComponentType.floor:
        return Icons.square_foot;
      default:
        return Icons.home;
    }
  }

  String _categoryLabel(String key, AppLocalizationsProvider l10n) {
    final isSk = l10n.currentLanguage == 'sk';
    switch (key) {
      case 'all':
        return isSk ? 'Všetko' : 'All';
      case 'beds':
        return isSk ? 'Postele' : 'Beds';
      case 'seating':
        return isSk ? 'Posedenie' : 'Seating';
      case 'tables':
        return isSk ? 'Stoly' : 'Tables';
      case 'storage':
        return isSk ? 'Úložný priestor' : 'Storage';
      case 'carpets':
        return isSk ? 'Koberce' : 'Carpets';
      case 'wallDecor':
        return isSk ? 'Steny' : 'Wall Decor';
      case 'plants':
        return isSk ? 'Rastliny' : 'Plants';
      case 'lighting':
        return isSk ? 'Svetlá' : 'Lighting';
      case 'doors':
        return isSk ? 'Dvere' : 'Doors';
      case 'walls':
        return isSk ? 'Tapety' : 'Walls';
      case 'floors':
        return isSk ? 'Podlahy' : 'Floors';
      default:
        return key;
    }
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
        bottom: ScrollableTabBarWrapper(
          tabController: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.deepPurple,
          indicatorWeight: 3,
          tabs: _categories.map((cat) {
            final count = _isLoading ? null : _itemsForCategory(cat).length;
            final icon = cat.isRoomComponent
                ? _roomComponentIcon(cat.componentType)
                : _categoryIcon(cat.labelKey);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 6),
                  Text(_categoryLabel(cat.labelKey, l10n)),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((cat) {
                final items = _itemsForCategory(cat);
                if (cat.labelKey == 'all') {
                  return _buildMixedGrid(items, l10n);
                }
                return cat.isRoomComponent
                    ? _buildRoomComponentGrid(
                        items as List<RoomComponent>, l10n)
                    : _buildItemGrid(items as List<Item>, l10n);
              }).toList(),
            ),
    );
  }

  Widget _buildItemGrid(List<Item> items, AppLocalizationsProvider l10n) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isPlaced = _placedItemIds.contains(item.id);
          return _buildItemCard(item, isPlaced, l10n);
        },
      ),
    );
  }

  Widget _buildMixedGrid(List<dynamic> items, AppLocalizationsProvider l10n) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final entry = items[index];
          if (entry is RoomComponent) {
            return _buildRoomComponentCard(entry, l10n);
          }
          final item = entry as Item;
          final isPlaced = _placedItemIds.contains(item.id);
          return _buildItemCard(item, isPlaced, l10n);
        },
      ),
    );
  }

  Widget _buildRoomComponentGrid(
      List<RoomComponent> components, AppLocalizationsProvider l10n) {
    if (components.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: components.length,
        itemBuilder: (context, index) => _buildRoomComponentCard(
              components[index],
              context.watch<AppLocalizationsProvider>(),
            ),
      ),
    );
  }

  Widget _buildItemCard(Item item, bool isPlaced, AppLocalizationsProvider l10n) {
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
                    _getItemTypeLabel(item.type, l10n),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.translate('placed'),
                    style: const TextStyle(
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

  Widget _buildRoomComponentCard(RoomComponent component, AppLocalizationsProvider l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: component.texture.isNotEmpty
                  ? Image.asset(
                      component.texture,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey[400],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              component.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getRoomComponentTypeLabel(component.type, l10n),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber[900],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}