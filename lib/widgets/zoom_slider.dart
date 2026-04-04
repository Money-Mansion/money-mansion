import 'package:flutter/material.dart';
import '../games/room_world.dart';

/// ZoomSlider is a Flutter widget that provides a horizontal slider for zoom control.
/// - Positioned at the bottom of the screen as an overlay
/// - Drag horizontally to adjust zoom (left = min zoom, right = max zoom)
/// - Only visible in edit mode
class ZoomSlider extends StatefulWidget {
  final RoomWorld gameWorld;

  const ZoomSlider({
    super.key,
    required this.gameWorld,
  });

  @override
  State<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends State<ZoomSlider> {
  late double _currentZoom;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.gameWorld.currentZoom;
  }

  void _updateZoomFromX(double globalX) {
    // Get the RenderBox of the track area
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Convert global X to local X within the widget
    final localX = renderBox.globalToLocal(Offset(globalX, 0)).dx;

    // Track spans the full width since we removed labels
    final trackLeft = 0.0;
    final trackRight = renderBox.size.width;
    final trackWidth = trackRight - trackLeft;

    if (trackWidth <= 0) return;

    // Clamp X to track bounds
    final clampedX = localX.clamp(trackLeft, trackRight);

    // Map X position to zoom (left=min, right=max)
    final relativePos = clampedX - trackLeft;
    final normalizedPos = relativePos / trackWidth;
    final positionRatio = normalizedPos.clamp(0.0, 1.0);

    final minZoom = widget.gameWorld.minZoom;
    final maxZoom = widget.gameWorld.maxZoom;
    final newZoom = minZoom + (maxZoom - minZoom) * positionRatio;

    widget.gameWorld.setZoom(newZoom);
    setState(() {
      _currentZoom = newZoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    _currentZoom = widget.gameWorld.currentZoom;

    return Positioned(
      bottom: 20,
      left: 80,
      right: 80,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Horizontal slider track with draggable thumb
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                _updateZoomFromX(details.globalPosition.dx);
              },
              onHorizontalDragStart: (details) {
                _updateZoomFromX(details.globalPosition.dx);
              },
              child: MouseRegion(
                onHover: (event) {
                  // Allow visual feedback on hover if needed
                },
                child: CustomPaint(
                  painter: _ZoomTrackPainter(currentZoom: _currentZoom, minZoom: widget.gameWorld.minZoom, maxZoom: widget.gameWorld.maxZoom),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the zoom track and thumb
class _ZoomTrackPainter extends CustomPainter {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;

  _ZoomTrackPainter({
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey[100]!,
    );

    // Draw track line (horizontal)
    final trackPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(5, size.height / 2),
      Offset(size.width - 5, size.height / 2),
      trackPaint,
    );

    // Calculate thumb position (zoom range mapped to track width)
    // left=min, right=max
    final zoomRatio = (currentZoom - minZoom) / (maxZoom - minZoom);
    final thumbX = 5 + (zoomRatio * (size.width - 10));

    // Draw thumb (draggable circle)
    final thumbPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(thumbX, size.height / 2),
      6,
      thumbPaint,
    );

    // Draw thumb outline
    final thumbOutline = Paint()
      ..color = Colors.blue[900]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(
      Offset(thumbX, size.height / 2),
      6,
      thumbOutline,
    );

    // Draw filled portion to the right of thumb (to show zoom level)
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(thumbX, 0, size.width - thumbX, size.height),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_ZoomTrackPainter oldDelegate) {
    return oldDelegate.currentZoom != currentZoom;
  }
}


