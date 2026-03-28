import 'dart:math';
import 'package:flame/components.dart';

/// Represents a single convex polygon used for collision detection
class Polygon {
  final List<Vector2> points;
  
  /// Epsilon tolerance for edge detection (in units)
  /// Points within this distance of an edge are considered inside the polygon
  static const double epsilon = 0.2;

  Polygon({required this.points});

  /// Calculate the perpendicular distance from a point to a line segment
  /// Returns the shortest distance from the point to the line segment
  double _distanceToSegment(Vector2 point, Vector2 p1, Vector2 p2) {
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    final lengthSquared = dx * dx + dy * dy;

    if (lengthSquared == 0) {
      // Segment is a point
      return point.distanceTo(p1);
    }

    // Calculate the projection of point onto the line segment
    var t = ((point.x - p1.x) * dx + (point.y - p1.y) * dy) / lengthSquared;
    t = t.clamp(0.0, 1.0);

    // Find the closest point on the segment
    final closestX = p1.x + t * dx;
    final closestY = p1.y + t * dy;

    // Calculate distance to the closest point
    final distX = point.x - closestX;
    final distY = point.y - closestY;
    return sqrt(distX * distX + distY * distY);
  }

  /// Check if a point is on or very close to any edge of this polygon
  bool _isPointOnEdge(Vector2 point) {
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      final distance = _distanceToSegment(point, p1, p2);
      if (distance < epsilon) {
        return true;
      }
    }
    return false;
  }

  /// Check if a point is inside this polygon using ray casting algorithm
  /// Now includes epsilon tolerance for boundary points
  bool containsPoint(Vector2 point) {
    if (points.length < 3) return false;

    // First, check if the point is on or very close to an edge
    if (_isPointOnEdge(point)) {
      return true;
    }

    // Standard ray-casting algorithm
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
