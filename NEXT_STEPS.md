# GymGuard - Nächste Schritte für Pose-Erkennung

## ✅ Was bereits implementiert ist:

1. **Entwicklungsumgebung komplett eingerichtet**
   - Flutter 3.38.2 installiert
   - Android SDK konfiguriert
   - Python venv mit TensorFlow und OpenCV

2. **Flutter App Grundgerüst**
   - Kamera-Integration funktionsfähig
   - Permission Handler implementiert
   - UI mit Live-Kamera-Preview

3. **Vorbereitete Struktur für Pose-Detection**
   - `pose_detector.dart` mit Klassen-Skelett
   - Python-Script zum Modell-Download bereit

## 🎯 Nächste Schritte - Pose-Estimation implementieren:

### Schritt 1: TensorFlow Lite Modell herunterladen

```bash
# Im Hauptverzeichnis (gymguard/)
.\venv\Scripts\Activate.ps1
python prepare_models.py
```

Dieser Script lädt automatisch:
- MoveNet Lightning (schnell, gut für Echtzeit)
- MoveNet Thunder (genauer, etwas langsamer)

### Schritt 2: Modell zu Flutter App hinzufügen

```bash
# Erstellen Sie den assets Ordner
New-Item -ItemType Directory -Path gym_guard_app\assets\models -Force

# Kopieren Sie das Modell
Copy-Item models\movenet_lightning.tflite gym_guard_app\assets\models\
```

### Schritt 3: pubspec.yaml aktualisieren

Fügen Sie in `gym_guard_app/pubspec.yaml` hinzu:

```yaml
flutter:
  assets:
    - assets/models/movenet_lightning.tflite
```

### Schritt 4: TFLite Flutter Plugin Setup

Das Plugin ist bereits installiert, aber für Android müssen Sie möglicherweise:

```bash
cd gym_guard_app
flutter pub get
```

### Schritt 5: pose_detector.dart vervollständigen

Aktualisieren Sie die `initialize()` Methode:

```dart
import 'package:tflite_flutter/tflite_flutter.dart';

Future<void> initialize() async {
  try {
    _interpreter = await Interpreter.fromAsset('assets/models/movenet_lightning.tflite');
    _isInitialized = true;
    print('Pose detector initialized successfully');
  } catch (e) {
    print('Error loading model: $e');
    _isInitialized = false;
  }
}
```

### Schritt 6: Bild-Preprocessing implementieren

MoveNet erwartet:
- Input: RGB Bild, 192x192 Pixel
- Output: 17 Keypoints mit [y, x, confidence]

Beispiel-Code für Image-Konvertierung:

```dart
import 'package:image/image.dart' as img;

Float32List preprocessImage(CameraImage image) {
  // 1. Convert CameraImage to RGB
  img.Image rgbImage = convertCameraImage(image);
  
  // 2. Resize to 192x192
  img.Image resized = img.copyResize(rgbImage, width: 192, height: 192);
  
  // 3. Normalize to [0, 1]
  var input = Float32List(1 * 192 * 192 * 3);
  var pixelIndex = 0;
  
  for (var y = 0; y < 192; y++) {
    for (var x = 0; x < 192; x++) {
      var pixel = resized.getPixel(x, y);
      input[pixelIndex++] = pixel.r / 255.0;
      input[pixelIndex++] = pixel.g / 255.0;
      input[pixelIndex++] = pixel.b / 255.0;
    }
  }
  
  return input;
}
```

### Schritt 7: Pose-Visualisierung

Aktualisieren Sie `PosePainter` in main.dart:

```dart
class PosePainter extends CustomPainter {
  final List<Keypoint>? keypoints;
  
  PosePainter(this.keypoints);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints == null) return;
    
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;
    
    // Draw keypoints
    for (var kp in keypoints!) {
      if (kp.confidence > 0.3) {
        canvas.drawCircle(
          Offset(kp.x * size.width, kp.y * size.height),
          8,
          paint
        );
      }
    }
    
    // Draw skeleton lines
    drawSkeleton(canvas, size, keypoints!);
  }
  
  void drawSkeleton(Canvas canvas, Size size, List<Keypoint> kps) {
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    // Define skeleton connections
    final connections = [
      [5, 6], [5, 7], [7, 9], [6, 8], [8, 10],  // Arms
      [5, 11], [6, 12], [11, 12],                // Torso
      [11, 13], [13, 15], [12, 14], [14, 16]     // Legs
    ];
    
    for (var conn in connections) {
      final p1 = kps[conn[0]];
      final p2 = kps[conn[1]];
      
      if (p1.confidence > 0.3 && p2.confidence > 0.3) {
        canvas.drawLine(
          Offset(p1.x * size.width, p1.y * size.height),
          Offset(p2.x * size.width, p2.y * size.height),
          linePaint
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## 🧪 Testen

```bash
cd gym_guard_app
flutter run
```

Verbinden Sie Ihr Android-Gerät und erlauben Sie Kamera-Zugriff.

## 📚 Hilfreiche Dependencies

Eventuell benötigt für Image-Processing:

```bash
flutter pub add image
```

## ⚠️ Troubleshooting

**Problem: Modell wird nicht gefunden**
- Prüfen Sie ob `assets/models/` existiert
- Stellen Sie sicher dass `pubspec.yaml` aktualisiert wurde
- Führen Sie `flutter clean` und dann `flutter pub get` aus

**Problem: CameraImage Konvertierung**
- CameraImage format ist platform-abhängig (YUV auf Android)
- Verwenden Sie ein Plugin wie `camera` mit image conversion utilities

**Problem: Langsame Performance**
- Verwenden Sie MoveNet Lightning statt Thunder
- Reduzieren Sie die Kamera-Auflösung
- Verarbeiten Sie nicht jeden Frame (z.B. nur jeden 3. Frame)

## 🎓 Lernressourcen

- [TFLite Flutter Plugin Dokumentation](https://pub.dev/packages/tflite_flutter)
- [MoveNet Guide](https://www.tensorflow.org/hub/tutorials/movenet)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [Image Processing in Flutter](https://pub.dev/packages/image)
