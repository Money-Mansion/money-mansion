class RoomComponent {
  final String id;
  final String name;    // Slovak name
  final String nameEn;  // English name
  final RoomComponentType type;
  final String texture;
  final int cost;
  final double scale;

  RoomComponent({
    required this.id,
    required this.name,
    String? nameEn,     // optional — falls back to name if not provided
    required this.type,
    required this.texture,
    required this.cost,
    this.scale = 1.0,
  }) : nameEn = nameEn ?? name;

  /// Returns the localised name for the given language code.
  String localizedName(String language) =>
      language == 'en' ? nameEn : name;

  RoomComponent copyWith({
    String? id,
    String? name,
    String? nameEn,
    RoomComponentType? type,
    String? texture,
    int? cost,
    double? scale,
  }) {
    return RoomComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      type: type ?? this.type,
      texture: texture ?? this.texture,
      cost: cost ?? this.cost,
      scale: scale ?? this.scale,
    );
  }
}

enum RoomComponentType {
  wall,
  floor,
}

extension RoomComponentTypeString on RoomComponentType {
  String toDisplayString() {
    return toString().split('.').last;
  }
}
