import 'dart:async';
import 'dart:math' as math;

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
  VoidCallback? onSelectionChanged;

  final Completer<void> _loadCompleter = Completer<void>();

  Future<void> get loaded => _loadCompleter.future;

  RoomComponent get roomComponent => room;

  void _updateCameraAndRoomPosition() {
    // 'size' is the current canvas size in world units.
    if (size.x == 0 || size.y == 0) {
      return;
    }

    // Center the room in the available canvas.
    room.position = size / 2;

    // Compute a uniform zoom so the 400x300 room fits inside the canvas
    // while preserving aspect ratio.
    const roomWidth = RoomComponent.roomWidth;
    const roomHeight = RoomComponent.roomHeight;
    final scaleX = size.x / roomWidth;
    final scaleY = size.y / roomHeight;
    final zoom = math.min(scaleX, scaleY);

    camera.viewfinder.zoom = zoom;
    camera.viewfinder.position = room.position.clone();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create and center the room component
    room = RoomComponent(game: this);
    add(room);

    // Initial camera/room alignment
    _updateCameraAndRoomPosition();

    if (!_loadCompleter.isCompleted) {
      _loadCompleter.complete();
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (_loadCompleter.isCompleted) {
      _updateCameraAndRoomPosition();
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
    onSelectionChanged?.call();
  }

  /// Clear any current selection
  void clearSelection() {
    _selectedItem?.isSelected = false;
    _selectedItem = null;
    onSelectionChanged?.call();
  }

  /// Get the currently selected item
  ItemComponent? getSelectedItem() => _selectedItem;

  /// Remove the currently selected item from the room
  void removeSelectedItem() {
    if (_selectedItem != null) {
      remove(_selectedItem!);
      _selectedItem = null;
      onSelectionChanged?.call();
    }
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

  /// Get set of item IDs currently placed in the room
  Set<String> getPlacedItemIds() {
    final placedIds = <String>{};
    for (final component in children) {
      if (component is ItemComponent) {
        placedIds.add(component.item.id);
      }
    }
    return placedIds;
  }

  /// Clear all game components (except camera)
  void clearComponents() {
    removeWhere((component) => component != camera);
    _selectedItem = null;
  }
}
