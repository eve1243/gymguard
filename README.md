# Rehabilitation Assistant (GymGuard AI)

**Rehabilitation Assistant** (formerly GymGuard) is a cross-platform mobile application (Android/iOS) designed to act as an intelligent, real-time personal trainer.

Unlike standard fitness trackers, this app uses **Computer Vision (Google ML Kit)** to "watch" you exercise through your smartphone camera. It analyzes your biomechanics in real-time to count repetitions, correct posture, and ensure safe movement tempo—all processed locally on your device for maximum privacy.

## 📱 Features

* **Smart Exercise Analysis:**
    * **Squats:** Checks for depth (Range of Motion) and safe tempo.
    * **Push-Ups:** Smart detection that only counts when you are in a horizontal position.
    * **Bicep Curls:** Prevents "swinging" and ensures controlled lifting speed.
    * **Overhead Press:** Verifies full arm extension.
* **Real-Time Feedback:** Visual skeleton overlay and Text-to-Speech audio guidance (e.g., "Slow down!", "Go lower").
* **User Profiles:** Save your name, age, and weight locally.
* **History:** Tracks your workout sessions automatically.
* **Privacy First:** No video is ever uploaded to the cloud. Everything runs on-device (Edge AI).

---

## 🛠️ Prerequisites

Before you start, make sure you have the following installed on your computer:

1.  **Flutter SDK:** [Download & Install Flutter](https://docs.flutter.dev/get-started/install)
2.  **VS Code:** Recommended editor with the "Flutter" and "Dart" extensions installed.
3.  **Android Studio:** Required to set up the Android Emulator.
4.  **Git:** To clone this repository.

---

## 🚀 Getting Started

Follow these exact steps to set up the project on your local machine.

### 1. Clone the Repository
Open your terminal (Command Prompt or PowerShell) and run:

```bash
git clone [https://github.com/Daniilsvirenko/rehabilitation-assistant.git](https://github.com/Daniilsvirenko/rehabilitation-assistant.git)
cd rehabilitation-assistant
2. Install Dependencies
You do not need to install libraries manually. The pubspec.yaml file contains everything. Just run:

Bash

flutter pub get
3. Set Up the Android Emulator (Critical Step!)
Since this app uses the camera, you must configure the Android Emulator to use your laptop's webcam.

Open Android Studio -> Device Manager.

Click the Edit (Pencil) icon on your virtual device (e.g., Medium Phone API 35).

Click Show Advanced Settings.

Scroll down to the Camera section.

Set Front to Webcam0 (your real webcam).

Set Back to Webcam0.

Click Finish.

Restart the emulator completely if it was already open.

4. Run the App
Make sure your emulator is running, then execute:

Bash

flutter run
📂 Project Structure
lib/main.dart: Contains the entire application logic (UI, ML Kit integration, and State Management).

pubspec.yaml: Lists all dependencies (camera, google_mlkit_pose_detection, flutter_tts, shared_preferences).

android/: Native Android configuration files.

ios/: Native iOS configuration files.

🤝 Troubleshooting
"Pixelated/Green Camera on Emulator": You forgot Step 3! Go back to Android Studio Device Manager and change the camera input from "Emulated" to "Webcam0".

"CocoaPods not installed" (macOS only): If you are on a Mac, run cd ios && pod install && cd ...

📜 License
This project was created for educational purposes as part of a university software engineering course.


### Next Step: How to Push this to GitHub
Since you already have the folder on your computer, here is how to "connect" it to this new repository name and upload your `README.md`:

1.  **Create the empty repo** on GitHub named `rehabilitation-assistant`.
2.  **In your VS Code terminal**, run these commands to update the remote link:

```powershell
# 1. Remove the old link to the group project
git remote remove origin

# 2. Add the link to YOUR new solo project
git remote add origin https://github.com/Daniilsvirenko/rehabilitation-assistant.git

# 3. Add the new README file
git add README.md

# 4. Save the changes
git commit -m "Update README with setup instructions"

# 5. Push everything to the new repo
git push -u origin main