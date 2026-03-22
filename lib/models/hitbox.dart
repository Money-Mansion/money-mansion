import 'package:flame/components.dart';

/// Represents a single convex polygon used for collision detection
class Polygon {
  final List<Vector2> points;

  Polygon({required this.points});

  /// Check if a point is inside this polygon using ray casting algorithm
  bool containsPoint(Vector2 point) {
    if (points.length < 3) return false;

    int crossings = 0;
    for (int i = 0; i < points.length; i++) {
      Vector2 p1 = points[i];
      Vector2 p2 = points[(i + 1) % points.length];

      // Check if the ray crosses this edge
      if ((p1.y <= point.y && point.y < p2.y) ||
          (p2.y <= point.y && point.y < p1.y)) {
        // Calculate the x-coordinate of the intersection
        double xIntersect =
            (p2.x - p1.x) * (point.y - p1.y) / (p2.y - p1.y) + p1.x;
        if (point.x < xIntersect) {
          crossings++;
        }
      }
    }

    return crossings % 2 == 1;
  }
}

/// Represents the complete hitbox for an item, which can contain multiple polygons
class Hitbox {
  final String id;
  final List<Polygon> polygons;

  Hitbox({required this.id, required this.polygons});

  /// Check if a point is inside any of the polygons
  bool containsPoint(Vector2 point) {
    return polygons.any((polygon) => polygon.containsPoint(point));
  }

  /// Get all vertices from all polygons (useful for rendering)
  List<Vector2> getAllVertices() {
    final vertices = <Vector2>[];
    for (final polygon in polygons) {
      vertices.addAll(polygon.points);
    }
    return vertices;
  }
}
