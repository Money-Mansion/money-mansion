import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Global registry mapping tutorial target IDs to their current screen-space rects.
class TutorialTargetRegistry {
  TutorialTargetRegistry._();
  static final TutorialTargetRegistry instance = TutorialTargetRegistry._();

  final Map<String, Rect> _targets = {};
  /// Notifies listeners whenever targets change so overlays can rebuild.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  void setTarget(String id, Rect rect) {
    _targets[id] = rect;
    version.value++;
  }

  void removeTarget(String id) {
    _targets.remove(id);
    version.value++;
  }

  Rect? getTarget(String id) => _targets[id];
}
