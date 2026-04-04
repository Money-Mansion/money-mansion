class RoomItemPlacement {
  final String roomId;
  final String itemId;
  final double x;
  final double y;
  final bool isFlipped;

  RoomItemPlacement({
    required this.roomId,
    required this.itemId,
    required this.x,
    required this.y,
    this.isFlipped = false,
  });
}

