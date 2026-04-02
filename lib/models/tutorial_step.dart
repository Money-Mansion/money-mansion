import 'package:flutter/widgets.dart';

/// Declarative tutorial step definition.
class TutorialStep {
  final String id;
  final String screenId;
  final String messageKey;
  final String? targetId;
  final String? requiredActionId; // action that must be triggered to complete
  final Alignment? targetAlignment; // rough area to highlight/point to

  const TutorialStep({
    required this.id,
    required this.screenId,
    required this.messageKey,
    this.targetId,
    this.requiredActionId,
    this.targetAlignment,
  });
}
