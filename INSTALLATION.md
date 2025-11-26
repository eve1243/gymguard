# 🚀 GymGuard - Installation & Setup Guide

## 📋 Voraussetzungen

### Beide Plattformen (Windows & macOS)
- Git installiert
- Mindestens 10 GB freier Speicherplatz
- Internetverbindung für Downloads
- Android-Gerät mit USB-Debugging (oder iOS-Gerät für macOS)

---

## 🪟 Windows Setup

### 1. Flutter installieren

```powershell
# Downloadlink: https://docs.flutter.dev/get-started/install/windows
# Oder mit Chocolatey:
choco install flutter

# Flutter zum PATH hinzufügen (wenn manuell installiert):
# Systemumgebungsvariablen > Path > Neu > C:\flutter\bin

# Verifizieren:
flutter doctor
```

### 2. Android Studio installieren

```powershell
# Download: https://developer.android.com/studio
# Nach Installation: Android Studio öffnen > More Actions > SDK Manager
# Installieren: Android SDK, SDK Platform Tools, SDK Build-Tools
```

### 3. Python 3.12 installieren

```powershell
# Mit winget:
winget install Python.Python.3.12

# Verifizieren:
python --version  # Sollte 3.12.x zeigen
```

### 4. Projekt klonen

```powershell
cd C:\Users\IhrName\Desktop
git clone https://github.com/eve1243/gymguard.git
cd gymguard
```

### 5. Python Virtual Environment einrichten

```powershell
# Virtual Environment erstellen:
py -3.12 -m venv venv

# Aktivieren:
.\venv\Scripts\Activate.ps1

# Bei Fehler "Ausführung von Skripts deaktiviert":
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Dependencies installieren:
pip install --upgrade pip
pip install tensorflow==2.19.1
pip install mediapipe==0.10.21
pip install opencv-python==4.11.0.86
pip install numpy

# Verifizieren:
python -c "import mediapipe as mp; print('MediaPipe:', mp.__version__)"
```

### 6. Flutter App einrichten

```powershell
cd gym_guard_app

# Dependencies installieren:
flutter pub get

# Android Lizenzen akzeptieren:
flutter doctor --android-licenses

# Prüfen:
flutter doctor
```

### 7. Android-Gerät verbinden

```powershell
# USB-Debugging aktivieren:
# Einstellungen > Über das Telefon > 7x auf Build-Nummer tippen
# Einstellungen > Entwickleroptionen > USB-Debugging aktivieren

# Gerät prüfen:
flutter devices
```

### 8. App starten

```powershell
flutter run
```

---

## 🍎 macOS Setup

### 1. Homebrew installieren (falls nicht vorhanden)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Flutter installieren

```bash
# Mit Homebrew:
brew install --cask flutter

# Oder manuell:
# Download: https://docs.flutter.dev/get-started/install/macos
# Entpacken nach ~/development/flutter
# PATH hinzufügen zu ~/.zshrc:
export PATH="$PATH:$HOME/development/flutter/bin"

# Verifizieren:
flutter doctor
```

### 3. Xcode installieren (für iOS)

```bash
# Aus dem App Store installieren
# Nach Installation:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

### 4. Android Studio installieren (für Android)

```bash
# Download: https://developer.android.com/studio
# Nach Installation: Android Studio > Settings > Android SDK
# Installieren: Android SDK, SDK Platform Tools, SDK Build-Tools
```

### 5. Python 3.12 installieren

```bash
# Mit Homebrew:
brew install python@3.12

# Verifizieren:
python3.12 --version
```

### 6. Projekt klonen

```bash
cd ~/Desktop
git clone https://github.com/eve1243/gymguard.git
cd gymguard
```

### 7. Python Virtual Environment einrichten

```bash
# Virtual Environment erstellen:
python3.12 -m venv venv

# Aktivieren:
source venv/bin/activate

# Dependencies installieren:
pip install --upgrade pip
pip install tensorflow==2.19.1
pip install mediapipe==0.10.21
pip install opencv-python==4.11.0.86
pip install numpy

# Verifizieren:
python -c "import mediapipe as mp; print('MediaPipe:', mp.__version__)"
```

### 8. Flutter App einrichten

```bash
cd gym_guard_app

