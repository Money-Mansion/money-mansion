import '../models/item.dart';

/// Centralized list of all items in the game.
/// Add new items here. They will be automatically loaded when the app starts.
final List<Item> GAME_ITEMS = [
  // Example item - DELETE THIS AFTER TESTING
  Item(
    id: 'basic_door',
    name: 'Basic Door',
    type: ItemType.door,
    texture: 'assets/images/basic_door.png',
    cost: 1,
    owned: false,
  ),

  // ADD YOUR ITEMS BELOW THIS LINE
  // Follow the format above. Each item needs:
  // - id: unique identifier (lowercase, underscores, no spaces)
  // - name: display name shown to players
  // - type: category (door, window, furniture, flooring, wallpaper, decoration)
  // - texture: path to PNG file in assets/images/
  // - cost: coin price in shop
  // - owned: false (items start as not owned, player buys them)
];
