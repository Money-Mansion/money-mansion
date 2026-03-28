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
