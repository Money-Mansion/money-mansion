# 📋 Implementácia Task Persistence System - Kompletný Prehľad

## 🎯 Čo Bolo Požiadané
Užívateľ potreboval aby sa tasky ukladali do databázy a aby boli viditeľné aj po zavretí a znova spustení aplikácie.

## ✅ Čo Bolo Vyriešené

### 1️⃣ Backend Infraštruktúra (Python + Flask + SQLite)

#### Inštalácie Packages
```bash
Flask 2.3.0 - Web framework
Flask-CORS 4.0.0 - Cross-Origin Resource Sharing
requests 2.31.0 - HTTP client na testovanie
```

#### Vytvorené API Endpoints
V súbore `backend/api/routes.py`:

| Metóda | Endpoint | Funkcia |
|--------|----------|---------|
| GET | `/api/tasks` | Všetky tasky |
| POST | `/api/tasks` | Nový task |
| GET | `/api/tasks/<id>` | Konkrétny task |
| PUT | `/api/tasks/<id>` | Aktualizovať task |
| DELETE | `/api/tasks/<id>` | Zmazať task |
| PUT | `/api/tasks/<id>/complete` | Označiť ako hotový |
| GET | `/api/game/state` | Stav hry |

#### Databázová Schéma
- `tasks` tabuľka s polami: id, task_name, description, status, reward_coins, due_date, completed_date, created_at
- `game_state` tabuľka s polami: coins, money, current_date, level, experience

### 2️⃣ Backend Server

#### Upravený `backend/app.py`
- Premenený z CLI na Flask web server
- CORS aktivovaný
- Automatická registrácia všetkých API routes
- Debug mode aktivovaný
- Pekný startup info s informáciami o serveri

#### Inicializácia Databázy
```bash
python database/db_init.py
# Vytvorí: backend/money_mansion.db s všetkými potrebnými tabuľkami
```

### 3️⃣ Flutter Aplikácia

#### Nový HTTP Service
Súbor: `lib/services/task_api_service.dart`

Poskytuje metódy:
- `getAllTasks()` - Načítať všetky tasky z backendu
- `createTask(Task)` - Vytvoriť nový task
- `completeTask(String id)` - Označiť task ako hotový
- `deleteTask(String id)` - Zmazať task
- `updateTask(Task)` - Aktualizovať task

Všetky metódy majú built-in error handling a timeout (10 sekúnd).

#### Vylepšený Task Model
Súbor: `lib/models/task.dart`
- Pridaná metóda `copyWith()` pre immutable updates
- Všetky potrebné polia: id, title, description, rewardCoins, dueDate, isCompleted

#### Modernizovaný TasksScreen
Súbor: `lib/screens/tasks_screen.dart`

Nové Features:
- **Loading State** - Spinner pri načítavaní taskov
- **Auto Load** - Tasky sa načítajú pri otváraní aplikácie
- **Sync Indicator** - Ukazuje či sa dáta syncujú
- **Refresh Button** - Manuálne obnovenie taskov
- **Network Error Handling** - User-friendly error messages
- **Activity Indicators** - Tasky sa ukazujú ako stáva sa s nimi operácia

### 4️⃣ Nové Package Dependencies

#### Flutter (`pubspec.yaml`)
```yaml
uuid: ^4.0.0      # Generovanie unique task IDs
http: ^1.1.0      # HTTP komunikácia s backendom
```

#### Backend (`requirements.txt`)
```
flask==2.3.0
flask-cors==4.0.0
python-dotenv==1.0.0
requests==2.31.0
```

---

## 🔄 Ako Funguje Celý Workflow

### 1. Inicializácia
```
1. Backend inicializuje databázu (tasks tabuľka vytvorená)
2. Flask server beží na http://127.0.0.1:5000
3. Flutter aplikácia sa spustí
4. TasksScreen sa inicializuje a zavolá API
```

### 2. Načítavanie Taskov
```
1. TasksScreen.initState() → _loadTasksFromBackend()
2. HTTP GET /api/tasks
3. Backend vracia JSON list taskov z databázy
4. TaskApiService parsuje JSON do Task objektov
5. GameState.tasks sa naplní s taskami
6. UI sa automaticky aktualizuje
```

### 3. Vytvorenie Tasku
```
1. User klikne "+" tlačidlo
2. Dialog sa otvorí na vyplnenie formulára
3. User vyplní: názov, opis, odmenu, termín
4. Klikne "Create Task"
5. TaskApiService.createTask() pošle HTTP POST s dátami
6. Backend vloží do databázy
7. Frontend aktualizuje UI
8. SnackBar potvrdí úspech
```

### 4. Označenie ako Hotový
```
1. User klikne checkbox na tasku
2. TaskApiService.completeTask() pošle PUT /api/tasks/{id}/complete
3. Backend:
   - Vyberie task z databázy
   - Označí status = 'completed'
   - Pridá coinmi do game_state
   - Vracia počet coinom
4. Frontend:
   - Označí task ako completed
   - Zobrazí checkmark ikonku
   - SnackBar: "+50 coins"
```

