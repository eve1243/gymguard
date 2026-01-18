# GymGuard

**GymGuard** is a cross-platform mobile application (Android/iOS) designed to act as an intelligent, real-time personal trainer.

Unlike standard fitness trackers, this app uses **Computer Vision (Google ML Kit)** to "watch" you exercise through your smartphone camera. It analyzes your biomechanics in real-time to count repetitions, correct posture, and ensure safe movement tempo—all processed locally on your device for maximum privacy.

* Works for **any user** on **ios and android**!

## 📱 Features

* **Smart Exercise Analysis:**
    * **Squats:** Checks for depth (Range of Motion) and safe tempo.
    * **Push-Ups:** Smart detection that only counts when you are in a horizontal position.
    * **Bicep Curls:** Prevents "swinging", ensures controlled lifting speed, **and detects shoulder shrugging**.
    * **Overhead Press:** Verifies full arm extension.
* **Real-Time Feedback:** Visual skeleton overlay and Text-to-Speech audio guidance.
* **Advanced Form Detection:** Multi-point tracking for shoulder stability and proper biomechanics.
* **User Profiles:** Save your name, age, and weight locally.
* **History:** Tracks your workout sessions automatically.
* **Privacy First:** No video is ever uploaded. Everything runs on-device.

---

## 🛠️ Prerequisites

- Flutter SDK
- VS Code (+ Flutter & Dart Extensions)
- Android Studio
- Git

---

## 🚀 Getting Started

### Universal Quick Start (iOS & Android)
```bash
# Clone the repository
git clone https://github.com/eve1243/gymguard.git
cd gymguard

# Run with our mobile-optimized script
# Windows:
run_application.bat

# macOS/Linux: 
chmod +x run_application.sh && ./run_application.sh
```

### Manual Setup (Advanced Users)
```bash
# Install dependencies
flutter pub get

# Run on connected mobile device
flutter run

# Or run with specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

### Requirements
- **Flutter SDK** (latest stable version)
- **iOS or Android device** with debugging enabled
- **Camera permissions** granted on target device

### Device Setup
#### 📱 Android:
1. Enable Developer Options (Settings > About > Tap "Build number" 7x)
2. Enable USB Debugging
3. Connect via USB and trust computer

#### 🍎 iOS:
1. Connect via USB cable
2. Trust computer when prompted
3. Enter passcode if requested

### Troubleshooting
- **No devices:** Check USB debugging (Android) or trust computer (iOS)
- **Build errors:** Run `flutter clean`
- **Camera issues:** Grant camera permissions when app starts
- **Mobile script:** Optimized specifically for iOS and Android deployment

