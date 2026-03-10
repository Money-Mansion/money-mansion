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

class _ShopScreenState extends State<ShopScreen> {
  int _selectedCategory = 0; // 0 = Furniture, 1 = Real Estate
  List<Item> _shopItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopItems();
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
      
      // Add to database
      await ShopService.buyItem(item.id);
      
      // Reload shop items
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

  List<Item> _getItemsByCategory(int category) {
    if (category == 0) {
      // Furniture category - show all items for now
      return _shopItems;
    } else {
      // Real Estate - empty for now
      return [];
    }
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
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedCategory == 0
                                ? Colors.deepPurple
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n.translate('furniture'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedCategory == 0
                              ? Colors.deepPurple
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedCategory == 1
                                ? Colors.deepPurple
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n.translate('realEstate'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedCategory == 1
                              ? Colors.deepPurple
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedCategory == 0
                    ? _buildFurnitureCategory(l10n)
                    : _buildRealEstateCategory(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureCategory(AppLocalizationsProvider l10n) {
    final items = _getItemsByCategory(0);
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No items available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You own all available items!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Image.asset(
                    item.texture,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.cost} coins',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _buyItem(item),
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(l10n.translate('buy')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealEstateCategory(AppLocalizationsProvider l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: 64,
            color: Colors.blue[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Real Estate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
