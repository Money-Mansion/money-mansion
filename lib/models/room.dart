class Room {
  final List<Furniture> furniture;
  final List<Wall> walls;
  final Floor floor;
  
  Room({
    this.furniture = const [],
    required this.walls,
    required this.floor,
  });
}

class Furniture {
  final FurnitureType type;
  final Position position;
  final int cost; // Cost to buy this furniture
  
  Furniture({
    required this.type,
    required this.position,
    this.cost = 0,
  });
}

enum FurnitureType {
  door,
  window,
  table,
  chair,
  bed,
  sofa,
}

class Wall {
  final WallStyle style;
  final Direction direction;
  
  Wall({
    required this.style,
    required this.direction,
  });
}

enum WallStyle {
  basic,
  painted,
  wallpaper,
}

enum Direction {
  north,
  south,
  east,
  west,
}

class Floor {
  final FloorType type;
  final int gridSize;
  
  Floor({
    required this.type,
    this.gridSize = 16, // 4x4 grid
  });
}

enum FloorType {
  wood,
  tile,
  carpet,
  marble,
}

class Position {
  final double x;
  final double y;
  
  Position({required this.x, required this.y});
}
