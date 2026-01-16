import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import 'package:uuid/uuid.dart';

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

  // Test furniture items
  final List<Item> furnitureItems = [
    Item(
      id: const Uuid().v4(),
      name: 'Cat Friend',
      type: ItemType.furniture,
      texture: '',
      cost: 50,
    ),
    Item(
      id: const Uuid().v4(),
      name: 'Alien Statue',
      type: ItemType.furniture,
      texture: '',
      cost: 75,
    ),
    Item(
      id: const Uuid().v4(),
      name: 'House Model',
      type: ItemType.decoration,
      texture: '',
      cost: 100,
    ),
    Item(
      id: const Uuid().v4(),
      name: 'Room Poster',
      type: ItemType.decoration,
      texture: '',
      cost: 30,
    ),
  ];

  // Real Estate items - empty for now
  final List<Item> realEstateItems = [];

  void _buyItem(Item item) {
    if (widget.gameState.coins >= item.cost) {
      widget.gameState.spendCoins(item.cost);
      widget.gameState.addOwnedItem(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} purchased for ${item.cost} coins!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! Need ${item.cost}, have ${widget.gameState.coins}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
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
                        'Furniture',
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
                        'Real Estate',
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
            child: _selectedCategory == 0
                ? _buildFurnitureCategory()
                : _buildRealEstateCategory(),
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureCategory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: furnitureItems.length,
      itemBuilder: (context, index) {
        final item = furnitureItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.chair,
                  size: 40,
                  color: Colors.orange[400],
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
                  label: const Text('Buy'),
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

  Widget _buildRealEstateCategory() {
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