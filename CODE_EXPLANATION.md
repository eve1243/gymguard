# GymGuard Code Explanation

## 📖 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Main Application (main.dart)](#main-application)
4. [Python Scripts](#python-scripts)
5. [Key Algorithms](#key-algorithms)
6. [Data Flow](#data-flow)
7. [Exercise Analysis Details](#exercise-analysis-details)

---

## 🎯 Project Overview

**GymGuard** is an AI-powered fitness application that provides real-time feedback on workout form using computer vision and pose estimation. The app analyzes your body posture during exercises and gives instant audio and visual feedback to help improve form and prevent injuries.

### Technology Stack
- **Frontend**: Flutter (Dart) - Cross-platform mobile framework
- **AI/ML**: Google ML Kit Pose Detection - On-device pose estimation
- **Backend**: Python with TensorFlow, MediaPipe, OpenCV
- **Storage**: SharedPreferences (local storage for workout history)
- **Voice**: Flutter TTS (Text-to-Speech for audio feedback)

---

## 🏗️ Architecture

### Project Structure
```
gymguard/
├── gym_guard_app/              # Flutter mobile application
│   ├── lib/
│   │   └── main.dart           # Main app code (all screens + logic)
│   ├── android/                # Android configuration
│   ├── ios/                    # iOS configuration
│   └── pubspec.yaml            # Flutter dependencies
├── python_scripts/
│   └── mediapipe_example.py    # Python pose detection demo
└── prepare_models.py           # Model download/preparation script
```

### Three-Tier Architecture

1. **Presentation Layer** (UI)
   - MenuScreen: Exercise selection
   - WorkoutScreen: Live camera + analysis
   - SummaryScreen: Results display

2. **Business Logic Layer**
   - Pose detection pipeline
   - Exercise-specific analysis algorithms
   - Rep counting and form validation

3. **Data Layer**
   - Camera image processing
   - Pose landmark extraction
   - Workout history persistence

---

## 📱 Main Application (main.dart)

The entire Flutter app is in a single file with **816 lines** of code. Let's break it down:

### 1. Main Entry Point (Lines 1-24)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();  // Get available cameras
  runApp(const GymGuardApp());
}
```

**What it does:**
- Initializes Flutter
- Detects all available cameras (front/back)
- Launches the app

### 2. App Theme (Lines 26-45)

```dart
class GymGuardApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
      ),
      home: const MenuScreen(),
    );
  }
}
```

**What it does:**
- Sets up dark theme with blue accents
- Defines MenuScreen as starting point

---

### 3. MenuScreen (Lines 47-179)

**Purpose**: Main menu where users select exercises and view workout history.

#### Key Features:

**A. Exercise Buttons** (Lines 89-96)
```dart
_buildMenuButton(context, "Squats", "Legs (ROM check)", 
                 Icons.accessibility_new, ExerciseType.squat)
