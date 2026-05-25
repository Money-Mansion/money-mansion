
import 'package:money_mansion/models/item.dart';
import 'package:money_mansion/models/room_component.dart';

class Category {
  final String labelKey;

  // For plain ItemType filtering (e.g. doors)
  final ItemType? itemType;

  // For fine-grained subtype filtering
  final ItemSubtype? itemSubtype;

  // For room-component tabs (walls, floors)
  final bool isRoomComponent;
  final RoomComponentType? componentType;

  const Category({
    required this.labelKey,
    this.itemType,
    this.itemSubtype,
    this.isRoomComponent = false,
    this.componentType,
  });
}

