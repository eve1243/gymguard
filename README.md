# GymGuard - Fitness Pose Detection App

Eine Flutter-App zur Echtzeit-Analyse von Fitnessübungen mittels KI-gestützter Pose-Erkennung.

## ✅ Phase 1: Abgeschlossen

### Entwicklungsumgebung Setup
- ✅ Flutter SDK (Version 3.38.2) installiert und konfiguriert
- ✅ Visual Studio Code mit Flutter- und Dart-Extensions
- ✅ Android SDK konfiguriert (Version 35.0.0)
- ✅ Python 3.13.1 Umgebung mit virtuellem Environment (venv)
- ✅ TensorFlow und OpenCV-Python installiert

**Hinweis zu MediaPipe:** MediaPipe unterstützt derzeit Python 3.13 nicht. Optionen:
1. Python 3.12 oder niedriger verwenden für volle MediaPipe-Unterstützung
2. Alternativ TensorFlow Lite Hub Modelle verwenden (MoveNet, PoseNet)

### Projekt Setup
- ✅ Flutter-Projekt `gym_guard_app` erstellt
- ✅ Notwendige Dependencies hinzugefügt:
  - `camera`: Kamerazugriff
  - `tflite_flutter`: TensorFlow Lite Integration
  - `permission_handler`: Berechtigungsverwaltung
- ✅ Android-Berechtigungen konfiguriert (Camera, Storage)
- ✅ Basis-Kamera-Implementation (FR-01)

## 🚀 Phase 2: In Arbeit

### Pose-Estimation Implementation (FR-02)

#### Nächste Schritte:

1. **TensorFlow Lite Modell vorbereiten**
   ```bash
   # Im Python venv
   cd path/to/project
   .\venv\Scripts\Activate.ps1
   ```
   
   Optionen für Pose-Detection Modelle:
   - **MoveNet** (empfohlen): Schnell, genau, optimiert für mobile Geräte
   - **PoseNet**: Leichtgewichtig, gut dokumentiert
   - **BlazePose** (MediaPipe): Sehr genau, benötigt MediaPipe

2. **Modell in Flutter integrieren**
   - .tflite Modelldatei in `assets/models/` platzieren
   - `pubspec.yaml` aktualisieren um Assets einzubinden
   - `PoseDetector` Klasse in `lib/pose_detector.dart` vervollständigen

3. **Pose-Visualisierung**
   - `PosePainter` implementieren um Keypoints zu zeichnen
   - Skelett-Linien zwischen Gelenken darstellen
   - Echtzeit-Feedback anzeigen

## 📁 Projektstruktur

```
gymguard/
├── gym_guard_app/          # Flutter App
│   ├── lib/
│   │   ├── main.dart       # Haupt-App mit Kamera-Integration
│   │   └── pose_detector.dart  # Pose-Detection Logik
│   ├── android/            # Android-spezifische Konfiguration
│   └── assets/             # Zu erstellen für TFLite Modelle
│       └── models/         # .tflite Dateien hier platzieren
├── venv/                   # Python Virtual Environment
└── python_scripts/         # Python-Skripte für Modelltraining (optional)
```

## 🛠️ App ausführen

1. **Android-Gerät vorbereiten:**
   - USB-Debugging aktivieren
   - Gerät per USB verbinden

2. **App starten:**
   ```bash
   cd gym_guard_app
   flutter run
   ```

3. **Verfügbare Geräte prüfen:**
   ```bash
   flutter devices
   ```

## 📋 Anforderungen Status

### Must-Requirements (Muss-Kriterien)
- ✅ **FR-01**: Kamera-Schnittstelle implementiert
- 🔄 **FR-02**: Pose-Estimation in Arbeit
- ⏳ **FR-03**: Echtzeit-Feedback (Abhängig von FR-02)
- ⏳ **FR-04**: Übungserkennung (Zukünftig)

### Should-Requirements (Soll-Kriterien)
- ⏳ Datenbank zur Speicherung von Trainingssessions
- ⏳ Fortschrittsverfolgung
- ⏳ Personalisierte Empfehlungen

### Could-Requirements (Kann-Kriterien)
- ⏳ Social Features
- ⏳ Gamification
- ⏳ Erweiterte Analysen

## 🔧 Nützliche Befehle

```bash
# Flutter
flutter doctor              # System-Check
flutter pub get            # Dependencies installieren
flutter clean              # Build-Cache leeren
flutter build apk          # Release APK erstellen

# Python (in venv)
.\venv\Scripts\Activate.ps1    # Virtual Environment aktivieren
pip list                       # Installierte Pakete anzeigen
python --version               # Python-Version prüfen
```

## 📚 Ressourcen

- [Flutter Dokumentation](https://docs.flutter.dev/)
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [Camera Plugin](https://pub.dev/packages/camera)
- [TFLite Flutter Plugin](https://pub.dev/packages/tflite_flutter)
- [MoveNet Tutorial](https://www.tensorflow.org/lite/examples/pose_estimation/overview)

## ⚠️ Bekannte Probleme

1. **MediaPipe Python 3.13**: Nicht kompatibel - verwenden Sie Python 3.12 oder niedriger
2. **Visual Studio 2019**: Warnung kann ignoriert werden (nur für Windows Desktop Apps relevant)
3. **Java/Gradle Version**: Bei Bedarf Java Version anpassen oder Gradle Version in `android/gradle/wrapper/gradle-wrapper.properties` updaten

## 👨‍💻 Entwicklung

Entwickelt als Teil des Software Engineering Projekts an der FH Campus Wien (2025/2026).