```
- 4 exercise types: Squats, Push-Ups, Overhead Press, Bicep Curl
- Each button navigates to WorkoutScreen with specific exercise type

**B. History Display** (Lines 110-139)
```dart
Future<void> _loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final String? historyJson = prefs.getString('workout_history');
  _history = List<Map<String, dynamic>>.from(json.decode(historyJson));
}
```
- Shows last 5 workouts
- Displays: exercise name, date, reps, mistakes
- Stored in JSON format using SharedPreferences

**Example JSON structure:**
```json
[
  {
    "type": "Squats",
    "reps": 15,
    "mistakes": 2,
    "date": "Dec 3, 14:30"
  },
  {
    "type": "Push-Ups",
    "reps": 20,
    "mistakes": 1,
    "date": "Dec 3, 15:00"
  }
]
```

---

### 4. WorkoutScreen (Lines 183-684)

**Purpose**: The heart of the app - real-time camera view with pose analysis.

#### State Variables (Lines 202-214)

```dart
int _reps = 0;              // Successful repetitions
int _mistakes = 0;          // Form errors
String _feedback = "Get Ready";  // Current status message
String _stage = "start";    // Exercise state (up/down/start)
double _minAngle = 180.0;   // Minimum angle reached (for squats)
```

#### Camera Initialization (Lines 236-260)

```dart
Future<void> _startCamera(int index) async {
  _controller = CameraController(
    cameras[index],
    ResolutionPreset.low,  // Low res for performance
    enableAudio: false,
    imageFormatGroup: Platform.isAndroid 
      ? ImageFormatGroup.nv21 
      : ImageFormatGroup.bgra8888,
  );
  await _controller!.initialize();
  _controller!.startImageStream(_processCameraImage);  // Stream frames
}
```

**What it does:**
- Initializes camera (default: front camera)
- Sets low resolution for better performance
- Starts streaming frames to `_processCameraImage`

#### Image Processing Pipeline (Lines 269-305)

```dart
Future<void> _processCameraImage(CameraImage image) async {
  if (_isDetecting || _poseDetector == null || _isPaused) return;
  _isDetecting = true;  // Prevent concurrent processing

  final inputImage = _inputImageFromCameraImage(image);
  final poses = await _poseDetector!.processImage(inputImage);
  
  if (poses.isNotEmpty) {
    final pose = poses.first;
    
    // Route to correct exercise analyzer
    switch (widget.exerciseType) {
      case ExerciseType.squat: _analyzeSquat(pose); break;
      case ExerciseType.pushUp: _analyzePushUp(pose); break;
      // ... etc
    }
    
    // Draw skeleton overlay
    _customPaint = CustomPaint(
      painter: PosePainter(pose, ...)
    );
  }
  
  _isDetecting = false;
}
```

**Flow:**
1. **Throttling**: Skip if already processing
2. **Convert**: Transform CameraImage to InputImage format
3. **Detect**: Run ML Kit pose detection
4. **Analyze**: Send pose to exercise-specific function
5. **Visualize**: Draw skeleton on screen
6. **Update UI**: setState triggers redraw

---

## 🧮 Key Algorithms

### 1. Angle Calculation (Lines 473-480)

```dart
double _calculateAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
  double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
                   math.atan2(first.y - mid.y, first.x - mid.x);
  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs();
  if (degrees > 180.0) degrees = 360.0 - degrees;
  return degrees;
}
```

**Purpose**: Calculate angle between three body landmarks (e.g., hip-knee-ankle)

**Math explained:**
- Uses arctangent (`atan2`) to get angles of two vectors
- Subtracts angles to get interior angle
- Normalizes to 0-180° range

**Example**: For knee angle during squat:
- `first` = hip
- `mid` = knee (vertex)
- `last` = ankle
- Returns ~180° when standing, ~90° when squatting

### 2. State Machine Pattern

Each exercise uses a state machine with states like:
- `"up"` - Extended position
- `"down"` - Contracted position
- `"start"` - Initial state

Transitions trigger rep counts and feedback.

---

## 🏋️ Exercise Analysis Details

### 1. Squat Analysis (Lines 307-361)

```dart
void _analyzeSquat(Pose pose) {
  // Get key landmarks
  final hip = pose.landmarks[PoseLandmarkType.leftHip];
  final knee = pose.landmarks[PoseLandmarkType.leftKnee];
  final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
  
  double angle = _calculateAngle(hip, knee, ankle);
  
  // Track minimum angle reached
  if (_stage == "down" && angle < _minAngle) {
    _minAngle = angle;
  }
  
  // Standing position (angle > 160°)
  if (angle > 160) {
    if (_stage == "down") {
      // Rep completed! Check quality...
      
      // Too fast? (< 1.5 seconds)
      if (duration.inMilliseconds < 1500) { 
         _mistakes++;
         _feedback = "TOO FAST!";
         _speak("Slow down");
      }
      // Good depth? (< 90°)
      else if (_minAngle < 90) {
         _reps++;
         _feedback = "PERFECT!";
         _speak("Good");
      }
      // Too shallow?
      else {
         _mistakes++;
         _feedback = "TOO SHALLOW!";
         _speak("Go lower");
      }
    }
    _stage = "up";
    _minAngle = 180.0;  // Reset
  }
  // Going down (angle < 140°)
  else if (angle < 140) {
    if (_stage == "up") {
      _stage = "down";
      _repStartTime = DateTime.now();  // Start timer
    }
    // Provide feedback during descent
    if (angle < 90) {
      _feedback = "UP!";
    } else {
      _feedback = "LOWER...";
    }
  }
}
```

**Quality Checks:**
1. **Depth**: Must reach < 90° knee angle
2. **Speed**: Must take > 1.5 seconds
3. **Tempo**: Provides live feedback during movement

**Why it works:**
- Knee angle decreases as you squat
- Tracks minimum angle to ensure depth
- Uses timer to prevent rushing

---

### 2. Push-Up Analysis (Lines 363-406)

**Unique Challenge**: Must detect if user is horizontal (push-up position) vs vertical (standing)

```dart
void _analyzePushUp(Pose pose) {
  final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final hip = pose.landmarks[PoseLandmarkType.leftHip];
  final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
  final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
  
  // ORIENTATION CHECK
  double diffY = (shoulder.y - hip.y).abs();  // Vertical distance
  double diffX = (shoulder.x - hip.x).abs();  // Horizontal distance
  
  // If vertical distance > horizontal distance = standing
  if (diffY > diffX) {
     _feedback = "GET ON FLOOR";
     return;
  }
  
  // Now analyze arm angle
  double armAngle = _calculateAngle(shoulder, elbow, wrist);
  
  if (armAngle > 160) {         // Top position
    if (_stage == "down") {
      _reps++;
      _feedback = "GOOD PUSHUP!";
    }
    _stage = "up";
  } 
  else if (armAngle < 90) {     // Bottom position
    _stage = "down";
    _feedback = "PUSH UP!";
  }
}
```

**Smart Features:**
- **Orientation detection**: Prevents counting if user is standing
- **Simple state machine**: Only needs up/down states
- **Arm angle focus**: shoulder-elbow-wrist angle

---

### 3. Overhead Press (Lines 408-430)

```dart
void _analyzeOverheadPress(Pose pose) {
  double elbowAngle = _calculateAngle(shoulder, elbow, wrist);
  
  // Arms fully extended AND wrist above shoulder
  if (elbowAngle > 160 && wrist.y < shoulder.y) {
    if (_stage == "down") {
      _reps++;
      _feedback = "GOOD!";
    }
    _stage = "up";
  } 
  // Arms bent AND weight near shoulders
  else if (elbowAngle < 90 && wrist.y > (shoulder.y - 100)) {
    _stage = "down";
    _feedback = "PUSH UP!";
  }
}
```

**Two conditions for completion:**
1. Elbow angle > 160° (fully extended)
2. Wrist Y-coordinate < shoulder Y-coordinate (arms overhead)

---

### 4. Bicep Curl (Lines 432-471)

**Most Complex**: Detects cheating by monitoring shoulder movement

```dart
void _analyzeBicepCurl(Pose pose) {
  double angle = _calculateAngle(shoulder, elbow, wrist);
  
  // Remember starting shoulder position
  if (_stage == "down") {
     _startShoulderX = shoulder.x; 
  }
  
  // Check if shoulder moved (swinging = cheating!)
  double bodyScale = (shoulder.y - elbow.y).abs();
  if (_stage == "up" && 
      (shoulder.x - _startShoulderX).abs() > (bodyScale * 0.2)) {
     _feedback = "DON'T SWING!";
     _speak("Do not swing");
  }
  
  if (angle > 160) {          // Arm extended
    _stage = "down";
  } 
  else if (angle < 50) {      // Arm fully curled
    if (_stage == "down") {
      if (_feedback == "DON'T SWING!") {
         _mistakes++;  // Cheated!
      } else {
         _reps++;      // Clean rep!
      }
    }
    _stage = "up";
  }
}
```

**Anti-Cheat System:**
1. Records shoulder X-position at start
2. Monitors shoulder movement during curl
3. If shoulder moves > 20% of body scale → SWING detected
4. Swing = counted as mistake, not rep

**Body Scale**: Distance from shoulder to elbow - used as reference for detecting significant movement

---

## 🎨 Visualization - PosePainter (Lines 773-816)

```dart
class PosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scaling factors
    final double scaleX = size.width / imageHeight; 
    final double scaleY = size.height / imageWidth;
    
    void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
      final p1 = pose.landmarks[type1];
      final p2 = pose.landmarks[type2];
      
      // Scale coordinates to screen size
      double x1 = p1.x * scaleX;
      double y1 = p1.y * scaleY;
      
      // Mirror for front camera
      if (lensDirection == CameraLensDirection.front) {
        x1 = size.width - x1;
        x2 = size.width - x2;
      }
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
    
    // Draw skeleton
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    // ... 12 total lines
  }
}
```

**What it does:**
- Draws green lines connecting body landmarks
- Scales coordinates from image space to screen space
- Mirrors display for front camera (so it looks natural)

**Lines drawn**: Shoulders, torso, arms, legs (12 connections total)

---

## 🔄 Data Flow

### Complete Cycle (every frame, ~30 FPS):

```
1. CAMERA
   ↓ CameraImage (raw bytes)
   
