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
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Pozadie miestnosti
          _buildRoomBackground(),
          
          // 3D perspektíva miestnosti
          Center(
            child: CustomPaint(
              size: const Size(400, 400),
              painter: RoomPainter(room: room!),
            ),
          ),
          
          // Pixel art character v pravom hornom rohu
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
          ],
        ),
      ),
    );
  }

  Widget _buildPixelCharacter() {
    return Icon(
      MyFlutterApp.robot,
      size: 50,
      color: Colors.green[700],
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

    // Kresli steny, potom podlahu, potom nábytok
    _drawWalls(canvas, size, paint);
    _drawFloor(canvas, size, paint);
    _drawFurniture(canvas, size, paint);
  }

  void _drawWalls(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2 + 40; // Posunúť doprava
    final centerY = size.height / 2;
    
    // Rozmery
    final backWallWidth = 260.0;
    final backWallHeight = 180.0;
    final sideDepth = 90.0;
    
    // === ĽAVÁ STENA (tmavšia šedá) ===
    paint.color = const Color(0xFFB0B0B0);
    final leftWall = Path()
      ..moveTo(centerX - backWallWidth / 2, centerY - backWallHeight / 2) // Top zadnej
      ..lineTo(centerX - backWallWidth / 2 - sideDepth, centerY - backWallHeight / 2 + 45) // Top ľavej
      ..lineTo(centerX - backWallWidth / 2 - sideDepth, centerY + backWallHeight / 2 + 45) // Bottom ľavej
      ..lineTo(centerX - backWallWidth / 2, centerY + backWallHeight / 2) // Bottom zadnej
      ..close();
    canvas.drawPath(leftWall, paint);
    
    // === ZADNÁ STENA (svetlo šedá) ===
    paint.color = const Color(0xFFD8D8D8);
    final backWall = Rect.fromLTWH(
      centerX - backWallWidth / 2,
      centerY - backWallHeight / 2,
      backWallWidth,
      backWallHeight,
    );
    canvas.drawRect(backWall, paint);
    
    // === ČIERNE ORÁMOVANIE ===
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    // Ľavá stena outline
    canvas.drawPath(leftWall, paint);
    
    // Zadná stena outline
    canvas.drawRect(backWall, paint);
  
    
    paint.style = PaintingStyle.fill;
  }

  void _drawFloor(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2 + 40;
    final centerY = size.height / 2;
    final backWallWidth = 260.0;
    final backWallHeight = 180.0;
    final sideDepth = 90.0;
    
    // Rohy podlahy
    final backLeft = Offset(centerX - backWallWidth / 2, centerY + backWallHeight / 2); // Ľavý zadný roh
    final backRight = Offset(centerX + backWallWidth / 2, centerY + backWallHeight / 2); // Pravý zadný roh
    final frontLeft = Offset(centerX - backWallWidth / 2 - sideDepth, centerY + backWallHeight / 2 + 45); // Ľavý predný roh
    final frontRight = Offset(centerX + backWallWidth / 2 - sideDepth / 3, centerY + backWallHeight / 2 + 45); // Pravý predný roh
    
    // 4x4 grid podlahy
    final rows = 4;
    final cols = 4;
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // Interpolácia medzi rohmi
        final t1 = row / rows;
        final t2 = (row + 1) / rows;
        final s1 = col / cols;
        final s2 = (col + 1) / cols;
        
        // 4 rohy každej dlaždice
        final p1 = _interpolateQuad(backLeft, backRight, frontLeft, frontRight, s1, t1);
        final p2 = _interpolateQuad(backLeft, backRight, frontLeft, frontRight, s2, t1);
        final p3 = _interpolateQuad(backLeft, backRight, frontLeft, frontRight, s2, t2);
        final p4 = _interpolateQuad(backLeft, backRight, frontLeft, frontRight, s1, t2);
        
        final tilePath = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();
        
        // Striedavé odtiene modrej
        if ((row + col) % 2 == 0) {
          paint.color = const Color(0xFF5BB5E8);
        } else {
          paint.color = const Color(0xFF4AA5D8);
        }
        canvas.drawPath(tilePath, paint);
        
        // Outline dlaždice
        paint.color = const Color(0xFF2A6B8F);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawPath(tilePath, paint);
        paint.style = PaintingStyle.fill;
      }
    }
  }
  
  // Helper funkcia pre bilineárnu interpoláciu
  Offset _interpolateQuad(Offset backLeft, Offset backRight, Offset frontLeft, Offset frontRight, double s, double t) {
    final top = Offset.lerp(backLeft, backRight, s)!;
    final bottom = Offset.lerp(frontLeft, frontRight, s)!;
    return Offset.lerp(top, bottom, t)!;
  }

  void _drawFurniture(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2 + 40; // Posunúť doprava
    final centerY = size.height / 2;
    final backWallWidth = 260.0;
    final backWallHeight = 180.0;
    
    // === DVERE (ľavá strana zadnej steny) ===
    final doorX = centerX - backWallWidth / 2 + 40;
    final doorY = centerY - backWallHeight / 2 + 35;
    final doorWidth = 48.0;
    final doorHeight = 85.0;
    
    // Hnedé dvere
    paint.color = const Color(0xFF8B6239);
    final doorRect = Rect.fromLTWH(doorX, doorY, doorWidth, doorHeight);
    canvas.drawRect(doorRect, paint);
    
    // Tmavší rám dverí
    paint.color = const Color(0xFF5D3F1F);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawRect(doorRect, paint);
    paint.style = PaintingStyle.fill;
    
    // Kľučka
    paint.color = const Color(0xFF404040);
    canvas.drawCircle(
      Offset(doorX + 10, doorY + doorHeight / 2),
      3.5,
      paint,
    );
    
    // === OKNO (pravá strana zadnej steny) ===
    final windowX = centerX + backWallWidth / 2 - 95;
    final windowY = centerY - backWallHeight / 2 + 30;
    final windowSize = 68.0;
    
    // Hnedý rám okna (vonkajší)
    paint.color = const Color(0xFF9B6B3C);
    final outerFrame = Rect.fromLTWH(windowX - 5, windowY - 5, windowSize + 10, windowSize + 10);
    canvas.drawRect(outerFrame, paint);
    
    // Svetlo modré sklo
    paint.color = const Color(0xFFADD8E6);
    final windowGlass = Rect.fromLTWH(windowX, windowY, windowSize, windowSize);
    canvas.drawRect(windowGlass, paint);
    
    // Tmavý vonkajší rám
    paint.color = const Color(0xFF5D3F1F);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawRect(outerFrame, paint);
    
    // Krížový rám (4 okienka)
    paint.strokeWidth = 3.5;
    paint.color = const Color(0xFF7A5230);
    // Vertikálna čiara
    canvas.drawLine(
      Offset(windowX + windowSize / 2, windowY),
      Offset(windowX + windowSize / 2, windowY + windowSize),
      paint,
    );
    // Horizontálna čiara
    canvas.drawLine(
      Offset(windowX, windowY + windowSize / 2),
      Offset(windowX + windowSize, windowY + windowSize / 2),
      paint,
    );
    
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
