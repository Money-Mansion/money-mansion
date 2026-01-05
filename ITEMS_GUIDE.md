# Items System Guide

This guide explains how to add new items to the Money Mansion app.

## Item Structure

Every item in the game has these properties:

- **id**: Unique identifier (use snake_case, e.g., `basic_door`)
- **name**: Display name shown to player (e.g., `Basic Door`)
- **type**: Category of the item (door, window, furniture, flooring, wallpaper, decoration)
- **texture**: Path to the image file in assets (e.g., `assets/images/basic_door.png`)
- **cost**: Cost in coins (for shop/future use)
- **owned**: Whether the player owns this item (true/false)

## Example Item: Basic Door

```dart
Item(
  id: 'basic_door',
  name: 'Basic Door',
  type: ItemType.door,
  texture: 'assets/images/basic_door.png',
  cost: 1,
  owned: true, // Player starts with this
)
```

## Adding a New Item

### Step 1: Prepare the Image
- Add your item's image to `assets/images/`
- Image name should match the item id (e.g., `my_furniture.png`)
- Keep the image file size reasonable

### Step 2: Add Item to Database Initialization
In `lib/main.dart`, find the section where items are initialized and add your new item:

```dart
// Example: Adding a wooden table
final woodenTable = Item(
  id: 'wooden_table',
  name: 'Wooden Table',
  type: ItemType.furniture,
  texture: 'assets/images/wooden_table.png',
  cost: 50,
  owned: false, // Player must buy this
);

await ItemDatabaseService.createItem(woodenTable);
```

### Step 3: Update pubspec.yaml (if needed)
Make sure your image is listed in `pubspec.yaml` under assets:

```yaml
flutter:
  assets:
    - assets/images/basic_door.png
    - assets/images/wooden_table.png
    # ... other images
```

## Item Types Reference

- **door**: Doors and entrances
- **window**: Windows and glass elements
- **furniture**: Tables, chairs, beds, sofas, etc.
- **flooring**: Floor types and rugs
- **wallpaper**: Wall decorations and paints
- **decoration**: Misc decorations, plants, artwork

## Inventory Display

Owned items are automatically displayed in the Inventory screen with:
- Item texture (image)
- Item name
- Item type (as a tag/label)

No additional code needed for display once the item is in the database with `owned: true`.

## Database Persistence

All items (owned and not owned) are stored in the SQLite database. This means:
- When you add a new item, it persists across app restarts
- Ownership status is saved in the database
- You only need to create items once (on first app run)

## Checklist for Adding Items

- [ ] Image file added to `assets/images/`
- [ ] Image file name matches item id
- [ ] Item added to initialization code in `main.dart`
- [ ] pubspec.yaml updated with image path
- [ ] ItemType is correct
- [ ] All required fields are filled
