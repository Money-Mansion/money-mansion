# Debug Guide: Gesture Input Flow Analysis

## Color-Coded Logs You'll Now See

| Emoji | Component | Event Type | Meaning |
|-------|-----------|-----------|---------|
| 🎥 | CameraControl | Any | Camera gesture event |
| 📦 | ItemComponent | Any | Item gesture event |
| 🏠 | RoomComponent | Any | Room gesture event |
| 🎮 | RoomWorld | Selection | Selection state change |
| 🔴 | Any | Tap | Tap/down event |
| 📍 | Any | Drag | Drag event |

---

## Expected Log Sequences

### ✅ SCENARIO 1: TAP ON EMPTY ROOM (should clear selection)

**EXPECTED LOGS:**
```
🎥🔴 CameraControl.onTapDown()
🎥🔴 CameraControl.onTapUp()
🏠🔴 RoomComponent.onTapDown - editMode=true
🏠🔴   -> CLEARING selection
🎮 RoomWorld.clearSelection() - was selected: null
🎮   -> Selection CLEARED
```

**CURRENT ISSUE:** If you see:
```
🎥🔴 CameraControl.onTapDown()  [stops here]
```
→ CameraComponent is consuming the tap and RoomComponent never gets it

---

### ✅ SCENARIO 2: TAP ON ITEM (should select it)

**EXPECTED LOGS:**
```
🎥🔴 CameraControl.onTapDown()
📦🔴 ItemComponent(gauc).onTapDown - editMode=true
📦🔴   -> SELECTING item gauc
🎮 RoomWorld.selectItem(gauc) - was selected: null
🎮   -> NOW selected: gauc
```

**CURRENT ISSUE:** If you see:
```
🎥🔴 CameraControl.onTapDown()  [stops here]
```
→ CameraComponent is consuming the tap and ItemComponent never gets it

---

### ✅ SCENARIO 3: DRAG ON ITEM (should move it)

**EXPECTED LOGS:**
```
🎥📍 CameraControl.onDragStart()
📦📍 ItemComponent(gauc).onDragStart - editMode=true, isSelected=false
📦📍   -> SELECTING item gauc
🎮 RoomWorld.selectItem(gauc) - was selected: null
🎮   -> NOW selected: gauc

🎥📍 CameraControl.onDragUpdate - editMode=true, selectedItem=gauc
🎥📍   -> SKIPPED (guards failed)   [CORRECT - camera blocked because item selected]

📦📍 ItemComponent(gauc).onDragUpdate delta=(5.2, -3.1)
📦📍   -> MOVING item by (5.2, -3.1)
```

**CURRENT ISSUE:** If camera also prints "PANNING CAMERA" during item drag:
→ Both components are panning simultaneously (conflict)

---

### ✅ SCENARIO 4: DRAG ON EMPTY SPACE (should pan camera)

**EXPECTED LOGS:**
```
🎥📍 CameraControl.onDragStart()
[no ItemComponent logs - no item hit]

🎥📍 CameraControl.onDragUpdate - editMode=true, selectedItem=null
🎥📍   -> PANNING CAMERA by (5.2, -3.1)
```

**CURRENT ISSUE:** If you see:
```
🎥📍 CameraControl.onDragUpdate - editMode=true, selectedItem=null
🎥📍   -> SKIPPED (guards failed)   [WRONG - should pan but doesn't]
```
→ Guard check is incorrectly failing

---

## How to Read the Logs

1. **Open the Dart console** in VS Code or run `flutter run`
2. Look for the emoji-prefixed logs above
3. **Check the sequence:**
   - Do all expected components fire events?
   - Do they fire in the right order?
   - Do guards evaluate correctly?
4. **Check for missing logs:**
   - If ItemComponent logs never appear when tapping items → CameraComponent is blocking
   - If RoomComponent logs never appear when tapping room → CameraComponent is blocking
   - If camera pans when item is selected → Guard failed
   - If camera doesn't pan on empty space → Guard failed or event not reaching camera

---

## The Smoking Gun: `containsLocalPoint()`

**Current code in CameraControlComponent:**
```dart
@override
bool containsLocalPoint(Vector2 point) {
  final result = size != Vector2.zero();
  print('🎥 CameraControl.containsLocalPoint -> size=${size}, result=$result');
  return result;
}
```

**If this prints:**
```
🎥 CameraControl.containsLocalPoint -> size=Vector2(1080.0, 2340.0), result=true
```
→ CameraComponent claims to contain that point and intercepts the event

**The question:** When CameraComponent.containsLocalPoint() returns true, does:
1. CameraComponent consume the event (bad - blocks ItemComponent/RoomComponent)?
2. Or does the event propagate correctly to children (good)?

This is the KEY to understanding why item selection is broken!

---

## What To Do After Running

1. **Run the app** in edit mode
2. **Try each scenario** (tap empty room, tap item, drag item, drag empty space)
3. **Screenshot the logs** or copy them
4. **Share what you see** - that will tell us exactly where the event flow breaks
5. We can then fix the ACTUAL problem instead of guessing

---

## Key Hypothesis to Test

**My suspicion:** CameraComponent.containsLocalPoint() is returning true, which makes Flame think "CameraComponent contains this point, so it should handle all gestures" → and the event never propagates to ItemComponent or RoomComponent below it.

**The fix (if correct):** CameraComponent should NOT claim to contain points that are outside its logical bounds, so events can reach child components.

But we need to see the actual logs to confirm this!
