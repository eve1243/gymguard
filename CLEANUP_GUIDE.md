# GymGuard - Saubere Projekt-Struktur

## ⚠️ BACKUP EMPFEHLUNG
Bevor Sie das Cleanup-Skript ausführen, erstellen Sie ein Backup:
```powershell
# Backup erstellen
cp -r C:\Users\Everl\StudioProjects\gymguard C:\Users\Everl\StudioProjects\gymguard_backup
```

## 🗂️ **Was entfernt werden kann:**

### ❌ **Komplett überflüssig:**
- **`gym_guard_app/`** - 100% Duplikat mit veralteter Version
- **`python_scripts/`** - Nur Beispielcode, nicht verwendet  
- **`build/`** - Build-Cache (wird automatisch neu erstellt)
- **`ios/main.dart`** - Fehlplatzierte Datei (gehört in lib/)

### 🚫 **Unbenutzte Platformen (nur iOS + Android benötigt):**
- **`windows/`** - Windows Platform (nicht benötigt)
- **`linux/`** - Linux Platform (nicht benötigt)
- **`macos/`** - macOS Platform (nicht benötigt)
- **`web/`** - Web Platform (nicht benötigt)

### 📄 **Zu viele Dokumentationen:**
- `INSTALLATION.md`
- `PYTHON_INSTALLATION.md` 
- `POSE_ESTIMATION_READY.md`
- `SETUP_SUMMARY.md`
- `NEXT_STEPS.md`
- `QUICKSTART.md`
**→ Alle ersetzen durch eine saubere README.md**

### 🔧 **Setup-Dateien nicht mehr benötigt:**
- `new.sh`
- `prepare_models.py`

### 📦 **Batch-Dateien konsolidieren:**
- `run_flutter_fixed.bat`
- `run_java17_forced.bat` 
- `run_updated_versions.bat`
**→ Nur `run_motion_optimized.bat` behalten**

## ✅ **Was bleibt (Kern des Projekts - nur iOS + Android):**

```
gymguard/
├── lib/
│   ├── main.dart                 # ⭐ Haupt-App (1409 Zeilen)
│   ├── models/
│   │   └── user_profile.dart     # User-Datenmodell
│   └── services/
│       └── secure_user_storage.dart # Datenspeicherung
├── android/                      # Android Platform ✓
├── ios/                          # iOS Platform ✓
├── test/                         # Unit Tests
├── pubspec.yaml                  # Dependencies
├── README.md                     # Haupt-Dokumentation
├── analysis_options.yaml         # Dart Linting
└── run_motion_optimized.bat      # Launch Script
```

## 🚀 **Speicherplatz-Einsparung:**
- **Vorher:** ~15+ Ordner mit Duplikaten + 4 unbenutzte Platformen
- **Nachher:** 6 essenzielle Ordner (nur iOS + Android)
- **Geschätzte Reduzierung:** 75-80% weniger Dateien

## 🛡️ **Sichere Ausführung:**

1. **Backup erstellen** (wichtig!)
2. **Cleanup-Skript ausführen:**
   ```powershell
   .\cleanup_project.bat
   ```
3. **Testen ob alles funktioniert:**
   ```powershell
   .\run_motion_optimized.bat
   ```

Das Skript fragt vor jeder Aktion nach Bestätigung und zeigt genau was entfernt wird!