### 5. Zmazanie Tasku
```
1. User klikne delete ikonu
2. TaskApiService.deleteTask() pošle DELETE /api/tasks/{id}
3. Backend zmaže z databázy
4. Frontend odstráni zo zoznamu
5. SnackBar potvrdí
```

### 6. Perzistenencia - Znova Otvorená Aplikácia
```
1. User zavrie aplikáciu (tasky sú v DB!)
2. Neskôr otvorí aplikáciu
3. TasksScreen.initState() zavolá _loadTasksFromBackend()
4. HTTP GET /api/tasks
5. Backend vracia všetky tasky z databázy
6. ✅ VŠETKY TASKY SÚ VIDIEĽNÉ!
```

---

## 📂 Zmeny v File Štruktúre

### Nové Súbory
```
backend/
  ├── api/
  │   └── routes.py [NEW] - REST API endpoints
  ├── test_api.py [NEW] - API test script
  └── .env.example [NEW] - Configuration template

lib/
  ├── models/
  │   └── task.dart [MODIFIED] - Pridané copyWith()
  ├── services/ [NEW]
  │   └── task_api_service.dart [NEW] - HTTP komunikácia
  └── screens/
      └── tasks_screen.dart [COMPLETELY REWRITTEN]

// Root
├── BACKEND_SETUP_GUIDE.md [NEW]
├── TASK_PERSISTENCE_SETUP.md [NEW]
└── BACKEND_IMPLEMENTATION_SUMMARY.md [NEW - TÁTO SÚBOR]
```

### Modifikované Súbory
```
backend/
  ├── app.py [MAJOR UPDATE] - Teraz Flask server
  ├── requirements.txt [UPDATED] - Pridané Flask, CORS, requests
  └── database/
      └── dao.py [OK - TaskDAO už existoval]

lib/
  ├── main.dart [NO CHANGES - Funguje s aktuálnym TasksScreen]
  ├── models/
  │   └── game_state.dart [UPDATED] - Pridané task management metódy
  └── pubspec.yaml [UPDATED] - uuid, http packages
```

---

## 🚀 Spustenie

### Backend
```bash
cd backend
pip install -r requirements.txt
python database/db_init.py
python app.py
# Server beží na http://127.0.0.1:5000
```

### Flutter
```bash
flutter pub get
flutter run
# TasksScreen automaticky načíta tasky z backendu
```

---

## 🔧 Konfigurácia

### Ak Backend Beží na Inej Adrese
```dart
// lib/services/task_api_service.dart - Riadok 8
static const String baseUrl = 'http://YOUR_IP:YOUR_PORT/api';
```

### Databázová Cesta
```
backend/money_mansion.db
```

---

## ✨ Klúčové Features

1. **Automatické Načítavanie** - Tasky sa načítajú pri štarte aplikácie
2. **Offline Mode** - Ak backend nie je dostupný, app nepadne (error handling)
3. **Error Messages** - User vidí čo sa stalo ak niečo zlyhá
4. **Loading Indicators** - User vidí že sa niečo deje
5. **Immutable Updates** - Task model je bezpečný (copyWith)
6. **UUID IDs** - Unikátne ID pre každý task
7. **Timestamps** - Dátumy sú uložené ako Unix timestamps
8. **Coiny Reward** - Automatické pripočítavanie coinom pri hotovom tasku
9. **Status Tracking** - Tasky majú status 'pending' alebo 'completed'
10. **CORS Enabled** - Backend prijíma requesty z Fluttru

---

## 📊 Technológie

### Backend
- Python 3.8+
- Flask 2.3.0 - Web Framework
- SQLite 3 - Database
- Flask-CORS - CORS support

### Frontend
- Flutter 3.x
- Dart
- http package - HTTP client
- uuid package - ID generation

---

## 🎓 Čo Bolo Naučené

1. REST API dizajn (GET, POST, PUT, DELETE)
2. CORS konfigurácia v Flasku
3. JSON serialization/deserialization v Dartu
4. Error handling v async operáciách
5. Loading states v UI
6. Database schema dizajn
7. Backend-Frontend integrácia

---

## 🐛 Známe Problémy a Riešenia

### Backend neprijíma spojenie
- ✅ Skontroluj ci server beží
- ✅ Skontroluj port (5000)
- ✅ Skontroluj firewall

### Tasky sa neukladajú
- ✅ Skontroluj czy databáza existuje
- ✅ Spusti `python database/db_init.py` znova

### CORS chyby
- ✅ Flask-CORS je nainstalovaný
- ✅ CORS je inicializovaný v app.py

---

## 📝 Testovanie

```bash
# Test backend API bez Fluttru
cd backend
python test_api.py
```

Alebo manuálne:
```bash
curl http://127.0.0.1:5000/api/tasks
```

---

## 🎉 Výsledok

- ✅ Tasky sa ukladajú do databázy
- ✅ Tasky sú viditeľné po novom spustení aplikácie
- ✅ Všetky CRUD operácie fungujú
- ✅ Coiny sa automaticky pridávajú
- ✅ Error handling je na mieste
- ✅ User experience je plynulá

**Projekt je hotový a připravený na použitie!** 🚀
