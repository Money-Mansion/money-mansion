import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/shop_item.dart';

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
  ItemCategory selectedCategory = ItemCategory.furniture;

  // Nábytok
  final List<ShopItem> furnitureItems = [
    ShopItem(
      id: 'sofa_1',
      name: 'Moderná pohovka',
      description: 'Komfortná pohovka do obývačky',
      cost: 500,
      category: ItemCategory.furniture,
      icon: '🛋️',
    ),
    ShopItem(
      id: 'table_1',
      name: 'Jedálenský stôl',
      description: 'Priestranný stôl pre rodinu',
      cost: 300,
      category: ItemCategory.furniture,
      icon: '🪑',
    ),
    ShopItem(
      id: 'lamp_1',
      name: 'Krásna lampa',
      description: 'Dekoratívna lampa do izby',
      cost: 150,
      category: ItemCategory.furniture,
      icon: '💡',
    ),
    ShopItem(
      id: 'bed_1',
      name: 'Kráľovská posteľ',
      description: 'Luxusná posteľ pre kľud',
      cost: 800,
      category: ItemCategory.furniture,
      icon: '🛏️',
    ),
    ShopItem(
      id: 'cabinet_1',
      name: 'Skrín',
      description: 'Priestranná skrín na oblečenie',
      cost: 400,
      category: ItemCategory.furniture,
      icon: '🚪',
    ),
  ];

  // Nehnuteľnosti
  final List<ShopItem> realEstateItems = [
    ShopItem(
      id: 'house_1',
      name: 'Skladový priestor',
      description: 'Extra priestor na uskladnenie',
      cost: 2000,
      category: ItemCategory.realEstate,
      icon: '🏠',
    ),
    ShopItem(
      id: 'house_2',
      name: 'Garáž',
      description: 'Priestor na auto',
      cost: 3000,
      category: ItemCategory.realEstate,
      icon: '🚗',
    ),
    ShopItem(
      id: 'house_3',
      name: 'Zahrada',
      description: 'Krásna záhrada s plotom',
      cost: 1500,
      category: ItemCategory.realEstate,
      icon: '🌳',
    ),
    ShopItem(
      id: 'house_4',
      name: 'Balkón',
      description: 'Útulný balkón s výhľadom',
      cost: 1000,
      category: ItemCategory.realEstate,
      icon: '🪟',
    ),
    ShopItem(
      id: 'house_5',
      name: 'Terasa',
      description: 'Spaciózna terasa na posedenie',
      cost: 2500,
      category: ItemCategory.realEstate,
      icon: '🏡',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final itemsToDisplay = selectedCategory == ItemCategory.furniture
        ? furnitureItems
        : realEstateItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        backgroundColor: Colors.deepOrange[300],
        centerTitle: true,
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          // Category Tabs
          Container(
            color: Colors.deepOrange[50],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _buildCategoryButton(
                  label: '🛋️ Nábytok',
                  category: ItemCategory.furniture,
                  isSelected: selectedCategory == ItemCategory.furniture,
                  onTap: () {
                    setState(() {
                      selectedCategory = ItemCategory.furniture;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildCategoryButton(
                  label: '🏠 Nehnuteľnosti',
                  category: ItemCategory.realEstate,
                  isSelected: selectedCategory == ItemCategory.realEstate,
                  onTap: () {
                    setState(() {
                      selectedCategory = ItemCategory.realEstate;
                    });
                  },
                ),
              ],
            ),
          ),
          // Items List
          Expanded(
            child: itemsToDisplay.isEmpty
                ? Center(
                    child: Text(
                      'Žiadne položky',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: itemsToDisplay.length,
                    itemBuilder: (context, index) {
                      final item = itemsToDisplay[index];
                      return _buildItemCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required String label,
    required ItemCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepOrange[400] : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.deepOrange[400],
          side: BorderSide(
            color: Colors.deepOrange[400]!,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(ShopItem item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showPurchaseDialog(item);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange[50]!, Colors.orange[100]!],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Text(
                item.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              // Content
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
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${item.cost}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Buy Button
              ElevatedButton(
                onPressed: () {
                  _buyItem(item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  minimumSize: const Size(60, 40),
                ),
                child: const Text(
                  'Kúpiť',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                item.icon,
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cena:'),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 20),
                          Text('${item.cost} mincí'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Máš:'),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 20),
                          Text('${widget.gameState.coins} mincí'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _buyItem(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
            ),
            child: const Text('Kúpiť'),
          ),
        ],
      ),
    );
  }

  void _buyItem(ShopItem item) {
    if (widget.gameState.coins >= item.cost) {
      widget.gameState.spendCoins(item.cost);
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ ${item.name} kúpené! Zostáva ti ${widget.gameState.coins} mincí',
          ),
          backgroundColor: Colors.green[400],
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nemáš dosť mincí! Potrebuješ ešte ${item.cost - widget.gameState.coins} mincí',
          ),
          backgroundColor: Colors.red[400],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}