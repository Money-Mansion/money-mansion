class Item {
  final String id;
  final String name; // Slovak name
  final String nameEn; // English name
  final ItemType type;
  final String texture;
  final int cost;
  final int quantity;
  final String? hitboxId;
  final double scale;

  Item({
    required this.id,
    required this.name,
    String? nameEn, // optional — falls back to name if not provided
    required this.type,
    required this.texture,
    required this.cost,
    this.quantity = 1,
    this.hitboxId,
    this.scale = 1.0,
  }) : nameEn = nameEn ?? name;

  /// Returns the localised name for the given language code.
  String localizedName(String language) => language == 'en' ? nameEn : name;

  Item copyWith({
    String? id,
    String? name,
    String? nameEn,
    ItemType? type,
    String? texture,
    int? cost,
    int? quantity,
    String? hitboxId,
    double? scale,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      type: type ?? this.type,
      texture: texture ?? this.texture,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
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
