import 'package:flutter/material.dart';
import 'package:money_mansion/widgets/scrollable_tab_bar_wrapper.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../models/room_component.dart';
import '../services/shop_service.dart';
import '../services/room_component_service.dart';
import '../services/app_localizations_provider.dart';
import '../services/room_layout_database_service.dart';
import '../widgets/tutorial_target.dart';
import 'category.dart';

class ShopScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const ShopScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  List<Item> _shopItems = [];
  List<RoomComponent> _shopRoomComponents = [];
  Map<String, int> _placedItemCounts = {};
  bool _isLoading = true;
  late TabController _tabController;

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------
  // "All" tab shows both items and room components.
  // Walls and floors also have dedicated tabs.
  static const List<Category> _categories = [
    // ── All & Room-component categories ──────────────────────────────
    Category(labelKey: 'all'),
    Category(
        labelKey: 'floors',
        isRoomComponent: true,
        componentType: RoomComponentType.floor),
    Category(
        labelKey: 'walls',
        isRoomComponent: true,
        componentType: RoomComponentType.wall),
    // ── Item categories ──────────────────────────────────────────────
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
    _loadShopItems();
    _loadShopRoomComponents();
    _loadPlacedItemCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadShopItems() async {
    final items = await ShopService.getShopItems();
    setState(() {
      _shopItems = items;
      _isLoading = false;
    });
  }

  Future<void> _loadShopRoomComponents() async {
    final components = await RoomComponentService.getShopComponents();
    setState(() {
      _shopRoomComponents = components;
    });
  }

  Future<void> _loadPlacedItemCounts() async {
    final placements = await RoomLayoutDatabaseService.getRoomLayout(
      RoomLayoutDatabaseService.defaultRoomId,
    );

    final counts = <String, int>{};
    for (final placement in placements) {
      counts.update(
        placement.itemId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    if (!mounted) return;
    setState(() {
      _placedItemCounts = counts;
    });
  }

  int _ownedCountForItem(String itemId) {
    for (final item in widget.gameState.ownedItems) {
      if (item.id == itemId) {
        return item.quantity;
      }
    }
    return 0;
  }

  int _placedCountForItem(String itemId) {
    return _placedItemCounts[itemId] ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Subtype filtering helpers
  // ---------------------------------------------------------------------------

  /// Returns true if the item belongs to the given subtype bucket.
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
        // No items yet — placeholder for future lamps, etc.
        return id.startsWith('lampa_') || id.startsWith('svetlo_');
    }
  }

  List<dynamic> _itemsForCategory(Category category) {
    // Room-component tabs
    if (category.isRoomComponent) {
      if (category.componentType == null) return _shopRoomComponents;
      return _shopRoomComponents
          .where((c) => c.type == category.componentType)
          .toList();
    }

    // "All" tab — includes both items and room components
    if (category.labelKey == 'all') {
      return [..._shopItems, ..._shopRoomComponents];
    }

    // Subtype filter
    if (category.itemSubtype != null) {
      return _shopItems
          .where((i) => _matchesSubtype(i, category.itemSubtype!))
          .toList();
    }

    // ItemType filter (doors)
    if (category.itemType != null) {
      return _shopItems.where((i) => i.type == category.itemType).toList();
    }

    return [];
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final language = l10n.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('shop')),
        leading: TutorialTarget(
          id: 'close_shop',
          child: IconButton(
            key: const Key('back_button'),
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: widget.onBack,
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
                  return _buildMixedGrid(items, l10n, language);
                }
                return cat.isRoomComponent
                    ? _buildRoomComponentGrid(
                        items as List<RoomComponent>, l10n, language)
                    : _buildItemGrid(items as List<Item>, l10n, language);
              }).toList(),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid builders
  // ---------------------------------------------------------------------------

  Widget _buildItemGrid(
      List<Item> items, AppLocalizationsProvider l10n, String language) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              language == 'sk'
                  ? 'Všetky položky v tejto kategórii vlastníš!'
                  : 'You own all items in this category!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(2, 6);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _buildItemCard(items[index], l10n, language),
    );
  }

  Widget _buildMixedGrid(
      List<dynamic> items, AppLocalizationsProvider l10n, String language) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(2, 6);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        if (entry is RoomComponent) {
          return _buildRoomComponentCard(entry, l10n, language);
        }
        return _buildItemCard(entry as Item, l10n, language);
      },
    );
  }

  Widget _buildItemCard(
      Item item, AppLocalizationsProvider l10n, String language) {
    final canAfford = widget.gameState.coins >= item.cost;
    final ownedCount = _ownedCountForItem(item.id);
    final placedCount = _placedCountForItem(item.id);
    final shownPlacedCount =
        (placedCount > ownedCount) ? ownedCount : placedCount;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      item.texture,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.localizedName(language),
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            size: 9, color: Colors.orange),
                        const SizedBox(width: 2),
                        Text(
                          '${item.cost}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: canAfford
                                ? Colors.orange[700]
                                : Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.translate('placed')}: $shownPlacedCount/$ownedCount',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple[700],
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford ? () => _buyItem(item) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              canAfford ? Colors.orange[400] : Colors.grey[300],
                          foregroundColor:
                              canAfford ? Colors.white : Colors.grey[500],
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          l10n.translate('buy'),
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                  ],
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
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x$ownedCount',
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

  Widget _buildRoomComponentGrid(List<RoomComponent> components,
      AppLocalizationsProvider l10n, String language) {
    if (components.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              language == 'sk'
                  ? 'Všetky komponenty v tejto kategórii vlastníš!'
                  : 'You own all components in this category!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(2, 6);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.68,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) =>
          _buildRoomComponentCard(components[index], l10n, language),
    );
  }

  Widget _buildRoomComponentCard(
      RoomComponent component, AppLocalizationsProvider l10n, String language) {
    final canAfford = widget.gameState.coins >= component.cost;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  component.texture,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.localizedName(language),
                  style:
                      const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 9, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text(
                      '${component.cost}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.orange[700] : Colors.red[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        canAfford ? () => _buyRoomComponent(component) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canAfford ? Colors.orange[400] : Colors.grey[300],
                      foregroundColor:
                          canAfford ? Colors.white : Colors.grey[500],
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      l10n.translate('buy'),
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Purchase handlers
  // ---------------------------------------------------------------------------

  void _buyItem(Item item) async {
    final l10n = context.read<AppLocalizationsProvider>();
    if (widget.gameState.coins >= item.cost) {
      final purchased = await ShopService.buyItem(item.id);
      if (purchased) {
        widget.gameState.spendCoins(item.cost);
        widget.gameState.addOwnedItem(item);
        await _loadShopItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('itemPurchasedSuccessfully')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('Failed to purchase item: ${item.id}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('notEnoughCoins')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _buyRoomComponent(RoomComponent component) async {
    final l10n = context.read<AppLocalizationsProvider>();
    if (widget.gameState.coins >= component.cost) {
      widget.gameState.spendCoins(component.cost);
      await RoomComponentService.buyComponent(component.id);
      await _loadShopRoomComponents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('itemPurchasedSuccessfully')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('notEnoughCoins')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Icon & label helpers
  // ---------------------------------------------------------------------------

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
      default:
        return key;
    }
  }
}

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------

/// Fine-grained item subtypes used for tab filtering.
/// These live purely in the UI layer — no changes needed to Item/ItemType.
// enum _ItemSubtype {
//   beds,
//   seating,
//   tables,
//   storage,
//   carpets,
//   wallDecor,
//   plants,
//   lighting,
// }

// class _Category {
//   final String labelKey;

//   // For plain ItemType filtering (e.g. doors)
//   final ItemType? itemType;

//   // For fine-grained subtype filtering
//   final _ItemSubtype? itemSubtype;

//   // For room-component tabs (walls, floors)
//   final bool isRoomComponent;
//   final RoomComponentType? componentType;

//   const _Category({
//     required this.labelKey,
//     this.itemType,
//     this.itemSubtype,
//     this.isRoomComponent = false,
//     this.componentType,
//   });
// }
