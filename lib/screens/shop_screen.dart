import 'package:flutter/material.dart';
import '../models/game_state.dart';

class ShopScreen extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const ShopScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        leading: IconButton(
          key: const Key('back_button'),
          icon: Icon(Icons.arrow_back),
          onPressed: onBack, // Use the callback instead of Navigator.pop
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Shop',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Furniture, upgrades, and decorations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}