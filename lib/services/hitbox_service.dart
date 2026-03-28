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
    final polygons = <Polygon>[];
    
    // Parse each TYPE_HULL section separately
    List<List<double>> hullSections = [];
    List<double> currentHull = [];
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // New hull section detected
      if (trimmed.startsWith('shape_type:')) {
        if (currentHull.isNotEmpty) {
          hullSections.add(currentHull);
          currentHull = [];
        }
      }
      // Parse data points
      else if (trimmed.startsWith('data:')) {
        final valueStr = trimmed.replaceFirst('data:', '').trim();
        if (valueStr.isNotEmpty) {
          try {
            currentHull.add(double.parse(valueStr));
          } catch (e) {
            print('Warning: Could not parse data value "$valueStr"');
          }
        }
      }
    }
    
    // Don't forget the last hull
    if (currentHull.isNotEmpty) {
      hullSections.add(currentHull);
    }
    
    if (hullSections.isEmpty) {
      print('Warning: No hull sections found in hitbox file for $id');
      return _createDefaultBoxHitbox(id);
    }
    
    // Convert each hull section into a separate polygon
    // First, find global Y bounds across all hulls
    double minY = double.infinity, maxY = double.negativeInfinity;
    
    for (final hullData in hullSections) {
      for (int i = 0; i < hullData.length; i += 3) {
        if (i + 1 < hullData.length) {
          final y = hullData[i + 1];
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    
    // Create a polygon for each hull
    for (final hullData in hullSections) {
      final points = <Vector2>[];
      
      for (int i = 0; i < hullData.length; i += 3) {
        if (i + 1 < hullData.length) {
          final x = hullData[i];
          final y = hullData[i + 1];
          // z is at i + 2, but we ignore it for 2D collision
          // Mirror Y around the midpoint to match Flame's coordinate system
          final flippedY = minY + (maxY - y);
          points.add(Vector2(x, flippedY));
        }
      }
      
      if (points.isNotEmpty) {
        polygons.add(Polygon(points: points));
      }
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
