# 🎮 Money Mansion - Task Persistence System

## ✨ Co Bolo Implementované

Vytvoril som kompletný systém na ukladanie taskov do databázy s integrácou medzi Flutter aplikáciou a Python backendom.

### Backend (Python + Flask)
- ✅ **REST API** s endpoints pre task management
- ✅ **SQLite Database** pre perzistenciu taskov
- ✅ CORS enabled pre komunikáciu s Flutter apkou
- ✅ TaskDAO a TaskService pre databázové operácie

### Frontend (Flutter)
- ✅ **HTTP Service** (`TaskApiService`) pre backend komunikáciu
- ✅ **Task Model** s UUID a kompletnými polami
- ✅ **Integrovaný TasksScreen** s nasledujúcim:
  - Automatické načítavanie taskov z DB pri štarte
  - Vytváraní taskov s uložením do DB
  - Označovanie taskov ako hotových (+ coinmi)
  - Zmazávanie taskov
  - Refresh tlačidlo

---

## 🚀 Ako Spustiť

### Krok 1: Príprava Backend

```bash
# Prejdi do backend priečinka
cd backend

# Inštaluj všetky dependencies
pip install -r requirements.txt
```

### Krok 2: Inicializácia Databázy

```bash
# Vytvor SQLite databázu s tabulkami
python database/db_init.py
```

Výstup:
```
Database initialized successfully!
```

### Krok 3: Spustenie Backend Servera

```bash
# Spusti Flask server
python app.py
```

Výstup:
```
==================================================
Starting Money Mansion Backend Server
==================================================
Server running on: http://127.0.0.1:5000
Database location: c:\...\backend\money_mansion.db

API Endpoints:
  Tasks: http://127.0.0.1:5000/api/tasks
  Game State: http://127.0.0.1:5000/api/game/state
==================================================
```

### Krok 4: Spustenie Flutter Aplikácie

V inom terminále:

```bash
# Vráť sa do root priečinka
cd ..

# Spusti Flutter aplikáciu
flutter run
```

---

## 📋 API Endpoints

### Tasks

```http
GET    /api/tasks                    # Všetky tasky
POST   /api/tasks                    # Vytvoriť nový task
GET    /api/tasks/<id>               # Konkrétny task
PUT    /api/tasks/<id>               # Aktualizovať task
DELETE /api/tasks/<id>               # Zmazať task
PUT    /api/tasks/<id>/complete      # Označiť ako hotový
```

### Game State

```http
GET    /api/game/state               # Aktuálny stav hry
POST   /api/game/coins/add           # Pridať coiny
```

---

## 🔄 Ako Funguje Workflow

### 📱 Scenár: Užívateľ Vytvorí Nový Task

1. Užívateľ klikne na `+` tlačidlo v TasksScreen
2. Vyplní formulár (názov, opis, odmenu, termín)
3. Klikne na "Create Task"
4. Flutter HTTP **POST** na `/api/tasks` s dátami
5. Backend uloží do `tasks` tabuľky v SQLite
6. Task sa pridá do listu v aplikácii
7. SnackBar potvrdí: "Task created successfully"

```json
POST /api/tasks
{
  "title": "Ukliď izbu",
  "description": "Všetky hry zložiť do skrine",
  "rewardCoins": 50,
  "dueDate": 1702166400.0
}

Response: 201 Created
{ "success": true, "message": "Task created" }
```

### 🎮 Scenár: Aplikácia sa Spustí (Prvý Raz)

1. `TasksScreen` sa inicializuje
2. Zavolá `_loadTasksFromBackend()`
3. HTTP **GET** na `/api/tasks`
4. Backend vracia všetky tasky z databázy
5. Tasks sa naplnia do `GameState.tasks`
6. UI zobrazí všetky tasky
7. Loading indikátor zmizne

```http
GET /api/tasks

Response: 200 OK
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Ukliď izbu",
    "description": "Všetky hry zložiť do skrine",
    "status": "pending",
    "rewardCoins": 50,
    "dueDate": 1702166400.0,
    "isCompleted": false
  }
]
```

### ✅ Scenár: Užívateľ Označí Task ako Hotový

1. Užívateľ klikne na **checkbox** pri tasku
2. HTTP **PUT** na `/api/tasks/{id}/complete`
3. Backend:
   - Označí task ako `completed`
   - Pridá coinmi do game_state
   - Vracia počet pridelených coinom
4. Frontend:
   - Označí task ako completed
   - Zobrazí zelený háčik
   - SnackBar: "Task completed! +50 coins"

```http
PUT /api/tasks/123/complete

Response: 200 OK
{
  "success": true,
  "message": "Task completed",
  "coinsAwarded": 50
}
```

