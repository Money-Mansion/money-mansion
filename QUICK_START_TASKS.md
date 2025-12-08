# 🚀 Quick Start - Task Persistence

## 📋 V Jednej Minúte

### Krok 1: Backend (Terminal 1)
```bash
cd backend
pip install -r requirements.txt
python database/db_init.py
python app.py
```

Expected output:
```
==================================================
Starting Money Mansion Backend Server
==================================================
Server running on: http://127.0.0.1:5000
```

### Krok 2: Flutter App (Terminal 2)
```bash
flutter pub get
flutter run
```

### Krok 3: Testovanie v Aplikácii
1. Otvoriť **Tasks** sekciu
2. Kliknúť `+` tlačidlo
3. Vyplniť formulár
4. Kliknúť "Create Task"
5. Task sa uloží do databázy! ✅
6. Zavri aplikáciu a spusti ju znova
7. **Task je stále tam!** 🎉

---

## 📝 Príkazy Ktoré Potrebuješ

### Backend Terminal
```bash
# Vstúp do backend priečinka
cd backend

# Inštalácia (iba prvý raz)
pip install -r requirements.txt

# Inicializácia DB (iba prvý raz)
python database/db_init.py

# Spustenie servera (zakaždým keď chceš testovať)
python app.py

# Test API (optional)
python test_api.py
```

### Flutter Terminal
```bash
# Inštalácia (iba prvý raz)
flutter pub get

# Spustenie aplikácie
flutter run

# Ak nefunguje, vyčisti a spusti znova
flutter clean
flutter pub get
flutter run
```

---

## ✅ Kontrolný Zoznam

- [ ] Backend: Flask server beží na http://127.0.0.1:5000
- [ ] Backend: Databáza existuje: `backend/money_mansion.db`
- [ ] Flutter: Aplikácia sa spustila
- [ ] Flutter: TasksScreen sa zobrazuje
- [ ] Flutter: +1 Tlačidlo funguje
- [ ] Flutter: Formulár sa otvorí
- [ ] Flutter: Task sa vytvoril (SnackBar: "Task created successfully")
- [ ] Flutter: Zavri a znova spusti aplikáciu
- [ ] Flutter: Task je stále viditeľný ✅

---

## 🔗 URL Adresy

- Backend API: `http://127.0.0.1:5000/api/tasks`
- Game State: `http://127.0.0.1:5000/api/game/state`

---

## 🐛 Ak Niečo Nefunguje

### Backend sa nespustí
```bash
# Skontroluj ci Port 5000 nie je obsadený
# Alebo spusti na inom porte:
# Zmeni v: backend/app.py - riadok 96: backend.run(port=5001)
```

### Flutter sa nemôže pripojiť
```bash
# Skontroluj czy backend beží
# Skontroluj czy URL je správna: http://127.0.0.1:5000
# V lib/services/task_api_service.dart - riadok 8
```

### Databáza chyb
```bash
python database/db_init.py
# Toto naplnené DB znova
```

---

## 📚 Detailné Návody

Pre viac informácií pozri:
- `BACKEND_SETUP_GUIDE.md` - Detailný setup
- `BACKEND_IMPLEMENTATION_SUMMARY.md` - Technické detaily
- `TASK_PERSISTENCE_SETUP.md` - Workflow dokumentácia

---

## 🎉 Hotovo!

Teraz máš funkčný task persistence system! Tasks sa ukladajú a sú viditeľné aj po zavretí aplikácie. 🚀
