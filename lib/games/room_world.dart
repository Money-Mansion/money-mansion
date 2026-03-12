import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../components/room_component.dart';
import '../components/item_component.dart';
import '../models/item.dart';

/// RoomWorld is a Flame game that provides a canvas for the room and items.
/// The room and item components are added to this world.
class RoomWorld extends FlameGame {
  RoomWorld() : super();

  ItemComponent? _selectedItem;

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

  /// Mark a specific item component as selected
  void selectItem(ItemComponent item) {
    if (_selectedItem == item) return;

    _selectedItem?.isSelected = false;
    _selectedItem = item;
    _selectedItem?.isSelected = true;
  }

  /// Clear any current selection
  void clearSelection() {
    _selectedItem?.isSelected = false;
    _selectedItem = null;
  }

  /// Add an item to the center of the room
  void addItemToRoom(Item item) {
    final itemComponent = ItemComponent(
      item: item,
      game: this,
      position: Vector2(size.x / 2, size.y / 2), // Center of the world
    );
    add(itemComponent);
  }

  /// Clear all game components (except camera)
  void clearComponents() {
    removeWhere((component) => component != camera);
  }
}
