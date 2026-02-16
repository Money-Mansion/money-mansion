class Item {
  final String id;
  final String name;
  final ItemType type;
  final String texture; // Path to image in assets
  final int cost;

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.texture,
    required this.cost,
  });

  Item copyWith({
    String? id,
    String? name,
    ItemType? type,
    String? texture,
    int? cost,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      texture: texture ?? this.texture,
      cost: cost ?? this.cost,
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
