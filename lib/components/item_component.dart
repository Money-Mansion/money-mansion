import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../models/item.dart';
import '../games/room_world.dart';

/// ItemComponent represents an item placed in the room
/// It displays the item's texture sprite at a specified position
class ItemComponent extends SpriteComponent with DragCallbacks, TapCallbacks {
  final Item item;
  final RoomWorld game;
  bool isSelected = false;

  ItemComponent({
    required this.item,
    required this.game,
    required Vector2 position,
    Vector2? size,
  }) : super(
    position: position,
    size: size ?? Vector2(80, 80),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    try {
      // Load the sprite from the item's texture path
      // Flame's loadSprite() already prepends 'assets/images/', so we strip it if present
      String texturePath = item.texture;
      if (texturePath.startsWith('assets/images/')) {
        texturePath = texturePath.replaceFirst('assets/images/', '');
      }
      sprite = await game.loadSprite(texturePath);
    } catch (e) {
      print('Error loading item sprite: ${item.texture} - $e');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isSelected) {
      final paint = Paint()
        ..color = const Color(0xFF9C27B0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Since this component uses Anchor.center, the local coordinate
      // system is aligned such that (0, 0) is the top-left corner of
      // the component's bounds for rendering, so we draw the rectangle
      // from (0, 0) to (size.x, size.y) to match the sprite.
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Hit area should match the visual bounds of the sprite
    return point.x >= 0 &&
        point.x <= size.x &&
        point.y >= 0 &&
        point.y <= size.y;
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.selectItem(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!isSelected) {
      game.selectItem(this);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
  }

  @override
  void onDragCancel(DragCancelEvent event) {
  }
}
