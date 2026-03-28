import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../services/shop_service.dart';
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
  bool _isLoading = true;
  late TabController _tabController;

  // Category definitions — label key + optional ItemType filter (null = All)
  static const List<_Category> _categories = [
    _Category(labelKey: 'all', type: null),
    _Category(labelKey: 'furniture', type: ItemType.furniture),
    _Category(labelKey: 'decoration', type: ItemType.decoration),
    _Category(labelKey: 'doors', type: ItemType.door),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadShopItems();
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

  List<Item> _itemsForCategory(_Category category) {
    if (category.type == null) return _shopItems; // All
    return _shopItems.where((i) => i.type == category.type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('shop')),
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(Icons.arrow_back),
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
                  Icon(_categoryIcon(cat.type), size: 16),
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
                return _buildItemGrid(items, l10n);
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
            Icon(Icons.shopping_bag, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.translate('noItemsYet'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You own all items in this category!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // Aim for cards ~130px wide — more columns on wider screens
    final crossAxisCount = (screenWidth / 130).floor().clamp(2, 6);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.68,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItemCard(items[index], l10n),
    );
  }

  Widget _buildItemCard(Item item, AppLocalizationsProvider l10n) {
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
                  item.name,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
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
                        color: canAfford ? Colors.orange[700] : Colors.red[400],
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

  String _categoryLabel(String key, AppLocalizationsProvider l10n) {
    switch (key) {
      case 'all':
        return 'All';
      case 'furniture':
        return l10n.translate('furniture');
      case 'decoration':
        return 'Decor';
      case 'doors':
        return 'Doors';
      default:
        return key;
    }
  }
}

// Simple data class for category definitions
class _Category {
  final String labelKey;
  final ItemType? type;
  const _Category({required this.labelKey, required this.type});
}