2. CONVERSION (_inputImageFromCameraImage)
   ↓ InputImage (ML Kit format)
   
3. ML KIT POSE DETECTOR
   ↓ List<Pose> (33 body landmarks)
   
4. EXERCISE ANALYZER (_analyzeSquat/_analyzePushUp/etc)
   ↓ Updates: _reps, _mistakes, _feedback, _stage
   
5. VISUALIZATION (PosePainter)
   ↓ CustomPaint widget
   
6. UI UPDATE (setState)
   ↓ Screen refreshes with new data
```

**Performance Note**: Processing is throttled via `_isDetecting` flag to prevent frame backlog

---

## 🐍 Python Scripts

### prepare_models.py

**Purpose**: Download and test TensorFlow Lite models

```python
def download_movenet_model(output_dir='models'):
    # Downloads two variants:
    # 1. MoveNet Lightning (fast, 192x192)
    # 2. MoveNet Thunder (accurate, 256x256)
    
    movenet_lightning_url = 'https://tfhub.dev/google/lite-model/...'
    urllib.request.urlretrieve(movenet_lightning_url, lightning_path)
```

**What it does:**
1. Downloads MoveNet models from TensorFlow Hub
2. Tests models with dummy input
3. Prints model info (input size, output shape)
4. Creates model_info.json for Flutter app

**Note**: GymGuard currently uses ML Kit (not MoveNet), but this script provides an alternative option.

---

### mediapipe_example.py

**Purpose**: Standalone Python demo for testing pose detection

#### Two Modes:

**1. Webcam Mode** (Lines 66-124)
```python
def process_webcam():
    cap = cv2.VideoCapture(0)
    
    with mp_pose.Pose(
        min_detection_confidence=0.5,
        model_complexity=1  # 0=lite, 1=full, 2=heavy
    ) as pose:
        while cap.isOpened():
            success, frame = cap.read()
            results = pose.process(frame_rgb)
            
            # Draw skeleton
            mp_drawing.draw_landmarks(
                frame,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS
            )
