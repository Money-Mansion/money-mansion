import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../games/room_world.dart';
import '../services/room_component_service.dart';

/// RoomComponent renders the room structure in the Flame world
/// Composed of walls and floor sprites
/// Loads selected components from the database for dynamic wall/floor selection
class RoomComponent extends PositionComponent with TapCallbacks {
  static const double roomWidth = 400;
  static const double roomHeight = 300;
  final RoomWorld game;

  RoomComponent({required this.game})
      : super(
        size: Vector2(roomWidth, roomHeight),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    // Get selected wall and floor components from database
    final selectedWallComponent = await RoomComponentService.getCurrentComponentForRole('wall');
    final selectedFloorComponent = await RoomComponentService.getCurrentComponentForRole('floor');
    
    // Use selected components if available, otherwise use defaults
    final wallTexture = selectedWallComponent?.texture ?? 'room/basic_right_wall.png';
    final floorTexture = selectedFloorComponent?.texture ?? 'room/basic_floor.png';

    // Load floor sprite
    final floor = SpriteComponent(
      sprite: await game.loadSprite(floorTexture),
      size: Vector2(roomWidth, 200), // Floor takes up bottom 30%
      position: Vector2(0, 100), // Position at bottom
      anchor: Anchor.topLeft,
    );

    // Load left wall (flipped version of right wall texture)
    final leftWall = SpriteComponent(
      sprite: await game.loadSprite(wallTexture),
      size: Vector2(roomWidth * 0.5, 200), 
      position: Vector2(roomWidth * 0.5, 0), // Flip point at the center
      anchor: Anchor.topLeft,
      scale: Vector2(-1, 1), // Flip horizontally
    );

    // Load right wall
    final rightWall = SpriteComponent(
      sprite: await game.loadSprite(wallTexture),
      size: Vector2(roomWidth * 0.5, 200), // Wall takes 15% of width
      position: Vector2(roomWidth * 0.5, 0), // Position on right side
      anchor: Anchor.topLeft,
    );

    add(floor);
    add(leftWall);
    add(rightWall);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // In edit mode: accept taps anywhere on the canvas (let onTapDown handle the logic)
    // This allows deselecting by tapping empty space anywhere
    if (game.isEditMode) {
      return true;  // Accept all taps so onTapDown gets called
    }
    
    // In view mode: only the room rectangle is tappable
    return point.x >= 0 &&
        point.x <= size.x &&
        point.y >= 0 &&
        point.y <= size.y;
  }

  @override
  void onTapDown(TapDownEvent event) {
    print('🏠🔴 RoomComponent.onTapDown - editMode=${game.isEditMode}');
    if (!game.isEditMode) return;
    // Don't clear selection here - wait for onTap to ensure it's not a drag
  }

  @override
  void onTapUp(TapUpEvent event) {
    print('🏠✓ RoomComponent.onTapUp - editMode=${game.isEditMode}');
    if (!game.isEditMode) return;
    
    // Check if the tap is on the currently selected item
    // If it is, don't clear (the item was just selected by ItemComponent)
    final selectedItem = game.getSelectedItem();
    if (selectedItem != null) {
      // Convert tap position to world coordinates
      final tapPos = event.localPosition;
      final itemPos = selectedItem.position;
      final itemSize = selectedItem.size;
      
      // Check if tap is within item bounds
      if (tapPos.x >= itemPos.x - itemSize.x / 2 &&
          tapPos.x <= itemPos.x + itemSize.x / 2 &&
          tapPos.y >= itemPos.y - itemSize.y / 2 &&
          tapPos.y <= itemPos.y + itemSize.y / 2) {
        print('🏠✓   -> TAP ON SELECTED ITEM, not clearing');
        return;
      }
    }
    
    // Tap is not on selected item (or no item selected), clear selection
    print('🏠✓   -> CLEARING selection');
    game.clearSelection();
  }
}