# Dependencies installieren:
flutter pub get

# Für Android - Lizenzen akzeptieren:
flutter doctor --android-licenses

# Für iOS - CocoaPods installieren:
sudo gem install cocoapods
cd ios
pod install
cd ..

# Prüfen:
flutter doctor
```

### 9. Gerät verbinden

**Für Android:**
```bash
# USB-Debugging aktivieren (siehe Windows-Anleitung)
flutter devices
```

**Für iOS:**
```bash
# iPhone per USB verbinden
# Xcode > Window > Devices and Simulators
# Gerät vertrauen
flutter devices
```

### 10. App starten

```bash
# Android:
flutter run

# iOS (benötigt Apple Developer Account):
flutter run -d <device-id>
```

---

## 🧪 MediaPipe Python Demo testen

### Windows
```powershell
cd C:\Users\IhrName\Desktop\gymguard
.\venv\Scripts\Activate.ps1
python python_scripts\mediapipe_example.py
```

### macOS
```bash
cd ~/Desktop/gymguard
source venv/bin/activate
python python_scripts/mediapipe_example.py
```

**Was Sie sehen sollten:**
- Webcam-Feed öffnet sich
- Skelett wird auf Ihren Körper gezeichnet
- 'q' drücken zum Beenden

---

## 🔧 Häufige Probleme

### Windows: "flutter: command not found"
```powershell
# Flutter zum PATH hinzufügen:
# Win + R > sysdm.cpl > Erweitert > Umgebungsvariablen
# Path > Bearbeiten > Neu > C:\flutter\bin
```

### macOS: "flutter: command not found"
```bash
# PATH in ~/.zshrc oder ~/.bash_profile hinzufügen:
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### "No devices found"
```bash
# Android: USB-Debugging überprüfen
# iOS: Xcode > Window > Devices and Simulators

flutter devices
```

### Python MediaPipe Import-Fehler
```bash
# Sicherstellen dass venv aktiviert ist und Python 3.12 verwendet wird
python --version  # Muss 3.12.x sein

# MediaPipe neu installieren:
pip uninstall mediapipe
pip install mediapipe==0.10.21
```

### Flutter Build-Fehler
```bash
# Cache leeren und neu bauen:
flutter clean
flutter pub get
flutter run
```

### Android Lizenzen nicht akzeptiert
```bash
flutter doctor --android-licenses
# Alle mit 'y' akzeptieren
```

### iOS Code Signing-Fehler
```bash
# Xcode öffnen > gym_guard_app/ios/Runner.xcworkspace
# Signing & Capabilities > Team auswählen
# Bundle Identifier ändern (muss eindeutig sein)
```

---

## 📱 Erste Schritte nach Installation

1. **App starten:** `flutter run`
2. **Kamera-Berechtigung akzeptieren**
3. **Vor die Kamera stellen** - Ihr Skelett sollte erscheinen!
4. **Logs prüfen:** Terminal zeigt erkannte Keypoints

---

## 🎯 Projekt-Struktur

```
gymguard/
├── gym_guard_app/          # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart              # Hauptapp mit Kamera
│   │   └── pose_detector_mlkit.dart  # ML Kit Integration
│   ├── android/            # Android-spezifisch
│   └── ios/                # iOS-spezifisch
├── python_scripts/         # Python Demos
│   └── mediapipe_example.py  # MediaPipe Webcam Demo
├── venv/                   # Python Virtual Environment
└── prepare_models.py       # Modell-Download-Script
```

---

## 🆘 Hilfe & Support

**Flutter Dokumentation:** https://docs.flutter.dev  
**MediaPipe Dokumentation:** https://google.github.io/mediapipe  
**GitHub Issues:** https://github.com/eve1243/gymguard/issues

**Wichtige Kommandos zum Merken:**

```bash
# Flutter
flutter doctor          # System-Check
flutter devices         # Geräte anzeigen
flutter run            # App starten
flutter clean          # Cache leeren

# Python (venv aktiviert)
python --version       # Version prüfen
pip list              # Installierte Packages
deactivate            # venv deaktivieren

# Git
git pull              # Updates holen
git status            # Änderungen anzeigen
```

---

**Viel Erfolg! 🎉**
