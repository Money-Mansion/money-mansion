import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

/// ChrumkoGuide is a reusable widget that displays Chrumko (the guide character)
/// with a dynamic tips system, animations, and speech bubbles.
class ChrumkoGuide extends StatefulWidget {
  final String language;
  final bool autoShowTips;
  final VoidCallback? onClicked;

  const ChrumkoGuide({
    super.key,
    required this.language,
    this.autoShowTips = true,
    this.onClicked,
  });

  @override
  State<ChrumkoGuide> createState() => _ChrumkoGuideState();
}

class _ChrumkoGuideState extends State<ChrumkoGuide>
    with TickerProviderStateMixin {
  int _tipIndex = 0;
  bool _showBubble = false;
  bool _overlayOpen = false;

  Timer? _repeatTimer;
  Timer? _hideTimer;

  final Random _random = Random();

  late AnimationController _animController;
  late AnimationController _positionController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  // Tips are derived from the current language at display time
  List<String> get _tips => AppLocalizations.getChrumkoTips(widget.language);
  String get _tipLabel =>
      AppLocalizations.translate('chrumkoTipLabel', language: widget.language);
  String get _tipDismiss =>
      AppLocalizations.translate('chrumkoTipDismiss', language: widget.language);

  // ── Life-cycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );

    // Position animation controller for overlay open/close
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeInOutCubic),
    );

    if (widget.autoShowTips) {
      // Show first tip 5 s after screen loads
      Future.delayed(const Duration(seconds: 5), _showNextTip);

      // Then repeat every 3 minutes
      _repeatTimer = Timer.periodic(
        const Duration(minutes: 3),
        (_) => _showNextTip(),
      );
    }
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _hideTimer?.cancel();
    _animController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // ── Tip logic ───────────────────────────────────────────────────────────────
  void _showNextTip() {
    if (!mounted) return;

    // Pick a random tip, making sure it's different from the current one
    int newIndex;
    do {
      newIndex = _random.nextInt(_tips.length);
    } while (_tips.length > 1 && newIndex == _tipIndex);

    setState(() {
      _tipIndex = newIndex;
      _showBubble = true;
    });
    _animController.forward(from: 0);

    // Auto-hide after 8 s
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 8), _dismissBubble);
  }

  void _dismissBubble() {
    if (!mounted) return;
    _animController.reverse().then((_) {
      if (mounted) setState(() => _showBubble = false);
    });
  }

  // ── Overlay interaction ──────────────────────────────────────────────────────
  void _toggleOverlay() {
    if (widget.onClicked == null) return;

    setState(() {
      _overlayOpen = !_overlayOpen;
    });

    if (_overlayOpen) {
      // Animate Chrumko when overlay opens (fade to 0.6 opacity)
      _positionController.forward();
      // Disable tips when overlay opens
      _repeatTimer?.cancel();
      _hideTimer?.cancel();
      _dismissBubble();
    } else {
      // Animate Chrumko back when overlay closes (fade back to 1.0)
      _positionController.reverse();
      // Resume tips when overlay closes
      if (widget.autoShowTips) {
        // Show a tip after 2 seconds
        Future.delayed(const Duration(seconds: 2), _showNextTip);
        // Resume periodic tips every 3 minutes
        _repeatTimer = Timer.periodic(
          const Duration(minutes: 3),
          (_) => _showNextTip(),
        );
      }
    }

    // Notify parent that Chrumko was clicked
    widget.onClicked?.call();
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // The row puts the bubble to the left of Chrumko, both fully in-bounds
    // so GestureDetector hit-testing works correctly.
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speech bubble — shown to the left of Chrumko
          if (_showBubble)
            ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissBubble,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 195),
                      margin: const EdgeInsets.only(top: 15, right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.purple.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _tipLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade400,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: Colors.purple.shade300,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _tips[_tipIndex],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A3F6B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _tipDismiss,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tail pointing right toward Chrumko
                    Positioned(
                      top: 33,
                      right: 0,
                      child: CustomPaint(
                        size: const Size(10, 14),
                        painter: _BubbleTailPainter(
                          color: Colors.white,
                          borderColor: Colors.purple.shade200,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Chrumko image — tappable to open overlay
          FadeTransition(
            opacity: _opacityAnim,
            child: GestureDetector(
              onTap: _toggleOverlay,
              child: Image.asset(
                'assets/images/chrumko.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tail painter ────────────────────────────────────────────────────────────
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _BubbleTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Triangle pointing right toward Chrumko
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height / 2)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) =>
      old.color != color || old.borderColor != borderColor;
}