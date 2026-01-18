# GymGuard

**GymGuard** is a cross-platform mobile application (Android/iOS) designed to act as an intelligent, real-time personal trainer.

Unlike standard fitness trackers, this app uses **Computer Vision (Google ML Kit)** to "watch" you exercise through your smartphone camera. It analyzes your biomechanics in real-time to count repetitions, correct posture, and ensure safe movement tempo—all processed locally on your device for maximum privacy.

## 📱 Features

* **Smart Exercise Analysis:**
    * **Squats:** Checks for depth (Range of Motion) and safe tempo.
    * **Push-Ups:** Smart detection that only counts when you are in a horizontal position.
    * **Bicep Curls:** Prevents "swinging" and ensures controlled lifting speed.
    * **Overhead Press:** Verifies full arm extension.
* **Real-Time Feedback:** Visual skeleton overlay and Text-to-Speech audio guidance.
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

```bash
git clone https://github.com/eve1243/gymguard.git
cd gymguard
flutter pub get
flutter run
```
---
**With the Script**
```bash
./run_application.bat