### 🗑️ Scenár: Užívateľ Zmaže Task

1. Užívateľ klikne na **delete ikonu**
2. HTTP **DELETE** na `/api/tasks/{id}`
3. Backend zmaže task z databázy
4. Frontend:
   - Odstráni task zo zoznamu
   - SnackBar: "Task deleted"

```http
DELETE /api/tasks/123

Response: 200 OK
{ "success": true, "message": "Task deleted" }
```

### 🔄 Scenár: Užívateľ Zavrie a Znova Otvorí Aplikáciu

1. Užívateľ zavrie aplikáciu (tasky existujú v DB)
2. Neskôr znova spustí aplikáciu
3. `TasksScreen` sa inicializuje
4. Zavolá `_loadTasksFromBackend()`
5. Backend vracia všetky uložené tasky
6. **Všetky tasky sú stále viditeľné!** ✅

---

## 📊 Databázová Schéma

### tasks Tabuľka

```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_name TEXT NOT NULL,              -- Názov tasku
    description TEXT,                      -- Opis tasku
    status TEXT DEFAULT 'pending',         -- 'pending' alebo 'completed'
    reward_coins INTEGER DEFAULT 0,        -- Coiny na odmenu
    reward_money INTEGER DEFAULT 0,        -- Money (zatiaľ nepoužívané)
    due_date REAL,                         -- Unix timestamp (sekundy)
    completed_date TIMESTAMP,              -- Kedy bol označený ako hotový
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### game_state Tabuľka

```sql
CREATE TABLE game_state (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    coins INTEGER DEFAULT 0,               -- Počet coinom
    money INTEGER DEFAULT 0,               -- Real-world peňadze
    current_date REAL DEFAULT 1.0,         -- Herný dátum
    level INTEGER DEFAULT 1,
    experience INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🧪 Testovanie API

Ak chceš testovať API bez Flutter:

```bash
cd backend
python test_api.py
```

Alebo použiť curl/Postman:

```bash
# Všetky tasky
curl http://127.0.0.1:5000/api/tasks

# Vytvoriť task
curl -X POST http://127.0.0.1:5000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Test task","rewardCoins":25,"dueDate":1702166400.0}'

# Označiť task ako hotový
curl -X PUT http://127.0.0.1:5000/api/tasks/1/complete

# Zmazať task
curl -X DELETE http://127.0.0.1:5000/api/tasks/1
```

---

## 📝 Súbory Ktoré Boli Vytvorené/Zmenené

### Nové Backend Súbory
- `backend/api/routes.py` - REST API endpoints
- `backend/test_api.py` - API test script
- `backend/.env.example` - Configuration template

### Zmenené Backend Súbory
- `backend/app.py` - Teraz Flask aplikácia (nie len CLI)
- `backend/requirements.txt` - Pridané Flask, CORS, requests

### Nové Flutter Súbory
- `lib/models/task.dart` - Task model s copyWith
- `lib/services/task_api_service.dart` - HTTP service

### Zmenené Flutter Súbory
- `lib/screens/tasks_screen.dart` - Integrovaná s backendom
- `lib/models/game_state.dart` - Pridané task management metódy
- `pubspec.yaml` - Pridané uuid a http packages

---

## ⚠️ Poznámky a Troubleshooting

### Backend Neprijíma Spojenie
**Riešenie:**
1. Skontroluj či server beží: `python app.py` v `backend` priečinku
2. Skontroluj port: `http://127.0.0.1:5000`
3. Skontroluj firewall

### Tasky sa Neukladajú
**Riešenie:**
1. Skontroluj či `backend/money_mansion.db` existuje
2. Spusti `python database/db_init.py` znova
3. Skontroluj Flask console pre chyby

### CORS Chyby v Fluttri
**Riešenie:**
- CORS je zakázaný pre `http://127.0.0.1:5000`
- To je OK! Flutter emulator/fyzické zariadenie musia pristupovať z iného IP
- Ak spúštaš na fyzickom zariadení, použi IP adresu servera, nie localhost

### Zmenenie Backend URL
Ak spúštaš backend na inej adrese:

```dart
// lib/services/task_api_service.dart - Riadok 8
static const String baseUrl = 'http://YOUR_IP:YOUR_PORT/api';
```

Príklad pre fyzické zariadenie na rovnakej WiFi:
```dart
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

---

## 🎉 Hotovo!

Teraz máš:
- ✅ Plne funkčný task management systém
- ✅ Databázu na ukladanie taskov
- ✅ Backend API na komunikáciu
- ✅ Perzistenciu - tasky sa ukladajú aj po zavretí aplikácie

Môžeš začať s vytvárením taskov a viac sa nebudú strácať! 🚀
