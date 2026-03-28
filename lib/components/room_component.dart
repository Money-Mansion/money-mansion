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
    // Treat the whole room rectangle as tappable
    return point.x >= 0 &&
        point.x <= size.x &&
        point.y >= 0 &&
        point.y <= size.y;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.isEditMode) {
      game.clearSelection();
    }
  }
}
