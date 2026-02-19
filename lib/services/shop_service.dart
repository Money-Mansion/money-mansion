import '../config/items_config.dart';
import '../models/item.dart';
import 'item_database_service.dart';

/// Handles shop logic including filtering items for sale
class ShopService {
  /// Get items available for purchase (config items minus owned items)
  static Future<List<Item>> getShopItems() async {
    final ownedItems = await ItemDatabaseService.getOwnedItems();
    final ownedIds = ownedItems.map((item) => item.id).toSet();
    
    // Return config items that are NOT owned
    return GAME_ITEMS.where((item) => !ownedIds.contains(item.id)).toList();
  }

  /// Get item details by ID from config
  static Item? getItemById(String itemId) {
    try {
      return GAME_ITEMS.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Handle item purchase: spend coins and add to owned items
  static Future<bool> buyItem(String itemId) async {
    final item = getItemById(itemId);
    if (item == null) {
      print('Item not found: $itemId');
      return false;
    }

    // Add to owned items in database
    return await ItemDatabaseService.addOwnedItem(item);
  }
}
