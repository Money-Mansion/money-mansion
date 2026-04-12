import 'package:flutter/widgets.dart';
import '../services/tutorial_target_registry.dart';

/// Wrap any widget that should be highlighted during the tutorial.
class TutorialTarget extends StatefulWidget {
  final String id;
  final Widget child;

  const TutorialTarget({super.key, required this.id, required this.child});

  @override
  State<TutorialTarget> createState() => _TutorialTargetState();
}

class _TutorialTargetState extends State<TutorialTarget> {
  final GlobalKey _key = GlobalKey();
  Rect? _lastRect;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void didUpdateWidget(covariant TutorialTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRect();
  }

  void _startTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateRect();
      _startTracking();
    });
  }

  void _updateRect() {
    final context = _key.currentContext;
    if (context == null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlayBox =
        Overlay.of(context)?.context.findRenderObject() as RenderBox?;
    final offset = overlayBox != null
        ? renderBox.localToGlobal(Offset.zero, ancestor: overlayBox)
        : renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;

    if (_lastRect == rect) return;
    _lastRect = rect;
    TutorialTargetRegistry.instance.setTarget(widget.id, rect);
  }

  @override
  void dispose() {
    TutorialTargetRegistry.instance.removeTarget(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
