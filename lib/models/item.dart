class Item {
  final String id;
  final String name;
  final String nameEn;
  final ItemType type;
  final ItemSubtype? subtype;
  final String texture;
  final int cost;
  final int quantity;
  final String? hitboxId;
  final double scale;

  Item({
    required this.id,
    required this.name,
    String? nameEn,
    required this.type,
    this.subtype,
    required this.texture,
    required this.cost,
    this.quantity = 1,
    this.hitboxId,
    this.scale = 1.0,
  }) : nameEn = nameEn ?? name;

  String localizedName(String language) => language == 'en' ? nameEn : name;

  Item copyWith({
    String? id,
    String? name,
    String? nameEn,
    ItemType? type,
    ItemSubtype? subtype,
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
      subtype: subtype ?? this.subtype,
      texture: texture ?? this.texture,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      hitboxId: hitboxId ?? this.hitboxId,
      scale: scale ?? this.scale,
    );
  }
}

enum ItemSubtype {
  beds,
  seating,
  tables,
  storage,
  carpets,
  wallDecor,
  plants,
  lighting,
  pets,
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

  String toLocalizedDisplayString(String language) {
    switch (this) {
      case ItemType.door:
        return language == 'sk' ? 'Dvere' : 'Door';
      case ItemType.window:
        return language == 'sk' ? 'Okno' : 'Window';
      case ItemType.furniture:
        return language == 'sk' ? 'Nábytok' : 'Furniture';
      case ItemType.flooring:
        return language == 'sk' ? 'Podlaha' : 'Flooring';
      case ItemType.wallpaper:
        return language == 'sk' ? 'Tapeta' : 'Wallpaper';
      case ItemType.decoration:
        return language == 'sk' ? 'Dekorácia' : 'Decoration';
    }
  }
}