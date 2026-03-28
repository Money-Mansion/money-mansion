import '../models/item.dart';
import 'items/doors.dart';
import 'items/furniture.dart';
import 'items/decorations.dart';
import 'items/carpets.dart';
import 'items/tables.dart';

/// Centralized list of all available items in the game.
/// 
/// Items are organized by category in separate files:
/// - doors.dart: Door items
/// - furniture.dart: Furniture (sofas, beds, wardrobes)
/// - decorations.dart: Decorations (paintings, shelves, plants, etc.)
/// - carpets.dart: Carpets and rugs
/// - tables.dart: Tables and desks
///
/// When a player purchases an item, it's added to the owned_items database table.
/// The owned_items table is the source of truth for what the player owns.
/// ShopScreen will filter these out (showing only items NOT in owned_items).
/// 
/// To add new items:
/// 1. Create or edit a category file (doors.dart, furniture.dart, decorations.dart, etc.)
/// 2. Add your Item to the appropriate list
/// 3. Update asset paths to point to the correct subdirectory
/// 4. The item will automatically appear in GAME_ITEMS
final List<Item> GAME_ITEMS = [
  ...doorItems,
  ...furnitureItems,
  ...decorationItems,
  ...carpetItems,  ...tableItems,];
