import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../models/room.dart';
import '../models/item.dart';
import '../models/game_state.dart';
import '../games/room_world.dart';
import '../services/room_layout_database_service.dart';
import 'tutorial_target.dart';

class RoomViewer extends StatefulWidget {
  final Room? room;
  final VoidCallback? onEditPressed;
  final String language; // pass AppLocalizationsProvider.currentLanguage
  final Function(RoomWorld)? onRoomWorldReady;
  final GameState? gameState;

  const RoomViewer({
    super.key,
    this.room,
    this.onEditPressed,
    this.language = 'en',
    this.onRoomWorldReady,
    this.gameState,
  });

  @override
  State<RoomViewer> createState() => _RoomViewerState();
}

class _RoomViewerState extends State<RoomViewer> {
  late RoomWorld roomWorld;
  final Map<int, Offset> _activeTouchPointers = {};
  double? _pinchStartDistance;
  double? _pinchStartZoom;

  bool get _useTouchPinchZoom {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.onEditPressed == null;
    roomWorld = RoomWorld(isEditMode: isEditMode);
    // Call the callback to expose roomWorld to parent widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRoomWorldReady?.call(roomWorld);
      _loadRoomLayoutIfNeeded();
    });
  }

  Future<void> _loadRoomLayoutIfNeeded() async {
    if (widget.room == null || widget.gameState == null) {
      return;
    }

    // Ensure the Flame world (and its room component) are fully loaded
    await roomWorld.loaded;

    final placements = await RoomLayoutDatabaseService.getRoomLayout(
      RoomLayoutDatabaseService.defaultRoomId,
    );

    if (!mounted) return;

    final roomCenter = roomWorld.roomComponent?.position ?? Vector2.zero();

    for (final placement in placements) {
      final Item? item = widget.gameState!.ownedItems.cast<Item?>().firstWhere(
            (i) => i?.id == placement.itemId,
            orElse: () => null,
          );

      if (item != null) {
        final itemComponent = roomWorld.addItemToRoom(
          item,
          // Convert stored offset-from-room-center back into a world position
          position: roomCenter + Vector2(placement.x, placement.y),
        );
        
        // Apply flip state if it was saved
        if (placement.isFlipped) {
          itemComponent.isFlipped = true;
        }
      }
    }
  }

  @override
  void dispose() {
    roomWorld.pauseEngine();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_useTouchPinchZoom || event.kind != PointerDeviceKind.touch) {
      return;
    }

    _activeTouchPointers[event.pointer] = event.position;
    _syncPinchState();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_useTouchPinchZoom || event.kind != PointerDeviceKind.touch) {
      return;
    }
    if (!_activeTouchPointers.containsKey(event.pointer)) {
      return;
    }

    _activeTouchPointers[event.pointer] = event.position;

    if (_activeTouchPointers.length < 2) {
      return;
    }

    final distance = _currentPointerDistance;
    final startDistance = _pinchStartDistance;
    final startZoom = _pinchStartZoom;
    if (distance == null ||
        startDistance == null ||
        startDistance <= 0 ||
        startZoom == null) {
      return;
    }

    roomWorld.beginPinch();
    roomWorld.setZoom(startZoom * (distance / startDistance));
  }

  void _handlePointerUp(PointerEvent event) {
    if (!_useTouchPinchZoom || event.kind != PointerDeviceKind.touch) {
      return;
    }

    _activeTouchPointers.remove(event.pointer);
    _syncPinchState();
  }

  double? get _currentPointerDistance {
    if (_activeTouchPointers.length < 2) return null;
    final points = _activeTouchPointers.values.take(2).toList(growable: false);
    return (points[0] - points[1]).distance;
  }

  void _syncPinchState() {
    if (_activeTouchPointers.length >= 2) {
      final distance = _currentPointerDistance;
      if (distance == null || distance <= 0) {
        return;
      }
      _pinchStartDistance = distance;
      _pinchStartZoom = roomWorld.currentZoom;
      roomWorld.beginPinch();
      return;
    }

    _pinchStartDistance = null;
    _pinchStartZoom = null;
    roomWorld.endPinch();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.room == null) {
      return const Center(
        child: Text('No room available'),
      );
    }

    return Stack(
      children: [
        // Flame canvas filling the entire space
        SizedBox.expand(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerUp,
            child: GameWidget(
              game: roomWorld,
              // Avoid brief black flashes while the game initializes
              // by matching the room background color.
              backgroundBuilder: (context) => Container(
                color: const Color(0xFFFFFBF5),
              ),
              loadingBuilder: (context) => Container(
                color: const Color(0xFFFFFBF5),
              ),
            ),
          ),
        ),

        // Edit button (bottom-right corner) - respects SafeArea
        if (widget.onEditPressed != null)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TutorialTarget(
                  id: 'open_room_edit',
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.purple.shade300,
                    onPressed: widget.onEditPressed,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
