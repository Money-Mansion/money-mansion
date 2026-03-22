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
    id: 'dvere_biele',
    name: 'Biele Dvere',
    type: ItemType.door,
    texture: 'assets/images/items/dvere_biele.png',
    cost: 0,
    hitboxId: null,
    scale: 0.2,
  ),

  Item(
    id: 'posteľ_základná',
    name: 'Základná posteľ',
    type: ItemType.furniture,
    texture: 'assets/images/items/posteľ_základná.png',
    cost: 0,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'kvietok_s_chrumkom',
    name: 'Chrumko na kvietku',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_s_chrumkom.png',
    cost: 55,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'obraz_s_chrumkom',
    name: 'Chrumko v obraze',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_s_chrumkom.png',
    cost: 75,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'kvietok_alien',
    name: 'Mimozemsky kvietok',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_alien.png',
    cost: 50,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'kvietok_y',
    name: 'Kvietky',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_y.png',
    cost: 50,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'kvietok_ruzovy',
    name: 'Ruzovy kvietok',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_ruzovy.png',
    cost: 50,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'posteľ_dievčenská',
    name: 'Dievčenská posteľ',
    type: ItemType.furniture,
    texture: 'assets/images/items/posteľ_dievčenská.png',
    cost: 300,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'skriňa_šatník',
    name: 'Šatník',
    type: ItemType.furniture,
    texture: 'assets/images/items/skriňa_šatník.png',
    cost: 175,
    hitboxId: null,
    scale: 1.0,
  ),

  Item(
    id: 'skriňa_knihy',
    name: 'Knihovňa',
    type: ItemType.furniture,
    texture: 'assets/images/items/skriňa_knihy.png',
    cost: 200,
    hitboxId: null,
    scale: 1.0,
  ),

  // ADD YOUR ITEMS BELOW THIS LINE
  // Follow the format above. Each item needs:
  // - id: unique identifier (lowercase, underscores, no spaces)
  // - name: display name shown to players
  // - type: category (door, window, furniture, flooring, wallpaper, decoration)
  // - texture: path to PNG file in assets/images/
  // - cost: coin price in shop
  // - hitboxId: (optional) ID of hitbox file to load (defaults to item id)
  // - scale: (optional) render scale factor, default 1.0
];
