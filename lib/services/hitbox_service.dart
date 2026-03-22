import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../models/hitbox.dart';

/// Service for loading and caching hitbox data from .convexshape files
class HitboxService {
  static final HitboxService _instance = HitboxService._internal();
  final Map<String, Hitbox> _cache = {};

  HitboxService._internal();

  factory HitboxService() {
    return _instance;
  }

  /// Load a hitbox from a .convexshape file
  /// Returns a cached hitbox if already loaded
  /// Returns a default box hitbox if file not found
  Future<Hitbox> loadHitbox(String hitboxId) async {
    // Return cached hitbox if available
    if (_cache.containsKey(hitboxId)) {
      return _cache[hitboxId]!;
    }

    try {
      final filePath = 'assets/hitboxes/$hitboxId.convexshape';
      final fileContent = await rootBundle.loadString(filePath);
      final hitbox = _parseConvexShape(hitboxId, fileContent);
      _cache[hitboxId] = hitbox;
      return hitbox;
    } catch (e) {
      print('Warning: Could not load hitbox file for "$hitboxId": $e');
      print('Using default box hitbox for "$hitboxId"');
      final defaultHitbox = _createDefaultBoxHitbox(hitboxId);
      _cache[hitboxId] = defaultHitbox;
      return defaultHitbox;
    }
  }

  /// Parse Defold format .convexshape file
  /// Format: 
  /// shape_type: TYPE_HULL
  /// data: x1
  /// data: y1
  /// data: z1
  /// data: x2
  /// ... etc
  /// 
  /// Note: Flips Y coordinates to match Flame's coordinate system
  Hitbox _parseConvexShape(String id, String content) {
    final lines = content.split('\n');
    final dataPoints = <double>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('data:')) {
        final valueStr = trimmed.replaceFirst('data:', '').trim();
        if (valueStr.isNotEmpty) {
          try {
            dataPoints.add(double.parse(valueStr));
          } catch (e) {
            print('Warning: Could not parse data value "$valueStr"');
          }
        }
      }
    }

    if (dataPoints.isEmpty) {
      print('Warning: No data points found in hitbox file');
      return _createDefaultBoxHitbox(id);
    }

    // Convert flat list of coordinates into polygons
    // Every 3 values = one point (x, y, z), ignore z
    final polygons = <Polygon>[];
    final points = <Vector2>[];
    double minY = double.infinity, maxY = double.negativeInfinity;

    // First pass: collect points and find Y bounds
    for (int i = 0; i < dataPoints.length; i += 3) {
      if (i + 1 < dataPoints.length) {
        final y = dataPoints[i + 1];
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    // Second pass: create points with flipped Y coordinates
    for (int i = 0; i < dataPoints.length; i += 3) {
      if (i + 1 < dataPoints.length) {
        final x = dataPoints[i];
        final y = dataPoints[i + 1];
        // z is at i + 2, but we ignore it for 2D collision
        // Mirror Y around the midpoint to match Flame's coordinate system
        final flippedY = minY + (maxY - y);
        points.add(Vector2(x, flippedY));
      }
    }

    if (points.isNotEmpty) {
      polygons.add(Polygon(points: points));
    }

    return Hitbox(id: id, polygons: polygons);
  }

  /// Create a default square hitbox (100x100)
  Hitbox _createDefaultBoxHitbox(String id) {
    const size = 50.0; // Half-size from center
    final points = [
      Vector2(-size, -size),
      Vector2(size, -size),
      Vector2(size, size),
      Vector2(-size, size),
    ];
    return Hitbox(id: id, polygons: [Polygon(points: points)]);
  }

  /// Clear the cache (useful for testing or memory management)
  void clearCache() {
    _cache.clear();
  }

  /// Get cache info (for debugging)
  Map<String, int> getCacheInfo() {
    return {
      for (final entry in _cache.entries)
        entry.key: entry.value.polygons.fold(
          0,
          (sum, poly) => sum + poly.points.length,
        ),
    };
  }
}
