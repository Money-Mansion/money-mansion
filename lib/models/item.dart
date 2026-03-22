class Item {
  final String id;
  final String name;
  final ItemType type;
  final String texture; // Path to image in assets
  final int cost;
  final String? hitboxId; // ID for loading hitbox from .convexshape file (defaults to id if null)
  final double scale; // Scale factor for rendering (0.0 - 1.0+, default 1.0)

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.texture,
    required this.cost,
    this.hitboxId,
    this.scale = 1.0,
  });

  Item copyWith({
    String? id,
    String? name,
    ItemType? type,
    String? texture,
    int? cost,
    String? hitboxId,
    double? scale,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      texture: texture ?? this.texture,
      cost: cost ?? this.cost,
      hitboxId: hitboxId ?? this.hitboxId,
      scale: scale ?? this.scale,
    );
  }
}

enum ItemType {
  door,
  window,
  furniture,
  flooring,
  wallpaper,
  decoration,
}

extension ItemTypeString on ItemType {
  String toDisplayString() {
    return toString().split('.').last;
  }
}
