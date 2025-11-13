# Money Mansion - Flutter Game Skeleton

Kostra mobilnej hry Money Mansion vytvorená vo Flutteru. Aplikácia poskytuje základnú štruktúru pre manažment miestností, herných zdrojov (coins, emeralds), navigáciu medzi obrazovkami a 3D izometrickú vizualizáciu miestností.

## 📁 Štruktúra Projektu

### `lib/main.dart`
- **Účel**: Vstupný bod aplikácie
- **Funkcia**: Inicializuje aplikáciu `MoneyMansionApp`, nastavuje Material Design 3 tému a routuje na `GameScreen`
- **Kľúčové**: `MaterialApp` s vypnutým debug banner

### `lib/screens/`

#### `game_screen.dart`
- **Účel**: Hlavná herná obrazovka - kontajner pre všetky sekcie
- **Funkcia**: 
  - Inicializuje `GameState` s predvolenými hodnotami (111 coins, 780 emeralds, dátum 7.7)
  - Spravuje navigáciu medzi obrazovkami cez `selectedNavIndex`
  - Prepína medzi 5 obrazovkami: Home (Room Viewer), Tasks, Shop, Stats, Inventory
- **Komponenty**: TopBar, RoomViewer/Screens, BottomNavigation
- **State Management**: `StatefulWidget` s `_GameScreenState`

#### `shop_screen.dart`
- **Účel**: Obchod s nábytkom a vylepšeniami
- **Funkcia**: Placeholder obrazovka s ikonou košíka
- **Použitie**: Kde hráči budú nakupovať nábytok, dekorácie, vylepšenia za coins/emeralds
- **Navigácia**: Index 2 (košík icon)

#### `tasks_screen.dart`
- **Účel**: Denné úlohy a misie
- **Funkcia**: Placeholder obrazovka s ikonou úloh
- **Použitie**: Zoznam úloh, ktoré hráč môže splniť za odmeny
- **Navigácia**: Index 1 (terč icon)

#### `inventory_screen.dart`
- **Účel**: Inventár predmetov a nábytku
- **Funkcia**: Placeholder obrazovka s ikonou inventára
- **Použitie**: Zobrazenie vlastnených predmetov, nábytku, zdrojov
- **Navigácia**: Index 4 (user icon)

#### `stats_screen.dart`
- **Účel**: Štatistiky a úspechy hráča
- **Funkcia**: Placeholder obrazovka s grafom
- **Použitie**: Zobrazenie progresie, achievementov, štatistík
- **Navigácia**: Index 3 (graf icon)

#### `profile_screen.dart`
- **Účel**: Profil hráča (momentálne nepoužitý)
- **Funkcia**: Záložná obrazovka pre profil
- **Poznámka**: Index 4 používa `inventory_screen.dart` namiesto tohto

#### `settings_screen.dart`
- **Účel**: Herné nastavenia a možnosti
- **Funkcia**: Placeholder pre nastavenia zvuku, grafiky, účtu
- **Navigácia**: Cez settings ikonu v ľavom hornom rohu TopBar

### `lib/widgets/`

#### `top_bar.dart`
- **Účel**: Horná lišta s hernými zdrojmi
- **Funkcia**: 
  - Zobrazuje ikonu nastavení (kliknuteľná - otvára `SettingsScreen`)
  - Zobrazuje coins (oranžová ikona + počet)
  - Zobrazuje emeralds (zelená ikona + počet)
  - Zobrazuje dátum v kalendárovom widgete (červená hlavička "JUL", biele pole s dátumom)
- **Komponenty**: `_ResourceDisplay` (coins/emeralds), `_CalendarWidget` (dátum)

#### `room_viewer.dart`
- **Účel**: 3D izometrická vizualizácia miestnosti
- **Funkcia**: 
  - Kreslí miestnosť pomocou `CustomPaint` a `Canvas`
  - Renderuje 2 steny (ľavú perspektívnu, zadnú plochú)
  - Renderuje podlahu (4x4 grid modrých dlaždíc v izometrickej projekcii)
  - Kreslí dvere (ľavá strana, hnedé, s kľučkou)
  - Kreslí okno (pravá strana, 4-panelové s krížom)
  - Zobrazuje robot ikonu v pravom dolnom rohu
