import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../components/room_component.dart';
import '../components/item_component.dart';
import '../models/item.dart';
import '../models/room_item_placement.dart';

/// RoomWorld is a Flame game that provides a canvas for the room and items.
/// The room and item components are added to this world.
class RoomWorld extends FlameGame {
  final bool isEditMode;

  RoomWorld({this.isEditMode = false}) : super();

  ItemComponent? _selectedItem;
  late final RoomComponent room;

  final Completer<void> _loadCompleter = Completer<void>();

  Future<void> get loaded => _loadCompleter.future;

  RoomComponent get roomComponent => room;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create and center the room component
    room = RoomComponent(game: this);
    room.position = Vector2(size.x / 2, size.y / 2);
    add(room);

    if (!_loadCompleter.isCompleted) {
      _loadCompleter.complete();
    }
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

  /// Add an item to the room at a given world position.
  /// If [position] is null, it will be added at the center of the world.
  void addItemToRoom(
    Item item, {
    Vector2? position,
  }) {
    final itemComponent = ItemComponent(
      item: item,
      game: this,
      position: position ?? room.position.clone(),
    );
    add(itemComponent);
  }

  /// Get current layout of all items in this room world.
  List<RoomItemPlacement> getCurrentLayout(String roomId) {
    final placements = <RoomItemPlacement>[];
    final roomCenter = room.position;

    for (final component in children) {
      if (component is ItemComponent) {
        placements.add(
          RoomItemPlacement(
            roomId: roomId,
            itemId: component.item.id,
            // Store offset relative to the room center so that
            // layouts stay consistent even if the canvas size changes.
            x: component.position.x - roomCenter.x,
            y: component.position.y - roomCenter.y,
          ),
        );
      }
    }

    return placements;
  }

  /// Clear all game components (except camera)
  void clearComponents() {
    removeWhere((component) => component != camera);
  }
}
