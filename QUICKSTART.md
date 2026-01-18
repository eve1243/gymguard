# 🚀 GymGuard - Schnellstart-Anleitung

## ✅ Was ist bereits fertig:

- ✅ Flutter & Android SDK komplett eingerichtet
- ✅ **Python 3.12.10** mit TensorFlow, **MediaPipe** & OpenCV
- ✅ Flutter App mit Live-Kamera erstellt
- ✅ Projekt-Struktur für Pose-Detection vorbereitet

## 🎉 NEU: MediaPipe ist jetzt verfügbar!

**MediaPipe Version 0.10.21** ist installiert und einsatzbereit!

## 📱 App jetzt testen:

```bash
cd gym_guard_app
flutter run
```

**Was Sie sehen werden:**
- Live-Kamera-Preview
- Status-Anzeige
- Hinweis dass Pose-Estimation noch hinzugefügt wird

## 🎯 Pose-Erkennung testen (2 einfache Schritte):

### Schritt 1: Python Environment aktivieren
```bash
cd C:\Users\Everl\Desktop\FHCampuswien\2025I2026\Software\gymguard
.\venv\Scripts\Activate.ps1
```

### Schritt 2: MediaPipe Demo starten
```bash
# Webcam-Demo für Echtzeit-Pose-Erkennung
python python_scripts\mediapipe_example.py
```

**Was Sie sehen werden:**
- Live-Webcam-Feed
- Skelett-Overlay auf Ihrem Körper
- Echtzeitdarstellung aller Gelenke
- Drücken Sie 'q' zum Beenden

---

## 📱 Alternative: Flutter App testen

Für die mobile Version:
```bash
cd C:\Users\Everl\Desktop\FHCampuswien\2025I2026\Software\gymguard
.\venv\Scripts\Activate.ps1
python prepare_models.py
```

### Schritt 2: Assets-Ordner erstellen
```bash
New-Item -ItemType Directory -Path gym_guard_app\assets\models -Force
```

### Schritt 3: Modell kopieren
```bash
Copy-Item models\movenet_lightning.tflite gym_guard_app\assets\models\
```

### Schritt 4: pubspec.yaml bearbeiten

Öffnen Sie `gym_guard_app\pubspec.yaml` und fügen Sie hinzu:

```yaml
flutter:
  uses-material-design: true
  
  # Fügen Sie diese Zeilen hinzu:
  assets:
    - assets/models/movenet_lightning.tflite
```

### Schritt 5: Dependencies neu laden
```bash
cd gym_guard_app
flutter pub get
flutter clean
```

## 📖 Vollständige Dokumentation:

- **README.md** - Projekt-Übersicht
- **SETUP_SUMMARY.md** - Detaillierte Setup-Zusammenfassung
- **NEXT_STEPS.md** - Code-Beispiele für Pose-Detection

## 🆘 Hilfe benötigt?

### Problem: "flutter: command not found"
```bash
# Prüfen Sie den PATH
echo $env:Path
# Flutter sollte in C:\flutter\bin sein
```

### Problem: "No devices found"
```bash
# Android-Gerät per USB verbinden
# USB-Debugging aktivieren
flutter devices
```

### Problem: App baut nicht
```bash
cd gym_guard_app
flutter clean
flutter pub get
flutter run
```

### Python Version prüfen
```bash
.\venv\Scripts\Activate.ps1
python --version  # Sollte 3.12.10 zeigen
```

## 🧪 MediaPipe testen:

## 🧪 MediaPipe testen:

```bash
.\venv\Scripts\Activate.ps1
python -c "import mediapipe as mp; print('MediaPipe Version:', mp.__version__)"
```

## 🎓 Nächste Lernziele:

1. **Jetzt**: MediaPipe Webcam-Demo testen (`python python_scripts\mediapipe_example.py`)
2. **Diese Woche**: Flutter App mit Kamera testen
3. **Nächste Woche**: Python Backend mit Flutter verbinden
4. **Später**: Übungserkennung & Feedback-System

## 📞 Wichtige Kommandos:

```bash
# Python Virtual Environment
.\venv\Scripts\Activate.ps1        # Aktivieren
python --version                   # Version prüfen (3.12.10)
python python_scripts\mediapipe_example.py  # Demo starten
deactivate                         # Deaktivieren

# Flutter
flutter doctor          # System überprüfen
flutter devices         # Geräte anzeigen
flutter run            # App starten
flutter analyze        # Code prüfen

# Python (im venv)
.\venv\Scripts\Activate.ps1    # Aktivieren
python prepare_models.py        # Modelle laden
deactivate                      # Deaktivieren
```

---

**Viel Erfolg! 🎉**
