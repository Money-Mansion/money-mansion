import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
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
  bool _tracking = true;

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
      if (!mounted || !_tracking) return;
      _updateRect();
      _startTracking();
    });
  }

  void _updateRect() {
    final context = _key.currentContext;
    if (context == null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    // Keep tracking independent from inherited widgets. Calling Overlay.of()
    // from a recurring post-frame callback can leave inherited dependencies
    // attached while routes/screens are being deactivated.
    final Rect rect = Rect.fromPoints(
      renderBox.localToGlobal(Offset.zero),
      renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero)),
    );

    if (_lastRect == rect) return;
    _lastRect = rect;
    TutorialTargetRegistry.instance.setTarget(widget.id, rect);
  }

  @override
  void dispose() {
    _tracking = false;
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
