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
    name: 'Sivý mramor',
    nameEn: 'Grey Marble Floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_grey_marble.png',
    cost: 0, // Example cost
  ),

  RoomComponent(
    id: 'floor_grey_parquets',
    name: 'Sivé parkety',
    nameEn: 'Grey Parquet Floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_grey_parquets.png',
    cost: 0, // Example cost
  ),

  RoomComponent(
    id: 'floor_parquets',
    name: 'Parkety',
    nameEn: 'Parquet Floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_parquets.png',
    cost: 0, // Example cost
  ),

  RoomComponent(
    id: 'floor_aqua_hexagons',
    name: 'Hexagonová podlaha',
    nameEn: 'Aqua Hexagons',
    type: RoomComponentType.floor,
    texture: 'room/floor_aqua_hexagons.png',
    cost: 0, // Example cost
  ),

  RoomComponent(
    id: 'floor_basic',
    name: 'Základná podlaha',
    nameEn: 'Basic Floor',
    type: RoomComponentType.floor,
    texture: 'room/basic_floor.png',
    cost: 0, // Starting floor is free (default)
  ),
  RoomComponent(
    id: 'floor_wood_squares',
    name: 'Drevené dlaždice',
    nameEn: 'Wooden Squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood_squares.png',
    cost: 0, // Starting floor is free (default)
  ),

  RoomComponent(
    id: 'floor_bloody_marble',
    name: 'Červenkastý mramor',
    nameEn: 'Redish Marble',
    type: RoomComponentType.floor,
    texture: 'room/floor_bloody_marble.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_magic_stones',
    name: 'Magické kamene',
    nameEn: 'Magic Stones',
    type: RoomComponentType.floor,
    texture: 'room/floor_magic_stones.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_magic_stone_runes',
    name: 'Magické kamene s runami',
    nameEn: 'Magic Stones with Runes',
    type: RoomComponentType.floor,
    texture: 'room/floor_magic_stone_runes.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_ruined1',
    name: 'Zničená podlaha 1',
    nameEn: 'Ruined Floor 1',
    type: RoomComponentType.floor,
    texture: 'room/floor_ruined1.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_ruined2',
    name: 'Zničená podlaha 2',
    nameEn: 'Ruined Floor 2',
    type: RoomComponentType.floor,
    texture: 'room/floor_ruined2.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_wood',
    name: 'Drevená podlaha',
    nameEn: 'Wood Floor',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_blueNwhite_squares',
    name: 'Modré a biele dlaždice',
    nameEn: 'Blue and White Squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_blueNwhite_squares.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_cat_disco',
    name: 'Mačacia disko',
    nameEn: 'Cat Disco',
    type: RoomComponentType.floor,
    texture: 'room/floor_cat_disco.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_blackNwhite_squares',
    name: 'Čierno-biele dlaždice',
    nameEn: 'Black and White Squares',
    type: RoomComponentType.floor,
    texture: 'room/floor_blackNwhite_squares.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_crossing_parquets',
    name: 'Prekrížené parkety',
    nameEn: 'Crossed Parquets',
    type: RoomComponentType.floor,
    texture: 'room/floor_crossing_parquets.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_crossing_parquets_dark',
    name: 'Prekrížené parkety - tmavé',
    nameEn: 'Crossed Parquets Dark',
    type: RoomComponentType.floor,
    texture: 'room/floor_crossing_parquets_dark.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_grey_hexagons',
    name: 'Sivé hexagóny',
    nameEn: 'Grey Hexagons',
    type: RoomComponentType.floor,
    texture: 'room/floor_grey_hexagons.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_magic_stones2',
    name: 'Magické kamene 2',
    nameEn: 'Magic Stones 2',
    type: RoomComponentType.floor,
    texture: 'room/floor_magic_stones2.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_wood2',
    name: 'Drevená podlaha 2',
    nameEn: 'Wood Floor 2',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood2.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_wood3',
    name: 'Drevená podlaha 3',
    nameEn: 'Wood Floor 3',
    type: RoomComponentType.floor,
    texture: 'room/floor_wood3.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_zigzag_parquets',
    name: 'Cikcak parkety',
    nameEn: 'Zigzag Parquets',
    type: RoomComponentType.floor,
    texture: 'room/floor_zigzag_parquets.png',
    cost: 0,
  ),

  RoomComponent(
    id: 'floor_zigzag_parquets_lightbrown',
    name: 'Cikcak parkety - svetlohneď',
    nameEn: 'Zigzag Parquets Light Brown',
    type: RoomComponentType.floor,
    texture: 'room/floor_zigzag_parquets_lightbrown.png',
    cost: 0,
  ),
];
