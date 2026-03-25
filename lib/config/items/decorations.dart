import '../../models/item.dart';

/// Decoration items - paintings, shelves, cabinets, plants, etc.
final List<Item> decorationItems = [
  // Library Shelves
  Item(
    id: 'polica_kniznica_cierna',
    name: 'Čierna knižnica',
    type: ItemType.decoration,
    texture: 'assets/images/items/polica_kniznica_cierna.png',
    cost: 0,
    hitboxId: null,
    scale: 0.14,
  ),

  // Basic Shelves
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

  // Cabinet/Storage
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

  // Beds (decorative)
  Item(
    id: 'posteľ_zámok',
    name: 'Posteľ na zámku',
    type: ItemType.decoration,
    texture: 'assets/images/items/posteľ_zámok.png',
    cost: 0,
    hitboxId: null,
    scale: 0.17,
  ),

  // Windows/Mirrors
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
    id: 'okno_zrkadlo',
    name: 'Zrkadlo',
    type: ItemType.decoration,
    texture: 'assets/images/items/okno_zrkadlo.png',
    cost: 0,
    hitboxId: 'obraz',
    scale: 0.11,
  ),

  // Paintings
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
    id: 'obraz_s_chrumkom',
    name: 'Chrumko v obraze',
    type: ItemType.decoration,
    texture: 'assets/images/items/obraz_s_chrumkom.png',
    cost: 75,
    hitboxId: null,
    scale: 0.11,
  ),

  // Flowers/Plants
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
];
