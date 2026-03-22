import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../models/item.dart';
import '../models/hitbox.dart';
import '../games/room_world.dart';
import '../services/hitbox_service.dart';

/// ItemComponent represents an item placed in the room
/// It displays the item's texture sprite at a specified position with polygon-based collision
class ItemComponent extends SpriteComponent with DragCallbacks, TapCallbacks {
  final Item item;
  final RoomWorld game;
  bool isSelected = false;
  
  late Hitbox hitbox;
  late Vector2 spriteSize;

  ItemComponent({
    required this.item,
    required this.game,
    required Vector2 position,
  }) : super(
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    try {
      // Load the sprite from the item's texture path
      String texturePath = item.texture;
      if (texturePath.startsWith('assets/images/')) {
        texturePath = texturePath.replaceFirst('assets/images/', '');
      }
      sprite = await game.loadSprite(texturePath);
      
      // Get the natural sprite dimensions
      if (sprite != null) {
        spriteSize = Vector2(sprite!.src.width, sprite!.src.height);
      } else {
        spriteSize = Vector2(100, 100); // Fallback
      }
      
      // Set the component size based on sprite dimensions and scale
      size = spriteSize * item.scale;
    } catch (e) {
      print('Error loading item sprite: ${item.texture} - $e');
      spriteSize = Vector2(100, 100);
      size = spriteSize * item.scale;
    }

    // Load hitbox data from .convexshape file
    try {
      final hitboxId = item.hitboxId ?? item.id;
      hitbox = await HitboxService().loadHitbox(hitboxId);
    } catch (e) {
      print('Error loading hitbox for item ${item.id}: $e');
      // HitboxService already provides a default fallback
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isSelected) {
      _renderHitboxOutline(canvas);
    }
  }

  /// Render the polygon hitbox outline for debugging/selection visualization
  void _renderHitboxOutline(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF9C27B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final polygon in hitbox.polygons) {
      final path = Path();
      
      if (polygon.points.isNotEmpty) {
        // Transform hitbox points to component-local coordinates and apply scale
        final scaledPoints = polygon.points.map((point) {
          return point * item.scale;
        }).toList();
        
        path.moveTo(scaledPoints[0].x, scaledPoints[0].y);
        
        for (int i = 1; i < scaledPoints.length; i++) {
          path.lineTo(scaledPoints[i].x, scaledPoints[i].y);
        }
        
        // Close the polygon
        path.close();
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Use point-in-polygon collision detection
    // Scale the point back to hitbox space (reverse the scale transformation)
    final hitboxPoint = point / item.scale;
    
    return hitbox.containsPoint(hitboxPoint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!game.isEditMode) {
      return;
    }
    game.selectItem(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!game.isEditMode) {
      return;
    }
    if (!isSelected) {
      game.selectItem(this);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!game.isEditMode) {
      return;
    }
    position.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
  }
}
