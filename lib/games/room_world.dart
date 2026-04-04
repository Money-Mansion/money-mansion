import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../components/room_component.dart';
import '../components/camera_control_component.dart';
import '../components/item_component.dart';
import '../models/item.dart';
import '../models/room_item_placement.dart';

/// RoomWorld is a Flame game that provides a canvas for the room and items.
/// The room and item components are added to this world.
class RoomWorld extends FlameGame {
  final bool isEditMode;

  RoomWorld({this.isEditMode = false}) : super();

  ItemComponent? _selectedItem;
  RoomComponent? room; // Nullable to allow reloading
  VoidCallback? onSelectionChanged;

  // Camera control fields (edit mode only)
  late double _defaultZoom;
  final double _minZoom = 0.5;   // Can zoom out to 50%
  final double _maxZoom = 3.0;   // Can zoom in to 300%
  bool _hasInitializedCamera = false;  // Prevent re-centering on resize in edit mode

  final Completer<void> _loadCompleter = Completer<void>();

  Future<void> get loaded => _loadCompleter.future;

  RoomComponent? get roomComponent => room;

  void _updateCameraAndRoomPosition() {
    if (size.x == 0 || size.y == 0) return;
    if (room == null) return;

    room!.position = size / 2;

    const roomWidth = RoomComponent.roomWidth;
    const roomHeight = RoomComponent.roomHeight;
    final scaleX = size.x / roomWidth;
    final scaleY = size.y / roomHeight;
    final baseZoom = math.min(scaleX, scaleY);
    final zoom = baseZoom * 0.9;

    _defaultZoom = zoom;
    camera.viewfinder.zoom = zoom;
    camera.viewfinder.position = room!.position.clone();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    room = RoomComponent(game: this);
    if (room != null) {
      world.add(room!);
    }

    // Add camera control component (handles gestures in edit mode)
    if (isEditMode) {
      world.add(CameraControlComponent(game: this));
    }

    if (!_loadCompleter.isCompleted) {
      _loadCompleter.complete();
    }

    _updateCameraAndRoomPosition();
    _hasInitializedCamera = true;  // Mark camera as initialized
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // In edit mode, don't reset camera on resize (user may have panned it)
    // Only update room position and zoom once during initial load
    if (_loadCompleter.isCompleted) {
      if (isEditMode && _hasInitializedCamera) {
        // In edit mode: only update room position, don't reset camera
        if (room != null) {
          room!.position = size / 2;
        }
      } else {
        // In view mode or first load: reset everything
        _updateCameraAndRoomPosition();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFFFBF5),
    );
    super.render(canvas);
  }

