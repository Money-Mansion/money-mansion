import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../games/room_world.dart';

/// CameraControlComponent handles camera gesture controls in edit mode.
/// This is an invisible component that receives drag gestures and notifies the RoomWorld game.
/// 
/// Gestures handled:
/// - Single-finger drag: pan camera
class CameraControlComponent extends PositionComponent with DragCallbacks {
  final RoomWorld game;

  CameraControlComponent({required this.game})
      : super(
          position: Vector2.zero(),
          size: Vector2.zero(),
        );

  @override
  Future<void> onLoad() async {
    // Make this component cover the entire game viewport
    // This allows it to receive all drag events
    size = game.size;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }

  /// Handle single-finger drag for camera panning
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // Only pan camera if:
    // 1. In edit mode
    // 2. No item is selected
    final editMode = game.isEditMode;
    final selectedItem = game.getSelectedItem();
    
    if (!editMode || selectedItem != null) {
      return;
    }

    game.panCamera(event.localDelta);
  }

  /// Allow all drags (hit detection is handled by priority)
  @override
  bool containsLocalPoint(Vector2 point) {
    final result = size != Vector2.zero();
    print('🎥 CameraControl.containsLocalPoint -> size=${size}, result=$result');
    return result;
  }

  @override
  void onDragStart(DragStartEvent event) {
    print('🎥📍 CameraControl.onDragStart()');
    super.onDragStart(event);
  }
}
