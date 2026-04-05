import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../models/room_component.dart';
import '../services/shop_service.dart';
import '../services/room_component_service.dart';
import '../services/app_localizations_provider.dart';

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
  bool _isLoading = true;
  late TabController _tabController;

  static const List<_Category> _categories = [
    _Category(labelKey: 'all', itemType: null),
    _Category(labelKey: 'furniture', itemType: ItemType.furniture),
    _Category(labelKey: 'decoration', itemType: ItemType.decoration),
    _Category(labelKey: 'doors', itemType: ItemType.door),
    _Category(labelKey: 'walls', isRoomComponent: true, componentType: RoomComponentType.wall),
    _Category(labelKey: 'floors', isRoomComponent: true, componentType: RoomComponentType.floor),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadShopItems();
    _loadShopRoomComponents();
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

  void _buyItem(Item item) async {
    final l10n = context.read<AppLocalizationsProvider>();
    if (widget.gameState.coins >= item.cost) {
      widget.gameState.spendCoins(item.cost);
      widget.gameState.addOwnedItem(item);

      await ShopService.buyItem(item.id);
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

  List<dynamic> _itemsForCategory(_Category category) {
    if (category.isRoomComponent) {
      if (category.componentType == null) return _shopRoomComponents;
      return _shopRoomComponents
          .where((c) => c.type == category.componentType)
          .toList();
    } else {
      if (category.itemType == null) return _shopItems;
      return _shopItems.where((i) => i.type == category.itemType).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final language = l10n.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('shop')),
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(Icons.close),
          color: Colors.black,
          onPressed: widget.onBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.deepPurple,
          indicatorWeight: 3,
          tabs: _categories.map((cat) {
            final count = _isLoading ? null : _itemsForCategory(cat).length;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.isRoomComponent ? _roomComponentIcon(cat.componentType) : _categoryIcon(cat.itemType), size: 16),
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
                return cat.isRoomComponent
                    ? _buildRoomComponentGrid(items as List<RoomComponent>, l10n, language)
                    : _buildItemGrid(items as List<Item>, l10n, language);
              }).toList(),
            ),
    );
  }

  Widget _buildItemGrid(List<Item> items, AppLocalizationsProvider l10n, String language) {
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

  Widget _buildItemCard(Item item, AppLocalizationsProvider l10n, String language) {
    final canAfford = widget.gameState.coins >= item.cost;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
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
          // Info + buy button
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
                        color:
                            canAfford ? Colors.orange[700] : Colors.red[400],
                      ),
                    ),
                  ],
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
    );
  }

  Widget _buildRoomComponentGrid(List<RoomComponent> components, AppLocalizationsProvider l10n, String language) {
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

  Widget _buildRoomComponentCard(RoomComponent component, AppLocalizationsProvider l10n, String language) {
    final canAfford = widget.gameState.coins >= component.cost;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
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
          // Info + buy button
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.localizedName(language),
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
                      '${component.cost}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color:
                            canAfford ? Colors.orange[700] : Colors.red[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAfford ? () => _buyRoomComponent(component) : null,
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

  IconData _categoryIcon(ItemType? type) {
    switch (type) {
      case ItemType.furniture:
        return Icons.chair;
      case ItemType.decoration:
        return Icons.local_florist;
      case ItemType.door:
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
    switch (key) {
      case 'all':
        return l10n.currentLanguage == 'sk' ? 'Všetko' : 'All';
      case 'furniture':
        return l10n.translate('furniture');
      case 'decoration':
        return l10n.currentLanguage == 'sk' ? 'Dekor' : 'Decor';
      case 'doors':
        return l10n.currentLanguage == 'sk' ? 'Dvere' : 'Doors';
      case 'walls':
        return l10n.currentLanguage == 'sk' ? 'Steny' : 'Walls';
      case 'floors':
        return l10n.currentLanguage == 'sk' ? 'Podlahy' : 'Floors';
      default:
        return key;
    }
  }
}

class _Category {
  final String labelKey;
  final ItemType? itemType;
  final bool isRoomComponent;
  final RoomComponentType? componentType;

  const _Category({
    required this.labelKey,
    this.itemType,
    this.isRoomComponent = false,
    this.componentType,
  });
}