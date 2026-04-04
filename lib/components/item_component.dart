import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../models/item.dart';
import '../models/hitbox.dart';
import '../games/room_world.dart';
import '../services/hitbox_service.dart';

/// ItemComponent represents an item placed in the room
/// It displays the item's texture sprite at a specified position with polygon-based collision
class ItemComponent extends SpriteComponent with TapCallbacks {
  final Item item;
  final RoomWorld game;
  bool isSelected = false;
  bool isFlipped = false; // Track whether item is horizontally flipped
  
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
      
      // Get the natural sprite dimensions from the image
      if (sprite != null) {
        // Get image dimensions
        final imageWidth = sprite!.image.width.toDouble();
        final imageHeight = sprite!.image.height.toDouble();
        spriteSize = Vector2(imageWidth, imageHeight);
        print('✓ Loaded sprite ${item.id}: size=${spriteSize.x}x${spriteSize.y}');
      } else {
        spriteSize = Vector2(100, 100); // Fallback
        print('⚠ Sprite is null for ${item.id}, using fallback');
      }
      
      // Set the component size based on sprite dimensions and scale
      size = spriteSize * item.scale;
      print('✓ Set ItemComponent size for ${item.id}: ${size.x}x${size.y} (scale: ${item.scale})');
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
    if (isFlipped) {
      // Save canvas state
      canvas.save();
      // Flip the canvas horizontally around the component center
      canvas.scale(-1, 1);
      // Render with flipped canvas
      if (isSelected) {
        _renderHitboxGlow(canvas);
      }
      super.render(canvas);
      // Restore canvas state
      canvas.restore();
    } else {
      if (isSelected) {
        _renderHitboxGlow(canvas);
      }
      super.render(canvas);
    }
  }

  /// Render a soft glowing effect around the hitbox (underneath the item)
  void _renderHitboxGlow(Canvas canvas) {
    const glowColor = Color(0xFF9C27B0);
    
    for (final polygon in hitbox.polygons) {
      if (polygon.points.isEmpty) continue;
      
      // Transform hitbox points to component-local coordinates and apply scale
      final scaledPoints = polygon.points.map((point) {
        return point * item.scale;
      }).toList();
      
      // Build path for the polygon
      final path = Path();
      path.moveTo(scaledPoints[0].x, scaledPoints[0].y);
      for (int i = 1; i < scaledPoints.length; i++) {
        path.lineTo(scaledPoints[i].x, scaledPoints[i].y);
      }
      path.close();
      
      // Draw glow along the edges using blurred strokes
      for (int glowLayer = 3; glowLayer >= 1; glowLayer--) {
        final opacity = (0.3 / glowLayer).clamp(0.0, 1.0);
        final glowPaint = Paint()
          ..color = glowColor.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0 + (2.0 * glowLayer)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 * glowLayer);
        
        canvas.drawPath(path, glowPaint);
      }
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Use point-in-polygon collision detection
    // Scale the point back to hitbox space (reverse the scale transformation)
    var hitboxPoint = point / item.scale;
    
    // If flipped, mirror the X coordinate for collision detection
    if (isFlipped) {
      hitboxPoint = Vector2(-hitboxPoint.x, hitboxPoint.y);
    }
    
    return hitbox.containsPoint(hitboxPoint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    print('📦🔴 ItemComponent(${item.id}).onTapDown - editMode=${game.isEditMode}');
    if (!game.isEditMode) {
      return;
    }
    // Don't select here - wait for onTap to determine if it's a tap or drag
  }

  @override
  void onTapUp(TapUpEvent event) {
    print('📦✓ ItemComponent(${item.id}).onTapUp - editMode=${game.isEditMode}');
    if (!game.isEditMode) {
      return;
    }
    print('📦✓   -> SELECTING item ${item.id}');
    game.selectItem(this);
  }

  /// Toggle horizontal flip (mirror) of the item and its hitbox
  void toggleFlip() {
    isFlipped = !isFlipped;
    // Flipping is handled in render() and containsLocalPoint() methods
  }
}
