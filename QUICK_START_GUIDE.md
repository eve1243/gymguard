# GymGuard Quick Start Guide

Welcome to GymGuard! This guide will help you understand how to use the app and what the code does.

## 🎯 What is GymGuard?

GymGuard is an AI-powered fitness app that watches your workout form in real-time and provides instant feedback. Think of it as having a personal trainer in your pocket!

## 📚 For Code Reviewers & Learners

If you're here to understand the codebase, start with these documents:

1. **[CODE_EXPLANATION.md](CODE_EXPLANATION.md)** - Comprehensive code walkthrough
   - How the app works (line by line)
   - Exercise algorithms explained
   - Data flow and architecture

2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Visual diagrams and system design
   - System architecture diagrams
   - State machines for each exercise
   - Component interactions
   - Performance optimizations

3. **[README.md](README.md)** - Project overview (in German)
   - Setup instructions
   - Development roadmap
   - Requirements status

## 🚀 How to Use the App

### 1. Starting a Workout

1. Open GymGuard
2. Select an exercise:
   - **Squats** - Checks if you go deep enough and don't rush
   - **Push-Ups** - Makes sure you're horizontal and go low enough
   - **Overhead Press** - Verifies full arm extension
   - **Bicep Curls** - Detects if you're cheating by swinging

### 2. During Your Workout

**What you see:**
- Live camera feed showing you
- Green skeleton overlay (your pose)
- Rep counter (successful reps)
- Error counter (form mistakes)
- Status message (what to do)

**Color meanings:**
- 🟢 **Green** = "PERFECT!" - Good rep
- 🔵 **Blue** = "UP!" / "PUSH UP!" - Instructions
- 🟠 **Orange** = "LOWER..." - Keep going
- 🔴 **Red** = "TOO FAST!" - Form error

**Voice feedback:**
- The app speaks to you: "Good", "Slow down", "Go lower"
- Helps you focus on form, not the screen

### 3. Finishing Up

1. Press **FINISH** button (top right)
2. See your summary:
   - Total reps
   - Mistakes made
   - Form accuracy %
3. Results are automatically saved to history

## 🧠 How It Works (Simple Version)

```
1. Camera captures you
   ↓
2. AI finds your body joints (33 points)
   ↓
3. App measures angles (like knee angle)
   ↓
4. Checks if form is correct
   ↓
5. Shows feedback (visual + voice)
```

## 🎓 Understanding the Code

### Main Components

**1. main.dart** (816 lines)
   - Contains entire app
   - Three screens: Menu, Workout, Summary
   - Four exercise analyzers
   - All in one file for simplicity

**2. Python Scripts** (Optional)
   - `prepare_models.py` - Downloads AI models
   - `mediapipe_example.py` - Test pose detection on your computer

### Key Concepts

**Pose Landmarks**
- AI detects 33 body points
- Examples: nose, shoulders, elbows, knees, ankles
- Each has x, y coordinates and confidence score

**Angle Calculation**
```dart
// Example: Knee angle during squat
angle = _calculateAngle(hip, knee, ankle)
// 180° = standing
// 90° = parallel squat
```

**State Machine**
- Tracks if you're "up" or "down"
- Prevents double-counting
- Example for squats:
  ```
  Standing (>160°) → "up" state
  Descending (<140°) → "down" state
  Back to standing → Count rep!
  ```

## 💡 Exercise-Specific Logic

### Squats
**Checks:**
- ✅ Depth: Must reach < 90° knee angle (parallel)
- ✅ Tempo: Must take > 1.5 seconds (no bouncing)

**Feedback:**
- "TOO SHALLOW!" - Didn't go deep enough
- "TOO FAST!" - Rushed the rep
- "PERFECT!" - Good depth and tempo

### Push-Ups
**Checks:**
- ✅ Orientation: Must be horizontal (not standing)
- ✅ Range: Arms must reach < 90° (chest down)

**Special feature:**
- Detects if you're standing vs. on the floor
- Only counts reps when horizontal

### Overhead Press
**Checks:**
- ✅ Extension: Arms must be fully straight (>160°)
- ✅ Height: Wrists must be above shoulders

### Bicep Curls
**Checks:**
- ✅ No swinging: Shoulders shouldn't move forward
- ✅ Full range: From 160° (straight) to 50° (curled)