- **Metódy**: 
  - `_drawWalls()` - kreslenie stien
  - `_drawFloor()` - podlaha s bilineárnou interpoláciou
  - `_drawFurniture()` - dvere a okná
  - `_interpolateQuad()` - helper pre perspektívu

#### `bottom_navigation.dart`
- **Účel**: Dolná navigačná lišta s 5 tlačidlami
- **Funkcia**: 
  - 5 navigačných tlačidiel s vlastnými ikonami a farbami
  - Index 0: Home (hnedá)
  - Index 1: Tasks (červená)
  - Index 2: Shop (zelená)
  - Index 3: Stats (oranžová)
  - Index 4: Inventory (modrá)
  - Zvýrazňuje vybraté tlačidlo
- **Komponenty**: `_NavButton` - jedno tlačidlo s ikonou
- **Testing**: Obsahuje `Key` pre každé tlačidlo pre widget testy

### `lib/models/`

#### `game_state.dart`
- **Účel**: Hlavný herný stav - zdroje a miestnosti
- **Dáta**: 
  - `coins` (int) - herná mena
  - `emeralds` (int) - prémiová mena
  - `date` (double) - herný dátum
  - `rooms` (List<Room>) - zoznam miestností
- **Metódy**: 
  - `addCoins(int amount)` - pridanie coinov
  - `spendEmeralds(int amount)` - míňanie emeraldov s validáciou

#### `room.dart`
- **Účel**: Definícia štruktúry miestnosti a nábytku
- **Triedy**: 
  - `Room` - miestnosť (id, type, walls, floor, furniture)
  - `Furniture` - nábytok (id, type, position)
  - `Wall` - stena (style, direction)
  - `Floor` - podlaha (type)
  - `Position` - pozícia (x, y)
- **Enumy**: 
  - `RoomType` - living, bedroom, kitchen, bathroom
  - `FurnitureType` - door, window, chair, table, bed, lamp
  - `WallStyle` - basic, brick, wood, painted
  - `FloorType` - tile, wood, carpet
  - `Direction` - north, south, east, west

### `lib/my_flutter_app_icons.dart`
- **Účel**: Definície vlastných ikon z fontu
- **Ikony**: 
  - `home` (0xe800) - domček
  - `target` (0xe801) - terč
  - `basket` (0xe802) - košík
  - `chart_bar` (0xf080) - graf
  - `user` (0xe803) - užívateľ
  - `settings` (0xf013) - nastavenia
  - `money` (0xf0d6) - emeraldy
  - `coins` (0xf51e) - mince
  - `robot` (0xf544) - robot
- **Font**: `MyFlutterApp` (ttf súbor v `assets/fonts/`)

### `assets/`

#### `assets/fonts/MyFlutterApp.ttf`
- **Účel**: Vlastný icon font obsahujúci všetky herné ikony
- **Použitie**: Alternatíva k Material Icons, umožňuje vlastné ikony

#### `assets/images/`
- **Účel**: Obrázky (napr. `room.png` - referenčný obrázok pre 3D miestnosť)

### `test/widget_test.dart`
- **Účel**: Automatizované widget testy
- **Testy**: 
  1. `'Money Mansion app loads correctly'` - overuje načítanie app, zobrazenie zdrojov (111, 780, 7.7, JUL)
  2. `'Navigation between screens works'` - testuje prepínanie medzi Shop, Stats, Inventory
- **Spustenie**: `flutter test`

### Konfiguračné súbory

#### `pubspec.yaml`
- Konfigurácia projektu, závislosti, assety
- Registrácia fontu `MyFlutterApp.ttf`
- Nastavenie `assets/images/` a `assets/fonts/`

---

## 🎮 Odporúčania pre ďalšiu implementáciu

### 1. **Získavanie hernej meny za tasky**

**Kde implementovať:**

- **Model pre Task** (`lib/models/task.dart`):
  ```dart
  class Task {
    final String id;
    final String title;
    final String description;
    final int coinsReward;
    final int emeraldsReward;
    bool isCompleted;
    
    Task({...});
  }
  ```

