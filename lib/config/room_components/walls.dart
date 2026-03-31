import '../../models/room_component.dart';

/// Wall components available for purchase in the shop.
/// 
/// Each wall has:
/// - id: unique identifier (e.g., 'wall_basic')
/// - name: Slovak display name
/// - nameEn: English display name
/// - type: RoomComponentType.wall
/// - texture: path to the right wall sprite (left wall auto-flips)
/// - cost: coins required to purchase (0 = free/default)

final List<RoomComponent> wallComponents = [
  RoomComponent(
    id: 'wall_sky',
    name: 'Stena obloha',
    nameEn: 'Sky Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_sky.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_leafs',
    name: 'Lístie',
    nameEn: 'Leaf Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_leafs.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_rainbow',
    name: 'Stena s poníkmi',
    nameEn: 'Rainbow Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_rainbow.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_bricks',
    name: 'Múr',
    nameEn: 'Bricks',
    type: RoomComponentType.wall,
    texture: 'room/wall_bricks.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_salvador_dali',
    name: 'Stena Salvadora Daliho',
    nameEn: 'Salvador Dali Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_salvador_dali.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_bricks_3d',
    name: 'Stena s tehlami',
    nameEn: 'Bricks Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_bricks_3d.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_donuts',
    name: 'Stena s donutmi',
    nameEn: 'Donut Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_donuts.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_waterfall',
    name: 'Stena s vodopádom',
    nameEn: 'Waterfall Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_waterfall.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_sky_animals',
    name: 'Stena so zvieratkami na obláčikoch',
    nameEn: 'Sky Animals Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_sky_animals.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_greenish_wallpaper',
    name: 'Stena so zelenou tapetou',
    nameEn: 'Greenish Wallpaper Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_greenish_wallpaper.png',
    cost: 0, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_basic',
    name: 'Základná stena',
    nameEn: 'Basic Wall',
    type: RoomComponentType.wall,
    texture: 'room/basic_right_wall.png',
    cost: 0, // Starting wall is free (default)
  ),
  RoomComponent(
    id: 'wall_triangles',
    name: 'Stena s trojuholníkmi',
    nameEn: 'Triangle Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_triangles.png',
    cost: 0, // Starting wall is free (default)
  ),
];