```

**Features:**
- Real-time webcam processing
- Visual skeleton overlay
- Status text ("Pose erkannt" / "Keine Pose")

**2. Image Mode** (Lines 15-64)
```python
def process_image(image_path):
    with mp_pose.Pose(static_image_mode=True) as pose:
        image = cv2.imread(image_path)
        results = pose.process(image_rgb)
        
        # Print all 33 landmarks
        for idx, landmark in enumerate(results.pose_landmarks.landmark):
            print(f"{mp_pose.PoseLandmark(idx).name}: "
                  f"x={landmark.x:.3f}, y={landmark.y:.3f}")
```

**Features:**
- Process static images
- Print landmark coordinates
- Save annotated image

#### Bonus: Squat Analyzer (Lines 149-170)

```python
def analyze_squat(landmarks):
    left_hip = landmarks.landmark[mp_pose.PoseLandmark.LEFT_HIP]
    left_knee = landmarks.landmark[mp_pose.PoseLandmark.LEFT_KNEE]
    left_ankle = landmarks.landmark[mp_pose.PoseLandmark.LEFT_ANKLE]
    
    angle = calculate_angle(left_hip, left_knee, left_ankle)
    
    if angle > 160:
        status = "Stehend"  # Standing
    elif angle > 90:
        status = "Teilweise gebeugt"  # Partially bent
    else:
        status = "Tief in der Hocke"  # Deep squat