- **Rozšíriť GameState** (`lib/models/game_state.dart`):
  ```dart
  class GameState {
    ...
    List<Task> tasks = [];
    
    void completeTask(String taskId) {
      final task = tasks.firstWhere((t) => t.id == taskId);
      if (!task.isCompleted) {
        addCoins(task.coinsReward);
        addEmeralds(task.emeraldsReward);
        task.isCompleted = true;
      }
    }
  }
  ```

- **TasksScreen implementácia** (`lib/screens/tasks_screen.dart`):
  - ListView s jednotlivými úlohami
  - Tlačidlo "Complete" pre každú úlohu
  - Callback na `gameState.completeTask(taskId)`
  - Animácia pridania coinov/emeraldov

### 2. **Nákup nábytku v shope**

**Kde implementovať:**

- **Model pre ShopItem** (`lib/models/shop_item.dart`):
  ```dart
  class ShopItem {
    final String id;
    final String name;
    final FurnitureType type;
    final int price;
    final String currency; // 'coins' alebo 'emeralds'
  }
  ```

- **ShopScreen** (`lib/screens/shop_screen.dart`):
  - GridView s produktami
  - Tlačidlo "Buy" overuje `gameState.coins >= item.price`
  - Po kúpe: `gameState.spendCoins()` + pridanie do inventára

### 3. **Umiestňovanie nábytku do miestnosti**

**Kde implementovať:**

- **RoomViewer interaktivita** (`lib/widgets/room_viewer.dart`):
  - `GestureDetector` pre tap na pozíciu v miestnosti
  - Konverzia tap pozície na grid koordináty
  - Pridanie `Furniture` objektu do `room.furniture`

- **Inventory na Room prepojenie**:
  - V `InventoryScreen`: drag-and-drop alebo tap na predmet
  - Modálny dialog: "Do ktorej miestnosti umiestniť?"
  - Callback: `gameState.rooms[index].furniture.add(...)`

### 4. **Perzistencia dát (ukladanie progresie)**

**Kde implementovať:**

- **Balík**: `shared_preferences` alebo `hive`
- **GameState metódy**:
  ```dart
  Future<void> saveGame() async {
    // Serializácia GameState do JSON
    // Uloženie do SharedPreferences
  }
  
  Future<void> loadGame() async {
    // Načítanie z SharedPreferences
    // Deserializácia do GameState
  }
  ```

- **Volanie**: 
  - `saveGame()` pri každej zmene stavu (coins, emeralds, rooms)
  - `loadGame()` v `initState()` v `GameScreen`

### 5. **Progresívny systém miestností**

**Kde implementovať:**

- **GameState rozšírenie**:
  ```dart
  List<Room> unlockedRooms = [];
  
  void unlockRoom(RoomType type, int cost) {
    if (coins >= cost) {
      spendCoins(cost);
      rooms.add(Room(type: type, ...));
    }
  }
  ```

- **UI pre prepínanie miestností**:
  - Šípky vľavo/vpravo na `RoomViewer`
  - Alebo carousel/swipe pre prechádzanie miestností
  - Tlačidlo "Unlock new room" v ShopScreen

### 6. **Animácie a efekty**

**Kde implementovať:**

- **Coins/emeralds prírastok** (`lib/widgets/top_bar.dart`):
  - `AnimatedSwitcher` pre plynulú zmenu čísel
  - Zelený "+X" animovaný text pri získaní zdrojov

- **Room transitions** (`lib/widgets/room_viewer.dart`):
  - `AnimatedContainer` pre zmenu farieb stien
  - `Hero` animácie pre nábytok

---

## 🚀 Ako spustiť

```bash
# Web
flutter run -d chrome

# Android/iOS (ak máš emulátor)
flutter run

# Testy
flutter test
```

## 📝 Poznámky

- Projekt je **kostra** - placeholder obrazovky je potrebné vyplniť funkčnosťou
- `RoomViewer` používa programatické kreslenie (nie obrázky) pre flexibilitu
- Všetky ikony sú v jednom fonte `MyFlutterApp.ttf`
- Navigation funguje, ale obrazovky Tasks/Shop/Stats/Inventory sú prázdne
- Hot reload funguje pre väčšinu zmien, hot restart potrebný pri zmene `pubspec.yaml`
