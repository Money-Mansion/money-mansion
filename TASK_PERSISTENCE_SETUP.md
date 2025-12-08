# Money Mansion - Backend & Flutter Integration Setup

## ✅ Co je nainštalované

### Backend (Python + Flask)
- ✅ Flask 2.3.0 - REST API framework
- ✅ Flask-CORS 4.0.0 - Cross-Origin Resource Sharing
- ✅ SQLite3 - Database (included with Python)
- ✅ TaskDAO & TaskService - Task management

### Frontend (Flutter)
- ✅ uuid package - Unique ID generation
- ✅ http package - HTTP requests to backend

## 🚀 Ako spustiť backend

### 1. Inštalácia Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Inicializácia Databázy
```bash
python db_init.py
```

Alebo priamo z app.py:
```bash
python app.py
```

### 3. Spustenie Backend Servera
```bash
python app.py
```

Server bude bežať na: `http://127.0.0.1:5000`

## 📱 Co je nainštalované vo Flutter

### Nové Modely
- `lib/models/task.dart` - Task model s copyWith metódou

### Nové Služby
- `lib/services/task_api_service.dart` - HTTP client pre backend komunikáciu

### Aktualizované Obrazovky
- `lib/screens/tasks_screen.dart` - Plne integrovaná s backendom
  - Náčítavanie taskov z databázy pri štarte
  - Vytvorenie taskov s uložením do DB
  - Označenie taskov ako hotových s coinmi v DB
  - Zmazávanie taskov z DB
  - Refresh tlačidlo na synchronizáciu

## 🔌 API Endpoints

### Tasky
```
GET    /api/tasks              - Všetky tasky
POST   /api/tasks              - Vytvoriť nový task
GET    /api/tasks/<id>         - Konkrétny task
PUT    /api/tasks/<id>         - Aktualizovať task
DELETE /api/tasks/<id>         - Zmazať task
PUT    /api/tasks/<id>/complete - Označiť ako hotový
```

### Game State
```
GET    /api/game/state         - Aktuálny stav hry
POST   /api/game/coins/add     - Pridať coiny
```

## 📋 Task Structure v Databáze

```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY,
    task_name TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending',
    reward_coins INTEGER DEFAULT 0,
    due_date REAL,
    completed_date TIMESTAMP,
    created_at TIMESTAMP
)
```

Status môže byť: `pending`, `completed`, `failed`

## 🔄 Workflow - Ako Funguje Perzistenencia

### Pri Vytváraní Tasku
1. Užívateľ vyplní formulár
2. Flutter vytvorí Task objekt s UUID
3. HTTP POST na `/api/tasks` s task dátami
4. Backend uloží do SQLite databázy
5. Task sa pridá do GameState listu
6. SnackBar potvrdí úspech

### Pri Otváraní Aplikácie
1. TasksScreen sa initializes
2. HTTP GET na `/api/tasks` na načítanie všetkých taskov
3. Backend vracia všetky tasky z databázy
4. Tasks sa naplnia do GameState.tasks listu
5. UI sa aktualizuje s taskami

### Pri Označení ako Hotový
1. Užívateľ klikne na checkbox
2. HTTP PUT na `/api/tasks/{id}/complete`
3. Backend označí task ako completed
4. Backend pripočítá coiny do game state
5. Frontend označí task ako completed
6. SnackBar potvrdí s počtom coinom

### Pri Zmazaní
1. Užívateľ klikne na delete ikonku
2. HTTP DELETE na `/api/tasks/{id}`
3. Backend zmaže task z databázy
4. Frontend odstráni task zo zoznamu
5. SnackBar potvrdí zmazanie

## ⚙️ Konfigurácia Backend URL

Ak spúštaš backend na inej adrese, aktualizuj `TaskApiService`:

```dart
// lib/services/task_api_service.dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

## 🐛 Troubleshooting

### Backend neprijíma spojenie
- Skontroluj či bežží na `http://127.0.0.1:5000`
- Skontroluj či je Flask importovaný bez chýb
- Skontroluj czy Flutter URL je správna

### Tasky sa neukladajú
- Skontroluj či databáza existuje: `backend/money_mansion.db`
- Skontroluj Flask logs pre chyby
- Overi ci sú všetky fields v JSON payloade správne

### CORS Chyby
- Flask-CORS je nainštalovaný
- CORS je aktivovaný v app.py: `CORS(self.app)`

## 📝 Poznámky

- Tasky majú status: `pending` alebo `completed`
- Dátum je uložený ako Unix timestamp (sekund)
- ID sa generuje ako UUID v Fluttri a proslúži ako referencie
- Coiny sa automatic pridávajú keď sa task označí ako hotový

## 🎯 Ďalší Krok

Hru môžeš teraz spustiť a tasky sa budú ukladať do databázy! 🎉
