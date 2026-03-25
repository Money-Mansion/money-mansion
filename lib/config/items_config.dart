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
    id: 'polica_kniznica_cierna',
    name: 'Čierna knižnica',
    type: ItemType.decoration,
    texture: 'assets/images/items/polica_kniznica_cierna.png',
    cost: 0,
    hitboxId: null,
    scale: 0.11,
  ),

  Item(
    id: 'okno_zrkadlo',
    name: 'Zrkadlo',
    type: ItemType.decoration,
    texture: 'assets/images/items/okno_zrkadlo.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'okno_normalne',
    name: 'Normálne okno',
    type: ItemType.decoration,
    texture: 'assets/images/items/okno_normalne.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'okno_modre',
    name: 'Modré okno',
    type: ItemType.decoration,
    texture: 'assets/images/items/okno_modre.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'okno_duhove',
    name: 'Duhové okno',
    type: ItemType.decoration,
    texture: 'assets/images/items/okno_duhove.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'okno_cierne',
    name: 'Čierne okno',
    type: ItemType.decoration,
    texture: 'assets/images/items/okno_cierne.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'obraz_tvary',
    name: 'Obraz s tvarmi',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_tvary.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'obraz_stastne_zvieratka',
    name: 'Obraz so šťastnými zvieratkami',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_stastne_zvieratka.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'obraz_skibidi',
    name: 'Skibidi obraz',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_skibidi.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'obraz_salvador_dali',
    name: 'Obraz Salvadora Daliho',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_salvador_dali.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'obraz_nastenka',
    name: 'Nástenka',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_nastenka.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'obraz_drak',
    name: 'Obraz draka',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_drak.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  Item(
    id: 'gauc_zeleny',
    name: 'Zelený gauč',
    type: ItemType.furniture,
    texture: 'assets/images/items/gauc_zeleny.png',
    cost: 0,
    hitboxId: 'gauc',
    scale: 0.185,
  ),

  Item(
    id: 'gauc_ruzovy',
    name: 'Ružový gauč',
    type: ItemType.furniture,
    texture: 'assets/images/items/gauc_ruzovy.png',
    cost: 0,
    hitboxId: 'gauc',
    scale: 0.185,
  ),

  Item(
    id: 'gauc_ruzovy_oblacik',
    name: 'Gauč ružový obláčik',
    type: ItemType.furniture,
    texture: 'assets/images/items/gauc_ruzovy_oblacik.png',
    cost: 0,
    hitboxId: 'gauc',
    scale: 0.185,
  ),

  Item(
    id: 'gauc_modry',
    name: 'Modrý gauč',
    type: ItemType.furniture,
    texture: 'assets/images/items/gauc_modry.png',
    cost: 0,
    hitboxId: 'gauc',
    scale: 0.185,
  ),

  Item(
    id: 'gauc_modry_oblacik',
    name: 'Gauč modrý obláčik',
    type: ItemType.furniture,
    texture: 'assets/images/items/gauc_modry_oblacik.png',
    cost: 0,
    hitboxId: 'gauc',
    scale: 0.185,
  ),

  Item(
    id: 'gauc_dreveny',
    name: 'Drevený gáuč',
    type: ItemType.furniture,
    texture: 'assets/images/items/gauc_dreveny.png',
    cost: 0,
    hitboxId: 'gauc',
    scale: 0.185,
  ),

  Item(
    id: 'skriňa_rohová',
    name: 'Rohová skriňa',
    type: ItemType.decoration,
    texture: 'assets/images/items/skriňa_rohová.png',
    cost: 0,
    hitboxId: null,
    scale: 0.17,
  ),

  Item(
    id: 'skriňa_poličky',
    name: 'Skriňa s poličkami',
    type: ItemType.decoration,
    texture: 'assets/images/items/skriňa_poličky.png',
    cost: 0,
    hitboxId: null,
    scale: 0.15,
  ),

  Item(
    id: 'skriňa_nízka',
    name: 'Nízká skriňa',
    type: ItemType.decoration,
    texture: 'assets/images/items/skriňa_nízka.png',
    cost: 0,
    hitboxId: null,
    scale: 0.125,
  ),

  Item(
    id: 'posteľ_zámok',
    name: 'Posteľ na zámku',
    type: ItemType.decoration,
    texture: 'assets/images/items/posteľ_zámok.png',
    cost: 0,
    hitboxId: null,
    scale: 0.17,
  ),

  Item(
    id: 'polica',
    name: 'Basic polica',
    type: ItemType.decoration,
    texture: 'assets/images/items/polica.png',
    cost: 0,
    hitboxId: null,
    scale: 0.125,
  ),

  Item(
    id: 'polica_dizajnová',
    name: 'Dizajnová polica',
    type: ItemType.decoration,
    texture: 'assets/images/items/polica_dizajnová.png',
    cost: 0,
    hitboxId: null,
    scale: 0.13,
  ),
  
  Item(
    id: 'obraz_aliens',
    name: 'Obraz s mimozemšťanom',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_aliens.png',
    cost: 0,
    hitboxId: null,
    scale: 0.11,
  ),

  Item(
    id: 'obraz_poník',
    name: 'Obraz s poníkom',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_poník.png',
    cost: 0,
    hitboxId: null,
    scale: 0.11,
  ),

  Item(
    id: 'dvere_biele',
    name: 'Biele Dvere',
    type: ItemType.door,
    texture: 'assets/images/items/dvere_biele.png',
    cost: 0,
    hitboxId: null,
    scale: 0.11,
  ),

  Item(
    id: 'posteľ_základná',
    name: 'Základná posteľ',
    type: ItemType.furniture,
    texture: 'assets/images/items/posteľ_základná.png',
    cost: 0,
    hitboxId: null,
    scale: 0.17,
  ),

  Item(
    id: 'kvietok_s_chrumkom',
    name: 'Chrumko na kvietku',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_s_chrumkom.png',
    cost: 55,
    hitboxId: null,
    scale: 0.15,
  ),

  Item(
    id: 'obraz_s_chrumkom',
    name: 'Chrumko v obraze',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_s_chrumkom.png',
    cost: 75,
    hitboxId: null,
    scale: 0.11,
  ),

  Item(
    id: 'kvietok_alien',
    name: 'Mimozemsky kvietok',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_alien.png',
    cost: 50,
    hitboxId: null,
    scale: 0.12,
  ),

  Item(
    id: 'kvietok_y',
    name: 'Kvietky',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_y.png',
    cost: 50,
    hitboxId: null,
    scale: 0.15,
  ),

  Item(
    id: 'kvietok_ruzovy',
    name: 'Ruzovy kvietok',
    type: ItemType.decoration,
    texture: 'assets/images/items/kvietok_ruzovy.png',
    cost: 50,
    hitboxId: null,
    scale: 0.15,
  ),

  Item(
    id: 'posteľ_dievčenská',
    name: 'Dievčenská posteľ',
    type: ItemType.furniture,
    texture: 'assets/images/items/posteľ_dievčenská.png',
    cost: 300,
    hitboxId: null,
    scale: 0.17,
  ),

  Item(
    id: 'skriňa_šatník',
    name: 'Šatník',
    type: ItemType.furniture,
    texture: 'assets/images/items/skriňa_šatník.png',
    cost: 175,
    hitboxId: null,
    scale: 0.2,
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
