import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/room.dart';

class RoomViewer extends StatefulWidget {
  final Room? room;
  final VoidCallback? onEditPressed;

  const RoomViewer({
    super.key,
    this.room,
    this.onEditPressed,
  });

  @override
  State<RoomViewer> createState() => _RoomViewerState();
}

class _RoomViewerState extends State<RoomViewer>
    with SingleTickerProviderStateMixin {

  // ── Financial tips ────────────────────────────────────────────────────────
  static const List<String> _tips = [
    "Save at least 20% of your income every month! 💰",
    "Track every expense — small ones add up fast! 📊",
    "Build an emergency fund worth 3–6 months of expenses! 🛡️",
    "Pay off high-interest debt first — it saves the most! 💳",
    "Invest early! Even small amounts grow big over time! 📈",
    "Avoid impulse buying — wait 24 h before a purchase! ⏳",
    "Set financial goals: short-term, mid-term & long-term! 🎯",
    "Review your subscriptions — cancel ones you don't use! 🔍",
    "Compound interest is your best friend when saving! 🌱",
    "Diversify investments to reduce risk! 🌍",
  ];

  int _tipIndex = 0;
  bool _showBubble = false;

  Timer? _repeatTimer;
  Timer? _hideTimer;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  // ── Life-cycle ─────────────────────────────────────────────────────────────
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

    // Show first tip after 5 s so it's visible shortly after the screen loads
    Future.delayed(const Duration(seconds: 5), _showNextTip);

    // Then show a new tip every 3 minutes
    _repeatTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => _showNextTip(),
    );
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _hideTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ── Tip logic ──────────────────────────────────────────────────────────────
  void _showNextTip() {
    if (!mounted) return;
    setState(() {
      _tipIndex = (_tipIndex + 1) % _tips.length;
      _showBubble = true;
    });
    _animController.forward(from: 0);

    // Auto-hide after 8 s
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), _dismissBubble);
  }

  void _dismissBubble() {
    if (!mounted) return;
    _animController.reverse().then((_) {
      if (mounted) setState(() => _showBubble = false);
    });
  }

  // ── Speech bubble widget ───────────────────────────────────────────────────
  Widget _buildSpeechBubble() {
    return Positioned(
      top: 15,      // sit just below the top edge of the chrumko image
      right: 110,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment.bottomRight, // grows from the character's corner
        child: GestureDetector(
          onTap: _dismissBubble,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bubble body
              Container(
                constraints: const BoxConstraints(maxWidth: 195),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    // Header row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Chrumko's Tip 💡",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _dismissBubble,
                          child: Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.purple.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Tip text
                    Text(
                      _tips[_tipIndex],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A3F6B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tap-to-dismiss hint
                    Text(
                      "Tap to dismiss",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Small tail pointing toward Chrumko (right side, near top)
              Positioned(
                top: 18,
                right: -10,
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
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.room == null) {
      return const Center(child: Text('No room available'));
    }

    return Stack(
      children: [
        // Room background
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            border: Border.all(
              color: const Color(0xFFB8A8D8),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/room.svg',
              width: 400,
              height: 400,
            ),
          ),
        ),

        // Chrumko guide (top-right corner) — tap for an instant tip
        Positioned(
          top: 0,
          right: -15,
          child: GestureDetector(
            onTap: _showNextTip,
            child: Image.asset(
              'assets/images/chrumko.png',
              width: 140,
              height: 140,
            ),
          ),
        ),

        // Speech bubble (only visible when _showBubble is true)
        if (_showBubble) _buildSpeechBubble(),

        // Edit button (bottom-right corner)
        if (widget.onEditPressed != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                mini: true,
                heroTag: null,
                backgroundColor: Colors.purple.shade300,
                onPressed: widget.onEditPressed,
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ),
      ],
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