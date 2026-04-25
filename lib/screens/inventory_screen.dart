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

// App colour constants — same as room_edit_screen.dart
const _purple = Color(0xFF6B5B8C);
const _purpleLight = Color(0xFFB8A8D8);
const _purpleBg = Color(0xFFE8D4F0);
const _cream = Color(0xFFFFFBF5);

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
  Map<String, int> _placedItemCounts = {};
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
    Category(labelKey: 'pets', itemSubtype: ItemSubtype.pets),
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

    final placedCounts = <String, int>{};
    for (final placement in placements) {
      placedCounts.update(
        placement.itemId as String,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    setState(() {
      _placedItemCounts = placedCounts;
      _inventoryRoomComponents = ownedComponents;
      _isLoading = false;
    });
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
      case ItemSubtype.pets:
        return id == 'hoblub' ||
            id == 'morca' ||
            id == 'zajacik' ||
            id.startsWith('macka_') ||
            id.startsWith('psik_');
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
      case 'pets':
        return Icons.pets;
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
        return isSk ? 'Nástenné dekorácie' : 'Wall Decor';
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
      case 'pets':
        return isSk ? 'Zvieratá' : 'Pets';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        title: Text(l10n.translate('inventory')),
        leading: TutorialTarget(
          id: 'nav_back',
          child: IconButton(
            icon: const Icon(Icons.close),
            color: _purple,
            onPressed: () {
              context.read<TutorialProvider>().registerAction('go_back');
              widget.onBack();
            },
          ),
        ),
        bottom: ScrollableTabBarWrapper(
          tabController: _tabController,
          labelColor: _purple,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: _purple,
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
                        color: _purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _purple,
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
          ? const Center(child: CircularProgressIndicator(color: _purple))
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
            Icon(Icons.inventory_2_outlined, size: 40, color: _purpleLight),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noItemsYet'),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(3, 6);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final placedCount = _placedItemCounts[item.id] ?? 0;
        return _buildItemCard(item, placedCount, l10n);
      },
    );
  }

  Widget _buildMixedGrid(List<dynamic> items, AppLocalizationsProvider l10n) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 40, color: _purpleLight),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noItemsYet'),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(3, 6);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        if (entry is RoomComponent) {
          return _buildRoomComponentCard(entry, l10n);
        }
        final item = entry as Item;
        final placedCount = _placedItemCounts[item.id] ?? 0;
        return _buildItemCard(item, placedCount, l10n);
      },
    );
  }

  Widget _buildRoomComponentGrid(
      List<RoomComponent> components, AppLocalizationsProvider l10n) {
    if (components.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 40, color: _purpleLight),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noItemsYet'),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(3, 6);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) => _buildRoomComponentCard(
        components[index],
        context.watch<AppLocalizationsProvider>(),
      ),
    );
  }

  Widget _buildItemCard(
      Item item, int placedCount, AppLocalizationsProvider l10n) {
    final maxCount = item.quantity > 0 ? item.quantity : 1;
    final shownPlacedCount = placedCount > maxCount ? maxCount : placedCount;
    final isFullyPlaced = shownPlacedCount >= maxCount;

    return Container(
      decoration: BoxDecoration(
        color: isFullyPlaced ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFullyPlaced ? Colors.grey.shade300 : _purpleLight,
          width: 1.5,
        ),
        boxShadow: isFullyPlaced
            ? []
            : [
                BoxShadow(
                  color: _purpleLight.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Opacity(
                    opacity: isFullyPlaced ? 0.5 : 1.0,
                    child: item.texture.isNotEmpty
                        ? Image.asset(
                            item.texture,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.image_not_supported,
                            size: 28,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                child: Text(
                  item.localizedName(l10n.currentLanguage),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isFullyPlaced ? Colors.grey[500] : _purple,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFullyPlaced ? Colors.grey[300] : _purpleBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.type.toDisplayString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      color: isFullyPlaced ? Colors.grey[600] : _purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Text(
                  '${l10n.translate('placed')}: $shownPlacedCount/$maxCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: isFullyPlaced ? Colors.grey[600] : _purple,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isFullyPlaced ? Colors.grey[500] : _purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x$maxCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isFullyPlaced)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.translate('placed'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomComponentCard(
      RoomComponent component, AppLocalizationsProvider l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _purpleLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _purpleLight.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: component.texture.isNotEmpty
                      ? Image.asset(
                          component.texture,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 28,
                          color: Colors.grey[400],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                child: Text(
                  component.localizedName(l10n.currentLanguage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _purple,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: _purpleBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getRoomComponentTypeLabel(component.type, l10n),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      color: _purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x1',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
