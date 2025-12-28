import 'package:flutter/material.dart';
import '../models/room.dart';
import '../my_flutter_app_icons.dart';

class RoomViewer extends StatelessWidget {
  final Room? room;

  const RoomViewer({
    super.key,
    this.room,
  });

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return const Center(
        child: Text('No room available'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5), // Soft cream background
        border: Border.all(
          color: const Color(0xFFB8A8D8), // Soft purple border
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background gradient
          _buildRoomBackground(),
          
          // 3D room perspective
          Center(
            child: CustomPaint(
              size: const Size(400, 400),
              painter: RoomPainter(room: room!),
            ),
          ),
          
          // Character in top right corner
          Positioned(
            top: 20,
            right: 20,
            child: _buildPixelCharacter(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF5F7),
            Color(0xFFFFFBF5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildPixelCharacter() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: MyFlutterApp.cat),
    );
  }
}

class RoomPainter extends CustomPainter {
  final Room room;

  RoomPainter({required this.room});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw in order: walls, floor, furniture, decorations
    _drawWalls(canvas, size, paint);
    _drawFloor(canvas, size, paint);
    _drawFurniture(canvas, size, paint);
  }

  void _drawWalls(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 20;
    
    // Room dimensions
    final wallWidth = 300.0;
    final wallHeight = 220.0;
    final depth = 70.0;
    
    // === LEFT WALL (side perspective) - ROUNDED ===
    // Create gradient for 3D effect
    final leftWallRect = Rect.fromPoints(
      Offset(centerX - wallWidth / 2 - depth, centerY - wallHeight / 2 + 40),
      Offset(centerX - wallWidth / 2, centerY + wallHeight / 2),
    );
    final leftWallGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFFE8CC),
        const Color(0xFFFFF0DC),
      ],
    );
    
    final leftWall = Path()
      ..moveTo(centerX - wallWidth / 2 + 10, centerY - wallHeight / 2) // Start with offset for rounding
      // Top left corner - rounded
      ..lineTo(centerX - wallWidth / 2 - depth + 10, centerY - wallHeight / 2 + 40)
      ..arcToPoint(
        Offset(centerX - wallWidth / 2 - depth, centerY - wallHeight / 2 + 50),
        radius: const Radius.circular(10),
        clockwise: false,
      )
      // Left edge
      ..lineTo(centerX - wallWidth / 2 - depth, centerY + wallHeight / 2 + 30)
      // Bottom left corner - rounded
      ..arcToPoint(
        Offset(centerX - wallWidth / 2 - depth + 10, centerY + wallHeight / 2 + 40),
        radius: const Radius.circular(10),
        clockwise: false,
      )
      // Bottom edge
      ..lineTo(centerX - wallWidth / 2 + 10, centerY + wallHeight / 2)
      // Bottom right corner - rounded
      ..arcToPoint(
        Offset(centerX - wallWidth / 2, centerY + wallHeight / 2 - 10),
        radius: const Radius.circular(10),
        clockwise: false,
      )
      // Right edge
      ..lineTo(centerX - wallWidth / 2, centerY - wallHeight / 2 + 10)
      // Top right corner - rounded
      ..arcToPoint(
        Offset(centerX - wallWidth / 2 + 10, centerY - wallHeight / 2),
        radius: const Radius.circular(10),
        clockwise: false,
      )
      ..close();
    
    paint.shader = leftWallGradient.createShader(leftWallRect);
    canvas.drawPath(leftWall, paint);
    paint.shader = null;
    
    // Left wall outline - softer
    paint.color = const Color(0xFFFFD4A3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.strokeJoin = StrokeJoin.round;
    canvas.drawPath(leftWall, paint);
    paint.style = PaintingStyle.fill;
    
    // === BACK WALL (main wall) ===
    paint.color = const Color(0xFFFFFBF0);
    final backWall = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - wallWidth / 2,
        centerY - wallHeight / 2,
        wallWidth,
        wallHeight,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(backWall, paint);
    
    // Wall outline
    paint.color = const Color(0xFFFFE4B8);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawRRect(backWall, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawFloor(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 20;
    final wallWidth = 300.0;
    final wallHeight = 220.0;
    final depth = 70.0;
    
// Isometric floor (ROUNDED)
final backLeft =
    Offset(centerX - wallWidth / 2, centerY + wallHeight / 2);
final backRight =
    Offset(centerX + wallWidth / 2, centerY + wallHeight / 2);
final frontLeft =
    Offset(centerX - wallWidth / 2 - depth, centerY + wallHeight / 2 + 40);
final frontRight =
    Offset(centerX + wallWidth / 2 - depth, centerY + wallHeight / 2 + 40);

const radius = 16.0;

Offset inset(Offset from, Offset to) {
  final dir = to - from;
  return from + dir / dir.distance * radius;
}

final bl1 = inset(backLeft, backRight);
final bl2 = inset(backLeft, frontLeft);

final br1 = inset(backRight, frontRight);
final br2 = inset(backRight, backLeft);

final fr1 = inset(frontRight, frontLeft);
final fr2 = inset(frontRight, backRight);

final fl1 = inset(frontLeft, backLeft);
final fl2 = inset(frontLeft, frontRight);

final floorPath = Path()
  ..moveTo(bl1.dx, bl1.dy)
  ..quadraticBezierTo(backLeft.dx, backLeft.dy, bl2.dx, bl2.dy)
  ..lineTo(fl1.dx, fl1.dy)
  ..quadraticBezierTo(frontLeft.dx, frontLeft.dy, fl2.dx, fl2.dy)
  ..lineTo(fr1.dx, fr1.dy)
  ..quadraticBezierTo(frontRight.dx, frontRight.dy, fr2.dx, fr2.dy)
  ..lineTo(br1.dx, br1.dy)
  ..quadraticBezierTo(backRight.dx, backRight.dy, br2.dx, br2.dy)
  ..close();

// Floor base color
paint.color = const Color(0xFFFFE4B8);
canvas.drawPath(floorPath, paint);

// Soft outer edge (adds roundness)
paint
  ..color = const Color(0x33FFB45C)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 8;
canvas.drawPath(floorPath, paint);

// Floor outline
paint
  ..color = const Color(0xFFFFCF8A)
  ..strokeWidth = 3;
canvas.drawPath(floorPath, paint);

paint.style = PaintingStyle.fill;

// ===== FLOOR GRID (unchanged geometry, nicer style) =====

final rows = 6;
final cols = 6;

paint
  ..color = const Color(0xAAFFCF8A)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2
  ..strokeCap = StrokeCap.round;

// Horizontal lines
for (int i = 1; i < rows; i++) {
  final t = i / rows;
  final leftPoint = Offset.lerp(backLeft, frontLeft, t)!;
  final rightPoint = Offset.lerp(backRight, frontRight, t)!;
  canvas.drawLine(leftPoint, rightPoint, paint);
}

// Vertical lines
for (int i = 1; i < cols; i++) {
  final t = i / cols;
  final backPoint = Offset.lerp(backLeft, backRight, t)!;
  final frontPoint = Offset.lerp(frontLeft, frontRight, t)!;
  canvas.drawLine(backPoint, frontPoint, paint);
}

paint.style = PaintingStyle.fill;

  }

  void _drawFurniture(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 20;
    final wallWidth = 300.0;
    final wallHeight = 220.0;
    
    // === DOOR (left side of back wall) ===
    final doorX = centerX - wallWidth / 2 + 45;
    final doorY = centerY ;
    final doorWidth = 60.0;
    final doorHeight = 105.0;
    
    // Door shadow
    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(doorX + 2, doorY + 2, doorWidth, doorHeight),
        const Radius.circular(10),
      ),
      paint,
    );
    
    // Door body
    paint.color = const Color(0xFFFF9977);
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(doorX, doorY, doorWidth, doorHeight),
      const Radius.circular(10),
    );
    canvas.drawRRect(doorRect, paint);
    
    // Door panels
    paint.color = const Color(0xFFFF8866);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    // Top panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(doorX + 8, doorY + 8, doorWidth - 16, doorHeight / 2 - 12),
        const Radius.circular(6),
      ),
      paint,
    );
    
    // Bottom panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(doorX + 8, doorY + doorHeight / 2 + 4, doorWidth - 16, doorHeight / 2 - 12),
        const Radius.circular(6),
      ),
      paint,
    );
    
    // Door outline
    paint.strokeWidth = 4;
    canvas.drawRRect(doorRect, paint);
    paint.style = PaintingStyle.fill;
    
    // Door handle
    paint.color = const Color(0xFFFFDD88);
    canvas.drawCircle(
      Offset(doorX + doorWidth - 15, doorY + doorHeight / 2),
      5,
      paint,
    );
    
    paint.color = const Color(0xFFFFAA44);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(
      Offset(doorX + doorWidth - 15, doorY + doorHeight / 2),
      5,
      paint,
    );
    paint.style = PaintingStyle.fill;
    
    // === WINDOW (right side of back wall) ===
    final windowX = centerX + wallWidth / 2 - 120;
    final windowY = centerY - wallHeight / 2 + 45;
    final windowSize = 85.0;
    
    // Window shadow
    paint.color = Colors.black.withOpacity(0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(windowX - 5 + 2, windowY - 5 + 2, windowSize + 10, windowSize + 10),
        const Radius.circular(12),
      ),
      paint,
    );
    
    // Window frame (outer)
    paint.color = const Color(0xFFFFB4B4);
    final windowFrame = RRect.fromRectAndRadius(
      Rect.fromLTWH(windowX - 8, windowY - 8, windowSize + 16, windowSize + 16),
      const Radius.circular(12),
    );
    canvas.drawRRect(windowFrame, paint);
    
    // Window glass with gradient effect
    final glassRect = Rect.fromLTWH(windowX, windowY, windowSize, windowSize);
    final glassGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFD4F1FF),
        const Color(0xFFB8E6F5),
      ],
    );
    paint.shader = glassGradient.createShader(glassRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassRect, const Radius.circular(6)),
      paint,
    );
    paint.shader = null;
    
    // Window cross frame
    paint.color = const Color(0xFFFFB4B4);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    
    // Vertical line
    canvas.drawLine(
      Offset(windowX + windowSize / 2, windowY),
      Offset(windowX + windowSize / 2, windowY + windowSize),
      paint,
    );
    // Horizontal line
    canvas.drawLine(
      Offset(windowX, windowY + windowSize / 2),
      Offset(windowX + windowSize, windowY + windowSize / 2),
      paint,
    );
    
    // Window frame outline
    paint.strokeWidth = 4;
    canvas.drawRRect(windowFrame, paint);
    paint.style = PaintingStyle.fill;

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}