```

**Demonstrates**: Same angle calculation logic used in Flutter app

---

## 🔐 Key Concepts Explained

### 1. Pose Landmarks

ML Kit detects **33 body points**:
```
0: nose              17: left_pinky
1: left_eye_inner    18: right_pinky
2: left_eye          19: left_index
...
11: left_hip         31: left_ankle
12: right_hip        32: right_ankle
```

Each landmark has:
- `x, y`: Normalized coordinates (0.0 to 1.0)
- `z`: Relative depth
- `likelihood`: Confidence score (0.0 to 1.0)

### 2. State Machine Design

**Why state machines?** Prevent double-counting and enable complex logic.

Example squat states:
```
        angle > 160°
  ┌─────────────────────────┐
  │                         │
  ▼                         │
[UP]                        │
  │                         │
  │ angle < 140°            │
  ▼                         │
[DOWN] ─────────────────────┘
  (tracks minAngle)
  
  Transition UP→DOWN: Start timer
  Transition DOWN→UP: Count rep, check quality
```

### 3. Coordinate Systems

**Challenge**: Camera image coordinates ≠ Screen coordinates

**Solution**: Scale and mirror
```dart
// Camera image: 480x640 (landscape)
// Screen: 1080x1920 (portrait)
// Need rotation + scaling

scaleX = screenWidth / imageHeight
scaleY = screenHeight / imageWidth

// Mirror for front camera
if (frontCamera) {
  x = screenWidth - x
}
```

### 4. Voice Feedback Throttling

```dart
Future<void> _speak(String text) async {
  if (DateTime.now().difference(_lastSpeech).inSeconds < 2) return;
  _lastSpeech = DateTime.now();
  await flutterTts.speak(text);
}
```

**Why?** Prevent annoying rapid-fire voice messages

**How?** Only speak if 2+ seconds since last message

---

## 📊 Summary Screen (Lines 686-771)

**Purpose**: Show workout results after "FINISH" button

**Key Features:**

1. **Statistics Display**
   - Total reps
   - Total mistakes
   - Form accuracy percentage

2. **Accuracy Calculation**
```dart
int totalAttempts = reps + mistakes;
double accuracy = (reps / totalAttempts) * 100;
// Green if > 80%, Orange otherwise
```

3. **Data Persistence**
```dart
Future<void> _finishWorkout() async {
  final prefs = await SharedPreferences.getInstance();
  history.add({
    'type': exerciseName,
    'reps': _reps,
    'mistakes': _mistakes,
    'date': DateFormat('MMM d, HH:mm').format(DateTime.now()),
  });
  await prefs.setString('workout_history', json.encode(history));
}
```

**Storage**: JSON array in SharedPreferences (local device storage)

---

## 🎯 Quality Assurance Features

### 1. Confidence Checking
```dart
if (hip.likelihood < 0.5 || knee.likelihood < 0.5) return;
```
Only analyze if ML Kit is confident about landmark positions

### 2. Debouncing
```dart
if (DateTime.now().difference(_lastRepTime).inSeconds < 1) return;
```
Prevent multiple counts from single rep

### 3. Form Validation
Each exercise has specific rules:
- Squats: Depth + tempo
- Push-ups: Orientation + range
- Overhead press: Full extension + height
- Bicep curls: No swinging

### 4. Visual Feedback
- Real-time skeleton overlay (green lines)
- Color-coded text (green = good, red = error, orange = warning)
- Large status display at bottom

### 5. Audio Feedback
- Text-to-speech for key moments
- Throttled to prevent spam
- Clear, short messages ("Good", "Slow down", "Go lower")

---

## 🚀 Performance Optimizations

### 1. Low Camera Resolution
```dart
ResolutionPreset.low  // ~240p - faster processing
```
**Trade-off**: Slightly less accurate pose detection, but much faster

### 2. Frame Throttling
```dart
if (_isDetecting) return;  // Skip if still processing last frame
```
**Prevents**: Frame backlog and memory issues

### 3. Minimal State Updates
```dart
// Only setState when data changes
if (mounted) setState(() {});
```
**Reduces**: Unnecessary UI redraws

### 4. Async Processing
```dart
await _poseDetector!.processImage(inputImage);
```
**Allows**: UI to remain responsive during ML inference

---

## 🔮 Extension Points

Want to add features? Here's how:

### 1. Add New Exercise
```dart
// 1. Add to enum
enum ExerciseType { squat, pushUp, newExercise }

