import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// RoomWorld is a Flame game that provides a blank canvas for the room.
/// Items and room components will be added to this world in the future.
class RoomWorld extends FlameGame {
  RoomWorld() : super();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Camera is automatically centered by the FlameGame
    // The background will be handled by this render method
    // This keeps the Flame world focused on game objects only
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

  /// Add a Room component to the world
  void addRoomComponent(Component roomComponent) {
    add(roomComponent);
  }

  /// Clear all game components (except camera)
  void clearComponents() {
    removeWhere((component) => component != camera);
  }
}