  /// Add a component to the world
  void addComponent(Component component) {
    world.add(component); // ← was: add(component) — must go through world
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
  ItemComponent? getSelectedItem() {
    return _selectedItem;
  }

  /// Get zoom bounds and current zoom level
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => camera.viewfinder.zoom;
  
  /// Set zoom to a specific value (clamped to min/max)
  void setZoom(double newZoom) {
    final clampedZoom = newZoom.clamp(_minZoom, _maxZoom);
    camera.viewfinder.zoom = clampedZoom;
  }

  /// Remove the currently selected item from the room
  void removeSelectedItem() {
    if (_selectedItem != null) {
      world.remove(_selectedItem!); // ← was: remove(_selectedItem!) — wrong parent
      _selectedItem = null;
      onSelectionChanged?.call();
    }
  }

  /// Move the currently selected item forward in the layer stack (on top of others)
  void moveSelectedItemToFront() {
    if (_selectedItem == null) return;
    
    // Get all items in the world
    final items = <ItemComponent>[];
    for (final component in world.children) {
      if (component is ItemComponent) {
        items.add(component);
      }
    }
    
    // Find the index of the selected item
    final selectedIndex = items.indexOf(_selectedItem!);
    if (selectedIndex < 0) return;
    
    // If already at the front, do nothing
    if (selectedIndex == items.length - 1) return;
    
    // Remove and re-add to move to the end (top layer)
    world.remove(_selectedItem!);
    world.add(_selectedItem!);
  }

  /// Move the currently selected item backward in the layer stack (behind others)
  void moveSelectedItemToBack() {
    if (_selectedItem == null) return;
    
    // Get all items and the room in the world
    final children = world.children.toList();
    final items = <ItemComponent>[];
    final nonItems = <Component>[];
    
    for (final component in children) {
      if (component is ItemComponent) {
        items.add(component);
      } else {
        nonItems.add(component);
      }
    }
    
    // Find the index of the selected item
    final selectedIndex = items.indexOf(_selectedItem!);
    if (selectedIndex < 0) return;
    
    // If already at the back, do nothing
    if (selectedIndex == 0) return;
    
    // Remove all items from world
    for (final item in items) {
      world.remove(item);
    }
    
    // Re-add in new order (selected item first/back, others in order)
    final newItems = [...items];
    newItems.removeAt(selectedIndex);
    world.add(_selectedItem!); // Add selected to back
    for (final item in newItems) {
      world.add(item);
    }
  }

  /// Add an item to the room at a given world position.
  void addItemToRoom(Item item, {Vector2? position}) {
    if (room == null) return;
    final itemComponent = ItemComponent(
      item: item,
      game: this,
      position: position ?? room!.position.clone(),
    );
    world.add(itemComponent);
  }

  /// Get current layout of all items in this room world.
  List<RoomItemPlacement> getCurrentLayout(String roomId) {
    final placements = <RoomItemPlacement>[];
    if (room == null) return placements;
    final roomCenter = room!.position;

    for (final component in world.children) {
      if (component is ItemComponent) {
        placements.add(
          RoomItemPlacement(
            roomId: roomId,
            itemId: component.item.id,
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
    for (final component in world.children) {
      if (component is ItemComponent) {
        placedIds.add(component.item.id);
      }
    }
    return placedIds;
  }

  /// Clear all item and room components from the world
  void clearComponents() {
    world.removeWhere( // ← was also correct but addComponent was adding to game root, now consistent
      (component) => component is ItemComponent || component is RoomComponent,
    );
    _selectedItem = null;
  }

  /// Reload the room component (called when room components are changed)
  void reloadComponents() {
    // Remove the current room component if it exists
    if (room != null) {
      world.remove(room!);
    }
    
    // Create a new room component which will load the latest from database
    room = RoomComponent(game: this);
    world.add(room!);
  }

  /// Public method to pan the camera
  void panCamera(Vector2 delta) {
    // Move camera opposite to drag direction (dragging left pans right)
    final oldPos = camera.viewfinder.position.clone();
    final scaledDelta = -delta / camera.viewfinder.zoom;
    // Directly set position components (add() doesn't persist on getter/setter properties)
    camera.viewfinder.position = camera.viewfinder.position + scaledDelta;
    _clampCameraPosition();
  }

  /// Public method to zoom by a fixed amount
  void zoomByAmount(double zoomDelta) {
    final newZoom = (camera.viewfinder.zoom + zoomDelta)
        .clamp(_minZoom, _maxZoom);
    
    camera.viewfinder.zoom = newZoom;
    _clampCameraPosition();
  }

  /// Clamp camera position to keep the room mostly visible
  void _clampCameraPosition() {
    if (room == null) return;
    
    final roomPos = room!.position;
    final roomWidth = RoomComponent.roomWidth;
    final roomHeight = RoomComponent.roomHeight;
    
    // Allow panning but keep at least 40% of room visible
    final maxOffsetX = (roomWidth * 0.3) / camera.viewfinder.zoom;
    final maxOffsetY = (roomHeight * 0.3) / camera.viewfinder.zoom;
    
    final oldX = camera.viewfinder.position.x;
    final oldY = camera.viewfinder.position.y;
    
    camera.viewfinder.position.x = camera.viewfinder.position.x
        .clamp(roomPos.x - maxOffsetX, roomPos.x + maxOffsetX);
    camera.viewfinder.position.y = camera.viewfinder.position.y
        .clamp(roomPos.y - maxOffsetY, roomPos.y + maxOffsetY);
    
    if (oldX != camera.viewfinder.position.x || oldY != camera.viewfinder.position.y) {
      // Camera was clamped (normal during panning)
    }
  }

  /// Reset camera to default zoom and position (public method for UI)
  void resetCamera() {
    if (room == null) return;
    camera.viewfinder.zoom = _defaultZoom;
    camera.viewfinder.position = room!.position.clone();
  }
}