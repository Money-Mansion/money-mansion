import '../models/room_component.dart';
import 'room_components/walls.dart';
import 'room_components/floors.dart';

/// Centralized list of all available room components in the game.
/// 
/// Room components are organized by type in separate files:
/// - walls.dart: Wall components
/// - floors.dart: Floor components
///
/// Room components work just like items:
/// - Players purchase them via the shop
/// - They're stored in owned_room_components database table
/// - Selected components are stored in room_selected_components
/// - In edit mode, players select which component to use for walls/floor
///
/// To add new room components:
/// 1. Create or edit a category file (walls.dart, floors.dart)
/// 2. Add your RoomComponent to the appropriate list
/// 3. Ensure texture paths point to actual assets in assets/images/room/
/// 4. The component will automatically appear in ROOM_COMPONENTS
///
/// Note: Currently supports 'wall' and 'floor' types only.
/// Wallpaper/ceiling can be added later by extending RoomComponentType enum.

final List<RoomComponent> ROOM_COMPONENTS = [
  ...wallComponents,
  ...floorComponents,
];
