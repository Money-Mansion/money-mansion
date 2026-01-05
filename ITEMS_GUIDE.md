# Items System Guide for Graphic Developers

This guide explains how to add new items to the Money Mansion game.

## Quick Summary

1. Create your item image and save it to `assets/images/`
2. Add one line of code to `lib/config/items_config.dart`
3. Restart the app
4. Done! Your item appears in the shop

---

## Step-by-Step: Adding an Item

### Step 1: Create and Save Your Image
- Export/save your item graphic as **PNG format**
- Place the file in `assets/images/` folder
- Name it something descriptive and simple
- **Example:** `golden_lamp.png`, `red_chair.png`, `marble_floor.png`

### Step 2: Add Item to items_config.dart

Open `lib/config/items_config.dart` and add your item to the `GAME_ITEMS` list:

```dart
final List<Item> GAME_ITEMS = [
  // Existing items...
  
  // YOUR NEW ITEM
  Item(
    id: 'golden_lamp',              // Must be unique, lowercase, underscores only
    name: 'Golden Lamp',            // Display name shown in game
    type: ItemType.decoration,      // Category (see list below)
    texture: 'assets/images/golden_lamp.png',  // Path to your image
    cost: 75,                       // Price in coins
    owned: false,                   // Players must buy this (don't change)
  ),
];
```

### Step 3: Restart the App
- Stop the running app
- Press "Run" or hot restart
- Your item is now in the shop! 

---

## Item Properties Explained

| Field | Example | Rules |
|-------|---------|-------|
| `id` | `'golden_lamp'` | Unique identifier. Use lowercase letters, numbers, and underscores only. No spaces. |
| `name` | `'Golden Lamp'` | Display name. Can have spaces and capitals. |
| `type` | `ItemType.decoration` | Category. See types list below. |
| `texture` | `'assets/images/golden_lamp.png'` | Path to PNG file. Must match your filename exactly. |
| `cost` | `75` | How many coins the player pays to buy it. |
| `owned` | `false` | Always use `false`. Players buy items; they don't own them by default. |

---

## Item Types (Choose One)

```dart
ItemType.door        // Doors, gates, entrances
ItemType.window      // Windows, glass, panes
ItemType.furniture   // Tables, chairs, beds, sofas, shelves
ItemType.flooring    // Floors, rugs, carpets
ItemType.wallpaper   // Wall colors, wallpaper, wall art
ItemType.decoration  // Plants, lamps, sculptures, misc decor
```

---

## Complete Example

**Your graphic:** A marble floor tile

```dart
Item(
  id: 'marble_floor_tile',
  name: 'Marble Floor',
  type: ItemType.flooring,
  texture: 'assets/images/marble_floor_tile.png',
  cost: 120,
  owned: false,
)
```

---

## Important Notes

✅ **DO:**
- Use lowercase with underscores for `id` (e.g., `red_sofa`, `blue_door`)
- Match the `texture` path exactly to your filename
- Save images as PNG files
- Set `owned: false` always

❌ **DON'T:**
- Use spaces or capitals in `id`
- Change the `owned` field
- Create duplicate `id` values
- Add the image path to `pubspec.yaml` (it's already configured)

---

## What Happens After I Add an Item?

1. When the app starts, your item is added to the game database
2. Your item appears in the **Shop** (someone else builds the shop UI)
3. Players can see it and buy it with coins
4. Once owned, it appears in the **Inventory** screen

---

## Troubleshooting

**Problem:** App crashes when starting
- **Solution:** Check that your image file path in `texture:` exactly matches the filename in `assets/images/`

**Problem:** Item doesn't appear in shop
- **Solution:** Make sure `id` doesn't have spaces or special characters (use only letters, numbers, underscores)

**Problem:** Inventory shows broken image
- **Solution:** Verify the PNG file exists in `assets/images/` and the path in `texture:` is correct
