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
    name: 'stena obloha',
    nameEn: 'sky Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_sky.png',
    cost: 100, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_leafs',
    name: 'stena lístie',
    nameEn: 'leaf wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_leafs.png',
    cost: 100, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_rainbow',
    name: 'stena s poníkmi',
    nameEn: 'pony wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_rainbow.png',
    cost: 110, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_bricks',
    name: 'tehlová stena',
    nameEn: 'brick wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_bricks.png',
    cost: 110, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_salvador_dali',
    name: 'stena Salvador Dali',
    nameEn: 'Salvador Dali Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_salvador_dali.png',
    cost: 120, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_bricks_3d',
    name: 'tehlový múr',
    nameEn: '3D brick wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_bricks_3d.png',
    cost: 110, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_donuts',
    name: 'stena s donutmi',
    nameEn: 'donut Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_donuts.png',
    cost: 100, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_waterfall',
    name: 'stena s vodopádom',
    nameEn: 'waterfall wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_waterfall.png',
    cost: 120, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_sky_animals',
    name: 'stena so zvieratkami',
    nameEn: 'animals wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_sky_animals.png',
    cost: 110, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_greenish_wallpaper',
    name: 'stena so zelenou tapetou',
    nameEn: 'green wallpaper wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_greenish_wallpaper.png',
    cost: 110, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_basic',
    name: 'klasická stena',
    nameEn: 'basic Wall',
    type: RoomComponentType.wall,
    texture: 'room/basic_right_wall.png',
    cost: 0, // Starting wall is free (default)
  ),
  RoomComponent(
    id: 'wall_triangles',
    name: 'čierna stena s trojuholníkmi',
    nameEn: 'triangle Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_triangles.png',
    cost: 100, // Starting wall is free (default)
  ),

  RoomComponent(
    id: 'wall_ancient',
    name: 'starožitná stena',
    nameEn: 'ancient Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_ancient.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_city',
    name: 'stena mesto',
    nameEn: 'city wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_city.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_eep',
    name: 'detská stena',
    nameEn: 'kids Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_eep.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_gaming',
    name: 'gamer stena',
    nameEn: 'waming wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_gaming.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_kawai_adventure',
    name: 'roztomilá stena',
    nameEn: 'cute wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_kawai_adventure.png',
    cost: 120,
  ),

  RoomComponent(
    id: 'wall_pacman',
    name: 'Pacman stena',
    nameEn: 'Pacman wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_pacman.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_rhombus',
    name: 'stena z kosoštvorcov',
    nameEn: 'rhombus wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_rhombus.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_shapes',
    name: 'stena s geometrickými tvarmi',
    nameEn: 'shapes Wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_shapes.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_strips',
    name: 'pruhovaná stena',
    nameEn: 'striped wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_strips.png',
    cost: 110,
  ),

  RoomComponent(
    id: 'wall_vibes',
    name: 'vibes stena',
    nameEn: 'vibes wall',
    type: RoomComponentType.wall,
    texture: 'room/wall_vibes.png',
    cost: 110,
  ),
];
