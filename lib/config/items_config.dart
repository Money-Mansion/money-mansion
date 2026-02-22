import '../models/item.dart';

/// Centralized list of all available items in the game.
/// Add new items here - they will appear in the shop by default.
/// 
/// When a player purchases an item, it's added to the owned_items database table.
/// The owned_items table is the source of truth for what the player owns.
/// ShopScreen will filter these out (showing only items NOT in owned_items).
final List<Item> GAME_ITEMS = [
  // Example item - DELETE THIS AFTER TESTING
  Item(
    id: 'basic_door',
    name: 'Basic Door',
    type: ItemType.door,
    texture: 'assets/images/basic_door.png',
    cost: 0,
  ),

  // ADD YOUR ITEMS BELOW THIS LINE
  // Follow the format above. Each item needs:
  // - id: unique identifier (lowercase, underscores, no spaces)
  // - name: display name shown to players
  // - type: category (door, window, furniture, flooring, wallpaper, decoration)
  // - texture: path to PNG file in assets/images/
  // - cost: coin price in shop
];