**Anti-cheat:**
- Records shoulder position at start
- If shoulder moves > 20% → "DON'T SWING!"
- Counts as mistake, not rep

## 🔍 Code Walkthrough (Where to Start)

If you want to understand the code:

1. **Start here:** Lines 16-24 (main function)
   - Entry point of the app

2. **Then look at:** Lines 269-305 (_processCameraImage)
   - This is where the magic happens
   - Camera frame → AI → Analysis → Feedback

3. **Explore analyzers:**
   - Squat: Lines 307-361
   - Push-up: Lines 363-406
   - Bicep curl: Lines 432-471

4. **Understand geometry:** Lines 473-480 (_calculateAngle)
   - How angles are calculated

5. **See visualization:** Lines 773-816 (PosePainter)
   - How skeleton is drawn

## 📊 Data Storage

**Workout History**
- Stored locally using SharedPreferences
- Format: JSON array
- Each workout has:
  ```json
  {
    "type": "Squats",
    "reps": 15,
    "mistakes": 2,
    "date": "Dec 3, 14:30"
  }
  ```

## 🎨 UI Elements

**MenuScreen**
- Exercise buttons
- Workout history (last 5)

**WorkoutScreen**
- Camera preview (full screen)
- Skeleton overlay (green lines)
- Stats panel (bottom):
  - REPS counter (left)
  - ERRORS counter (middle)
  - STATUS message (right)
- Controls (top):
  - Switch camera button
  - Pause/Resume button
  - FINISH button

**SummaryScreen**
- Trophy icon
- Total reps
- Mistakes count
- Accuracy percentage
- Back to menu button

## 🚦 Performance Tips

**Why the app is fast:**

1. **Low camera resolution** (240p)
   - Faster processing
   - Still accurate enough

2. **Frame throttling**
   - Skips frames if still processing
   - Prevents lag

3. **On-device AI**
   - No internet needed
   - No cloud delays
   - Privacy-friendly

## 🐛 Troubleshooting

**"Not visible"**
- Move back from camera
- Ensure full body is in frame
- Check lighting

**Reps not counting**
- Make sure you complete full range of motion
- For push-ups: Get on the floor (not standing)
- For squats: Go deeper (below parallel)

**Too many mistakes**
- Slow down your reps
- Focus on form over speed
- Listen to voice feedback

## 🎯 For Developers

**Want to add a new exercise?**

1. Add to enum:
   ```dart
   enum ExerciseType { squat, pushUp, newExercise }
   ```

2. Create analyzer function:
   ```dart
   void _analyzeNewExercise(Pose pose) {
     // Your logic
   }
   ```

3. Add to switch statement in _processCameraImage

4. Add menu button in MenuScreen

**Want to modify form rules?**
- Look in the exercise analyzers
- Adjust angle thresholds (e.g., change 90° to 80°)
- Modify tempo requirements (e.g., change 1500ms to 2000ms)

## 📖 Learning Resources

**Understand Pose Detection:**
- [ML Kit Documentation](https://developers.google.com/ml-kit/vision/pose-detection)
- [Pose Landmark Guide](https://developers.google.com/ml-kit/vision/pose-detection/classifying-poses)

**Learn Flutter:**
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

**Computer Vision Concepts:**
- Landmark detection
- Angle calculation with atan2
- State machines for tracking

## 💬 Common Questions

**Q: Why is all code in one file?**
A: For simplicity and easy understanding. In production, you'd split it into modules.

**Q: How accurate is the AI?**
A: ML Kit is very accurate (95%+) in good lighting with full body visible.

**Q: Can I use this offline?**
A: Yes! All AI runs on your device. No internet needed.

**Q: Why front camera?**
A: So you can see yourself while working out (like a mirror).

**Q: What about privacy?**
A: No images are stored or sent anywhere. Everything stays on your device.

## 🎉 Summary

GymGuard is a practical example of:
- Real-time computer vision
- Mobile AI/ML integration
- State machine design
- User experience design
- Geometric algorithms

The code is well-structured with clear exercise-specific logic, making it easy to understand and extend.

**For detailed code explanation:** See [CODE_EXPLANATION.md](CODE_EXPLANATION.md)
**For architecture diagrams:** See [ARCHITECTURE.md](ARCHITECTURE.md)

Happy learning! 💪🤖
