class Room {
  final String id;
  final RoomType type;
  final List<Furniture> furniture;
  final List<Wall> walls;
  final Floor floor;
  
  Room({
    required this.id,
    required this.type,
    this.furniture = const [],
    required this.walls,
    required this.floor,
  });
}

enum RoomType {
  living,
  bedroom,
  kitchen,
  bathroom,
  office,
}

class Furniture {
  final String id;
  final FurnitureType type;
  final Position position;
  
  Furniture({
    required this.id,
    required this.type,
    required this.position,
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
