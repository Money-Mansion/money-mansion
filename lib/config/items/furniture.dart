import '../../models/item.dart';

/// Furniture items - sofas, beds, cabinets, wardrobes
final List<Item> furnitureItems = [
  // Sofas/Couches
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

  // Beds
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
    id: 'posteľ_dievčenská',
    name: 'Dievčenská posteľ',
    type: ItemType.furniture,
    texture: 'assets/images/items/posteľ_dievčenská.png',
    cost: 300,
    hitboxId: null,
    scale: 0.17,
  ),

  // Wardrobes
  Item(
    id: 'skriňa_šatník',
    name: 'Šatník',
    type: ItemType.furniture,
    texture: 'assets/images/items/skriňa_šatník.png',
    cost: 175,
    hitboxId: null,
    scale: 0.2,
  ),
];
