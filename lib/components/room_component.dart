import 'package:flame/components.dart';
import '../games/room_world.dart';

/// RoomComponent renders the room structure in the Flame world
/// Composed of walls and floor sprites
class RoomComponent extends PositionComponent {
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
    // Load floor
    final floor = SpriteComponent(
      sprite: await game.loadSprite('room/basic_floor.png'),
      size: Vector2(roomWidth, 200), // Floor takes up bottom 30%
      position: Vector2(0, 100), // Position at bottom
      anchor: Anchor.topLeft,
    );

    // Load left wall
    final leftWall = SpriteComponent(
      sprite: await game.loadSprite('room/basic_left_wall.png'),
      size: Vector2(roomWidth * 0.5, 200), // Wall takes 15% of width
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
    );

    // Load right wall
    final rightWall = SpriteComponent(
      sprite: await game.loadSprite('room/basic_right_wall.png'),
      size: Vector2(roomWidth * 0.5, 200), // Wall takes 15% of width
      position: Vector2(roomWidth * 0.5, 0), // Position on right side
      anchor: Anchor.topLeft,
    );

    add(floor);
    add(leftWall);
    add(rightWall);
  }
}
