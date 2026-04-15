
import 'package:money_mansion_skeleton/models/item.dart';
import 'package:money_mansion_skeleton/models/room_component.dart';

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------

/// Fine-grained item subtypes used for tab filtering.
/// These live purely in the UI layer — no changes needed to Item/ItemType.

enum ItemSubtype {
  beds,
  seating,
  tables,
  storage,
  carpets,
  wallDecor,
  plants,
  lighting,
}


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