// 2. Add analyzer function
void _analyzeNewExercise(Pose pose) {
  // Your logic here
}

// 3. Add to switch statement
switch (widget.exerciseType) {
  case ExerciseType.newExercise: 
    _analyzeNewExercise(pose); 
    break;
}

// 4. Add menu button
_buildMenuButton(context, "New Exercise", "Description", 
                 Icons.icon, ExerciseType.newExercise)
```

### 2. Add Advanced Analytics
```dart
// Track additional metrics
double _avgAngle = 0.0;
List<double> _angleHistory = [];
Duration _totalTime = Duration.zero;

// Calculate in analyzer
_angleHistory.add(angle);
_avgAngle = _angleHistory.reduce((a, b) => a + b) / _angleHistory.length;
```

### 3. Export Workout Data
```dart
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> exportToCSV() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/workouts.csv');
  String csv = _history.map((w) => 
    '${w['type']},${w['reps']},${w['mistakes']},${w['date']}'
  ).join('\n');
  await file.writeAsString(csv);
}
```

---

## 🎓 Learning Resources

### Understanding Pose Detection
- **ML Kit Docs**: https://developers.google.com/ml-kit/vision/pose-detection
- **Landmark Diagram**: Shows all 33 points
- **Coordinate System**: Normalized (0-1) vs pixel coordinates

### Flutter Concepts Used
- **StatefulWidget**: For screens with changing data
- **FutureBuilder**: Async data loading
- **CustomPainter**: Drawing on canvas
- **CameraController**: Camera access
- **SharedPreferences**: Simple local storage

### Math Concepts
- **atan2**: Angle of vector from origin
- **Vector subtraction**: Finding angles between landmarks
- **Normalization**: Scaling to 0-180° range

---

## 🐛 Common Issues & Solutions

### Issue 1: "Camera not working"
**Solution**: Check permissions in AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

### Issue 2: "Pose not detected"
**Causes:**
- Poor lighting
- User too far from camera
- Partial body visibility

**Solution**: Add user guidance
```dart
if (poses.isEmpty) {
  _feedback = "Step back, show full body";
}
```

### Issue 3: "Rep counting too sensitive"
**Solution**: Increase debounce time
```dart
if (DateTime.now().difference(_lastRepTime).inSeconds < 2) return;
```

### Issue 4: "App crashes on iOS"
**Solution**: Add camera usage description in Info.plist
```xml
<key>NSCameraUsageDescription</key>
<string>GymGuard needs camera access for pose detection</string>
```

---

## 📝 Code Quality Notes

### Good Practices Used:
✅ Single responsibility per function
✅ Descriptive variable names
✅ Error handling (try-catch)
✅ Resource cleanup (dispose methods)
✅ Const constructors for performance
✅ Null safety checks

### Areas for Improvement:
⚠️ All code in one file (should split into modules)
⚠️ Magic numbers (e.g., 160, 90 angles - should be constants)
⚠️ Limited error messages to user
⚠️ No unit tests
⚠️ Hard-coded strings (should use i18n for multi-language)

---

## 🎉 Conclusion

**GymGuard** is a well-structured fitness app that cleverly uses:
1. **Real-time pose detection** via ML Kit
2. **State machines** for rep counting
3. **Angle geometry** for form validation
4. **Multi-modal feedback** (visual + audio)

**Key Innovation**: Exercise-specific quality checks (depth, tempo, orientation, anti-cheat)

**Architecture Strength**: Clean separation of concerns despite single-file structure

**Best Learning Aspects**:
- Practical computer vision application
- State machine design pattern
- Flutter camera integration
- Real-time ML inference
- Geometric algorithms

This code serves as an excellent template for building AI-powered fitness applications!
