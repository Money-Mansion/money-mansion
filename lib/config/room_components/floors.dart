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
    id: 'floor_basic',
    name: 'Základná podlaha',
    nameEn: 'Basic Floor',
    type: RoomComponentType.floor,
    texture: 'room/basic_floor.png',
    cost: 0, // Starting floor is free (default)
  ),
];
