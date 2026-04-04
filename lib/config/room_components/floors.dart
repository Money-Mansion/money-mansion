import '../../models/room_component.dart';

/// Floor components available for purchase in the shop.
/// 
/// Each floor has:
/// - id: unique identifier (e.g., 'floor_basic')
/// - name: Slovak display name
/// - nameEn: English display name
/// - type: RoomComponentType.floor
/// - texture: path to the floor sprite
/// - cost: coins required to purchase (0 = free/default)

final List<RoomComponent> floorComponents = [
  RoomComponent(
    id: 'floor_grey_marble',
    name: 'sivý mramor',
    nameEn: 'grey marble floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_grey_marble.png',
    cost: 70, // Example cost
  ),

  RoomComponent(
    id: 'floor_grey_parquets',
    name: 'prekrížené svetlo-sivé parkety',
    nameEn: 'crossed light grey parquets',
    type: RoomComponentType.floor,
    texture: 'room/floor_grey_parquets.png',
    cost: 70, // Example cost
  ),

  RoomComponent(
    id: 'floor_parquets',
    name: 'dubové drevo parkety',
    nameEn: 'oak wood parquet floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_parquets.png',
    cost: 70, // Example cost
  ),

  RoomComponent(
    id: 'floor_aqua_hexagons',
    name: 'modrá hexagonová podlaha',
    nameEn: 'aqua hexagon floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_aqua_hexagons.png',
    cost: 70, // Example cost
  ),

  RoomComponent(
    id: 'floor_basic',
    name: 'klasická podlaha',
    nameEn: 'basic Floor',
    type: RoomComponentType.floor,
    texture: 'room/basic_floor.png',
    cost: 70, // Starting floor is free (default)
  ),
  RoomComponent(
    id: 'floor_wood_squares',
    name: 'drevené dlaždice',
    nameEn: 'wooden Squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood_squares.png',
    cost: 70, // Starting floor is free (default)
  ),

  RoomComponent(
    id: 'floor_bloody_marble',
    name: 'červený mramor',
    nameEn: 'red marble',
    type: RoomComponentType.floor,
    texture: 'room/floor_bloody_marble.png',
    cost: 80,
  ),

  RoomComponent(
    id: 'floor_magic_stones',
    name: 'magické kamene',
    nameEn: 'magic stones',
    type: RoomComponentType.floor,
    texture: 'room/floor_magic_stones.png',
    cost: 100,
  ),

  RoomComponent(
    id: 'floor_magic_stone_runes',
    name: 'magické kamene s runami',
    nameEn: 'magic stones with runes',
    type: RoomComponentType.floor,
    texture: 'room/floor_magic_stone_runes.png',
    cost: 120,
  ),

  RoomComponent(
    id: 'floor_ruined1',
    name: 'zničená podlaha 1',
    nameEn: 'ruined Floor 1',
    type: RoomComponentType.floor,
    texture: 'room/floor_ruined1.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_ruined2',
    name: 'zničená podlaha 2',
    nameEn: 'ruined Floor 2',
    type: RoomComponentType.floor,
    texture: 'room/floor_ruined2.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_wood',
    name: 'drevená podlaha orechové drevo',
    nameEn: 'wood floor walnut wood',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_blueNwhite_squares',
    name: 'modré a biele dlaždice',
    nameEn: 'blue and white squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_blueNwhite_squares.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_cat_disco',
    name: 'mačacie dlaždice',
    nameEn: 'cat squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_cat_disco.png',
    cost: 80,
  ),

  RoomComponent(
    id: 'floor_blackNwhite_squares',
    name: 'čierno-biele dlaždice',
    nameEn: 'black and white squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_blackNwhite_squares.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_crossing_parquets',
    name: 'prekrížené sivé parkety',
    nameEn: 'crossed grey parquets',
    type: RoomComponentType.floor,
    texture: 'room/floor_crossing_parquets.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_crossing_parquets_dark',
    name: 'prekrížené tmavo-sivé parkety',
    nameEn: 'crossed dark grey parquets',
    type: RoomComponentType.floor,
    texture: 'room/floor_crossing_parquets_dark.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_grey_hexagons',
    name: 'sivá hexagonová podlaha',
    nameEn: 'grey hexagon floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_grey_hexagons.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_magic_stones2',
    name: 'magické kamene 2',
    nameEn: 'magic stones 2',
    type: RoomComponentType.floor,
    texture: 'room/floor_magic_stones2.png',
    cost: 100,
  ),

  RoomComponent(
    id: 'floor_wood2',
    name: 'drevená podlaha čerešňové drevo',
    nameEn: 'wood floor cherry wood',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood2.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_wood3',
    name: 'drevená podlaha dubové drevo',
    nameEn: 'wood floor oak wood',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood3.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_zigzag_parquets',
    name: 'orechové drevo parkety',
    nameEn: 'walnut wood parquet floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_zigzag_parquets.png',
    cost: 70,
  ),

  RoomComponent(
    id: 'floor_zigzag_parquets_lightbrown',
    name: 'javorové drevo parkety',
    nameEn: 'maple wood parquet floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_zigzag_parquets_lightbrown.png',
    cost: 70,
  ),
];
