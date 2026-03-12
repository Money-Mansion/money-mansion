import 'package:flame/components.dart';
import '../models/item.dart';
import '../games/room_world.dart';

/// ItemComponent represents an item placed in the room
/// It displays the item's texture sprite at a specified position
class ItemComponent extends SpriteComponent {
  final Item item;
  final RoomWorld game;

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
}
