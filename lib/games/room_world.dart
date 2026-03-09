import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../components/room_component.dart';

/// RoomWorld is a Flame game that provides a canvas for the room and items.
/// The room and item components are added to this world.
class RoomWorld extends FlameGame {
  RoomWorld() : super();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Create and center the room component
    final room = RoomComponent(game: this);
    room.position = Vector2(size.x / 2, size.y / 2);
    add(room);
  }

  @override
  void render(Canvas canvas) {
    // Draw background color (pink-white)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFFFBF5),
    );
    // Then render game components on top
    super.render(canvas);
  }

  /// Add a component to the world
  void addComponent(Component component) {
    add(component);
  }

  /// Clear all game components (except camera)
  void clearComponents() {
    removeWhere((component) => component != camera);
  }
}
