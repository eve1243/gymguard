// GymGuard - AI-Powered Fitness Form Analyzer
// 
// This app uses real-time pose detection to analyze workout form and provide
// instant feedback on exercise technique. It supports multiple exercises:
// - Squats (with depth and tempo validation)
// - Push-Ups (with orientation detection)
// - Overhead Press (with full extension tracking)
// - Bicep Curls (with anti-cheat swing detection)

import 'dart:math' as math;        // For angle calculations
import 'dart:typed_data';          // For camera image byte handling
import 'dart:io';                  // For platform detection (Android/iOS)
import 'dart:convert';             // For JSON encoding/decoding workout history

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';                            // Camera access
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; // AI pose detection
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';   // Local storage for workout history
import 'package:flutter_tts/flutter_tts.dart';                 // Text-to-speech for voice feedback
import 'package:intl/intl.dart';                               // Date formatting

// Global list of available cameras (front/back)
List<CameraDescription> cameras = [];

/// App entry point
/// Initializes camera and launches the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Camera Error: $e');
  }
  runApp(const GymGuardApp());
}

/// Root app widget
/// Sets up dark theme and navigation
class GymGuardApp extends StatelessWidget {
  const GymGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymGuard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),  // Dark background
        primaryColor: Colors.blueAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

// ============================================================================
// SCREEN 1: MENU SCREEN
// ============================================================================
// Main menu for exercise selection and workout history display
//
// Features:
// - 4 exercise selection buttons
// - Recent workout history (last 5 sessions)
// - Persistent storage using SharedPreferences
// ============================================================================

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _history = [];  // Workout history from local storage

  @override
  void initState() {
    super.initState();
    _loadHistory();  // Load saved workouts when screen opens
  }

  /// Loads workout history from SharedPreferences (local storage)
  /// History is stored as JSON array
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('workout_history');
    if (historyJson != null) {
      setState(() {
        _history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GymGuard AI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Start Workout",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(context, "Squats", "Legs (ROM check)", Icons.accessibility_new, ExerciseType.squat),
            const SizedBox(height: 15),
            _buildMenuButton(context, "Push-Ups", "Chest (Horizontal only)", Icons.fitness_center, ExerciseType.pushUp),
            const SizedBox(height: 15),
            _buildMenuButton(context, "Overhead Press", "Shoulders", Icons.arrow_upward, ExerciseType.overheadPress),
            const SizedBox(height: 15),
            _buildMenuButton(context, "Bicep Curl", "Arms (Strict Tempo)", Icons.sports_gymnastics, ExerciseType.bicepCurl),
            
            const SizedBox(height: 40),
            const Text(
              "Recent History",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Text("No workouts yet. Start training!", style: TextStyle(color: Colors.white54));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length > 5 ? 5 : _history.length,
      itemBuilder: (context, index) {
        final item = _history[_history.length - 1 - index];
        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(_getIcon(item['type']), color: Colors.blueAccent),
            title: Text(item['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${item['date']}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${item['reps']} Reps", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                Text("${item['mistakes']} Errors", style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(String type) {
    if (type.contains("Squat")) return Icons.accessibility_new;
    if (type.contains("Push")) return Icons.fitness_center;
    if (type.contains("Press")) return Icons.arrow_upward;
    return Icons.sports_gymnastics;
  }

  Widget _buildMenuButton(BuildContext context, String title, String subtitle, IconData icon, ExerciseType type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        backgroundColor: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.blueAccent)),
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutScreen(exerciseType: type)),
        );
        _loadHistory();
      },
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.blueAccent),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        ],
      ),
    );
  }
}

/// Enum to identify different exercise types
/// Used to route to correct analysis function
enum ExerciseType { squat, pushUp, overheadPress, bicepCurl }

// ============================================================================
// SCREEN 2: WORKOUT SCREEN
// ============================================================================
// Live camera view with real-time pose analysis
//
// Architecture:
// 1. Camera streams frames (~30 FPS)
// 2. Each frame is processed by ML Kit Pose Detector (AI)
// 3. Pose landmarks (33 body points) are extracted
// 4. Exercise-specific analyzer validates form
// 5. Skeleton overlay drawn on camera view
// 6. Real-time feedback displayed (visual + audio)
//
// Key Features:
// - State machine for rep counting (up/down states)
// - Form validation (depth, tempo, orientation)
// - Mistake tracking (errors vs successful reps)
// - Voice feedback (Text-to-Speech)
// - Pause/Resume functionality
// - Camera switching (front/back)
// ============================================================================

class WorkoutScreen extends StatefulWidget {
  final ExerciseType exerciseType;

  const WorkoutScreen({super.key, required this.exerciseType});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with WidgetsBindingObserver {
  // Camera and AI components
  CameraController? _controller;      // Manages camera hardware
  PoseDetector? _poseDetector;        // ML Kit AI model for pose detection
  FlutterTts flutterTts = FlutterTts();  // Text-to-speech for voice feedback
  
  // Control flags
  bool _isDetecting = false;  // Prevents concurrent frame processing
  bool _isPaused = false;     // Workout paused state
  int _cameraIndex = 1;       // Current camera (0=back, 1=front typically)
  
  // ========== REP COUNTING AND FORM VALIDATION ==========
  int _reps = 0;              // Count of successful reps
  int _mistakes = 0;          // Count of form errors
  String _feedback = "Get Ready";  // Current status message shown to user
  Color _feedbackColor = Colors.white;  // Color coding: green=good, red=error, orange=warning
  
  // ========== STATE MACHINE VARIABLES ==========
  String _stage = "start";    // Exercise phase: "up", "down", or "start"
  double _minAngle = 180.0;   // Minimum angle reached during squat (for depth check)
  double _startShoulderX = 0.0;  // Starting shoulder position (bicep curl swing detection)
  DateTime _repStartTime = DateTime.now();  // When current rep started (for tempo check)
  
  // ========== TIMING AND THROTTLING ==========
  DateTime _lastRepTime = DateTime.now();   // Prevents double-counting same rep
  DateTime _lastSpeech = DateTime.now();    // Prevents voice feedback spam
  
  // ========== VISUALIZATION ==========
  CustomPaint? _customPaint;  // Skeleton overlay drawn on camera feed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initTTS();
    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  }

  /// Text-to-speech configuration
  /// Speed set to 0.5 for clear pronunciation
  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }

  /// Speaks feedback text with throttling
  /// Prevents voice spam (minimum 2 seconds between messages)
  Future<void> _speak(String text) async {
    if (DateTime.now().difference(_lastSpeech).inSeconds < 2) return;
    _lastSpeech = DateTime.now();
    await flutterTts.speak(text);
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;
    int initialIndex = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    if (initialIndex != -1) _cameraIndex = initialIndex;
    else _cameraIndex = 0;
    await _startCamera(_cameraIndex);
  }

  Future<void> _startCamera(int index) async {
    if (_controller != null) await _controller!.dispose();
    _controller = CameraController(
      cameras[index],
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    try {
      await _controller!.initialize();
      if (!mounted) return;
      _controller!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  void _switchCamera() {
    if (cameras.length < 2) return;
    int newIndex = (_cameraIndex + 1) % cameras.length;
    _cameraIndex = newIndex;
    _startCamera(newIndex);
  }

  /// Main image processing pipeline
  /// Called for every camera frame (~30 FPS)
  /// 
  /// Flow:
  /// 1. Throttle check (skip if already processing)
  /// 2. Convert CameraImage to ML Kit format
  /// 3. Run AI pose detection (gets 33 body landmarks)
  /// 4. Route to exercise-specific analyzer
  /// 5. Draw skeleton overlay
  /// 6. Update UI
  Future<void> _processCameraImage(CameraImage image) async {
    // Skip if already processing a frame, paused, or detector not ready
    if (_isDetecting || _poseDetector == null || _isPaused) return;
    _isDetecting = true;  // Set lock to prevent concurrent processing

    // Convert camera format to ML Kit format
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isDetecting = false;
      return;
    }

    try {
      // Run AI pose detection - returns list of detected poses
      // Usually 0-1 person detected per frame
      final poses = await _poseDetector!.processImage(inputImage);
      
      if (poses.isNotEmpty) {
        final pose = poses.first;  // Use first detected person
        
        // Route to correct exercise analyzer based on selected exercise type
        switch (widget.exerciseType) {
          case ExerciseType.squat: _analyzeSquat(pose); break;
          case ExerciseType.pushUp: _analyzePushUp(pose); break;
          case ExerciseType.overheadPress: _analyzeOverheadPress(pose); break;
          case ExerciseType.bicepCurl: _analyzeBicepCurl(pose); break;
        }
        
        // Create skeleton overlay painter if screen is still mounted
        if (mounted) {
          final painter = PosePainter(
            pose, 
            image.width.toDouble(), 
            image.height.toDouble(), 
            _controller!.description.lensDirection
          );
          _customPaint = CustomPaint(painter: painter);
        }
      } else {
        // No person detected in frame
        _customPaint = null;
        _feedback = "Not visible";
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      // Always unlock and update UI, even if error occurred
      if (mounted) setState(() {});
      _isDetecting = false;
    }
  }

  // ============================================================================
  // EXERCISE ANALYZERS
  // ============================================================================
  // Each analyzer implements exercise-specific form validation logic
  // using a state machine pattern (up/down states)
  // ============================================================================

  // --- SQUAT ANALYZER ---
  /// Analyzes squat form with depth and tempo validation
  /// 
  /// Quality checks:
  /// - Depth: Knee angle must reach < 90° (parallel or below)
  /// - Tempo: Must take > 1.5 seconds (prevents bouncing)
  /// 
  /// State machine:
  /// - "up" state: Knees extended (angle > 160°)
  /// - "down" state: Descending (angle < 140°)
  /// - Tracks minimum angle reached during descent
  void _analyzeSquat(Pose pose) {
    // Get left leg landmarks (hip-knee-ankle)
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
    
    // Validate landmarks exist and ML Kit is confident
    if (hip == null || knee == null || ankle == null) return;
    if (hip.likelihood < 0.5 || knee.likelihood < 0.5) return;

    // Calculate knee angle (180° = standing, 90° = parallel squat)
    double angle = _calculateAngle(hip, knee, ankle);
    
    // Track minimum angle reached during descent (for depth check)
    if (_stage == "down" && angle < _minAngle) {
      _minAngle = angle;
    }

    // STANDING POSITION: Knees extended (angle > 160°)
    if (angle > 160) {
      if (_stage == "down") {
        // Rep completed! Now validate quality...
        
        // Debounce: Prevent double-counting within 1 second
        if (DateTime.now().difference(_lastRepTime).inSeconds < 1) return;
        _lastRepTime = DateTime.now();

        // Check tempo: Should take > 1.5 seconds
        final duration = DateTime.now().difference(_repStartTime);
        if (duration.inMilliseconds < 1500) { 
           // TOO FAST - rushing leads to injury
           setState(() => _mistakes++);
           _feedback = "TOO FAST!";
           _feedbackColor = Colors.redAccent;
           _speak("Slow down");
        } 
        // Check depth: Did we reach parallel (< 90°)?
        else if (_minAngle < 90) {
          // PERFECT REP!
          setState(() => _reps++);
          _feedback = "PERFECT!";
          _feedbackColor = Colors.greenAccent;
          _speak("Good");
        } else {
          // TOO SHALLOW - didn't reach parallel
          setState(() => _mistakes++);
          _feedback = "TOO SHALLOW!";
          _feedbackColor = Colors.redAccent;
          _speak("Go lower");
        }
      }
      _stage = "up";
      _minAngle = 180.0;  // Reset for next rep
      
    // DESCENDING: Knees bending (angle < 140°)
    } else if (angle < 140) {
      if (_stage == "up") {
        // Just started descending - begin new rep
        _stage = "down";
        _minAngle = angle;
        _repStartTime = DateTime.now();  // Start timer for tempo check
      }
      // Provide real-time feedback during descent
      if (angle < 90) {
        _feedback = "UP!";  // At bottom, tell user to push up
        _feedbackColor = Colors.blueAccent;
      } else {
        _feedback = "LOWER...";  // Still descending
        _feedbackColor = Colors.orangeAccent;
      }
    }
  }

  // --- PUSH-UP ANALYZER ---
  /// Analyzes push-up form with smart orientation detection
  /// 
  /// Unique challenge: Must distinguish between:
  /// - Horizontal position (push-up) - VALID
  /// - Vertical position (standing) - INVALID
  /// 
  /// Solution: Compare vertical vs horizontal distance between shoulder and hip
  /// - If vertical distance > horizontal distance = standing (reject)
  /// - If horizontal distance > vertical distance = push-up position (accept)
  void _analyzePushUp(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];

    if (shoulder == null || hip == null || elbow == null || wrist == null) return;

    // ========== ORIENTATION CHECK ==========
    // Calculate distances between shoulder and hip
    double diffY = (shoulder.y - hip.y).abs();  // Vertical distance
    double diffX = (shoulder.x - hip.x).abs();  // Horizontal distance

    // If vertical distance > horizontal distance, person is standing (vertical)
    // We only count push-ups when person is horizontal (on the floor)
    if (diffY > diffX) {
       _feedback = "GET ON FLOOR";  // Tell user to get into push-up position
       _feedbackColor = Colors.orangeAccent;
       return;  // Stop analysis - not in correct position
    }

    // ========== PUSH-UP ANALYSIS (Person is horizontal) ==========
    // Calculate arm angle (shoulder-elbow-wrist)
    double armAngle = _calculateAngle(shoulder, elbow, wrist);

    // TOP POSITION: Arms extended (angle > 160°)
    if (armAngle > 160) {
      if (_stage == "down") {
        // Rep completed!
        
        // Debounce to prevent double-counting
        if (DateTime.now().difference(_lastRepTime).inSeconds < 1) return;
        _lastRepTime = DateTime.now();

        setState(() => _reps++);
        _feedback = "GOOD PUSHUP!";
        _feedbackColor = Colors.greenAccent;
        _speak("Good");
      }
      _stage = "up";
      
    // BOTTOM POSITION: Chest down (angle < 90°)
    } else if (armAngle < 90) {
      _stage = "down";
      _feedback = "PUSH UP!";
      _feedbackColor = Colors.blueAccent;
      
    // MIDDLE POSITION: Descending
    } else if (armAngle < 140 && _stage == "up") {
      _feedback = "LOWER...";
      _feedbackColor = Colors.orangeAccent;
    }
  }

  // --- 3. OVERHEAD PRESS ---
  void _analyzeOverheadPress(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    if (shoulder == null || elbow == null || wrist == null) return;

    double elbowAngle = _calculateAngle(shoulder, elbow, wrist);

    if (elbowAngle > 160 && wrist.y < shoulder.y) {
      if (_stage == "down") {
        setState(() => _reps++);
        _feedback = "GOOD!";
        _feedbackColor = Colors.greenAccent;
        _speak("Good press");
      }
      _stage = "up";
    } else if (elbowAngle < 90 && wrist.y > (shoulder.y - 100)) {
      _stage = "down";
      _feedback = "PUSH UP!";
      _feedbackColor = Colors.blueAccent;
    }
  }

  // --- BICEP CURL ANALYZER ---
  /// Analyzes bicep curl form with anti-cheat swing detection
  /// 
  /// Common cheating pattern: Using momentum by swinging shoulders forward
  /// 
  /// Solution: Track shoulder X-position
  /// - Record starting shoulder position when arm is down
  /// - Monitor shoulder movement during curl
  /// - If shoulder moves > 20% of body scale = SWING (cheating)
  /// - Flag as mistake instead of valid rep
  void _analyzeBicepCurl(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    if (shoulder == null || elbow == null || wrist == null) return;

    // Calculate arm angle (shoulder-elbow-wrist)
    double angle = _calculateAngle(shoulder, elbow, wrist);

    // ========== SWING DETECTION ==========
    // Record starting shoulder position when arm is extended
    if (_stage == "down") {
       _startShoulderX = shoulder.x; 
    }
    
    // Calculate body scale for relative movement detection
    // Using shoulder-to-elbow distance as reference
    double bodyScale = (shoulder.y - elbow.y).abs();
    
    // Check if shoulder has moved significantly (> 20% of body scale)
    // This indicates swinging/using momentum
    if (_stage == "up" && (shoulder.x - _startShoulderX).abs() > (bodyScale * 0.2)) {
       _feedback = "DON'T SWING!";
       _feedbackColor = Colors.redAccent;
       _speak("Do not swing");
    }

    // ========== REP COUNTING ==========
    // EXTENDED POSITION: Arm straight (angle > 160°)
    if (angle > 160) {
      _stage = "down";
      _feedback = "CURL UP!";
      _feedbackColor = Colors.blueAccent;
      
    // CURLED POSITION: Arm fully bent (angle < 50°)
    } else if (angle < 50) {
      if (_stage == "down") {
        // Debounce
        if (DateTime.now().difference(_lastRepTime).inSeconds < 1) return;
        _lastRepTime = DateTime.now();

        // Check if we detected swinging
        if (_feedback == "DON'T SWING!") {
           // Cheated - count as mistake
           setState(() => _mistakes++);
        } else {
           // Clean rep - count it!
           setState(() => _reps++);
           _feedback = "GOOD!";
           _feedbackColor = Colors.greenAccent;
           _speak("Nice");
        }
      }
      _stage = "up";
    }
  }

  /// Calculates angle between three landmarks (geometric calculation)
  /// 
  /// Uses arctangent to find angle at the middle point
  /// 
  /// Example: For knee angle in a squat:
  ///   first = hip
  ///   mid = knee (the vertex where we measure angle)
  ///   last = ankle
  /// 
  /// Returns: Angle in degrees (0-180°)
  /// - 180° = fully extended (straight line)
  /// - 90° = right angle
  /// - 0° = fully bent (overlapping)
  double _calculateAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    // Calculate angles of two vectors using atan2
    // Vector 1: mid -> first
    // Vector 2: mid -> last
    double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
                     math.atan2(first.y - mid.y, first.x - mid.x);
    
    // Convert radians to degrees
    double degrees = radians * 180.0 / math.pi;
    
    // Take absolute value (we want interior angle, not direction)
    degrees = degrees.abs();
    
    // Normalize to 0-180° range
    if (degrees > 180.0) degrees = 360.0 - degrees;
    
    return degrees;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation rotation = InputImageRotation.rotation0deg;
    if (Platform.isAndroid) {
       var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
       if (rotationCompensation == null) return null;
       if (camera.lensDirection == CameraLensDirection.front) {
         rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
       } else {
         rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
       }
       rotation = InputImageRotationValue.fromRawValue(rotationCompensation) ?? InputImageRotation.rotation0deg;
    }
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final size = Size(image.width.toDouble(), image.height.toDouble());
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller?.pauseVideoRecording(); 
      } else {
        _controller?.resumeVideoRecording();
      }
    });
  }

  Future<void> _finishWorkout() async {
    _controller?.stopImageStream();
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('workout_history');
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      history = List<Map<String, dynamic>>.from(json.decode(historyJson));
    }
    String typeName = "";
    switch(widget.exerciseType) {
      case ExerciseType.squat: typeName = "Squats"; break;
      case ExerciseType.pushUp: typeName = "Push-Ups"; break;
      case ExerciseType.overheadPress: typeName = "Overhead Press"; break;
      case ExerciseType.bicepCurl: typeName = "Bicep Curl"; break;
    }
    history.add({
      'type': typeName,
      'reps': _reps,
      'mistakes': _mistakes,
      'date': DateFormat('MMM d, HH:mm').format(DateTime.now()),
    });
    await prefs.setString('workout_history', json.encode(history));

    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
          reps: _reps, 
          mistakes: _mistakes,
          exerciseType: widget.exerciseType
        )
      )
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _poseDetector?.close();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String title = "";
    switch(widget.exerciseType) {
      case ExerciseType.squat: title = "Squats"; break;
      case ExerciseType.pushUp: title = "Push-Ups"; break;
      case ExerciseType.overheadPress: title = "Overhead Press"; break;
      case ExerciseType.bicepCurl: title = "Bicep Curl"; break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _switchCamera,
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: _finishWorkout,
              child: const Text("FINISH", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_customPaint != null && !_isPaused) _customPaint!,
          
          if (_isPaused)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pause_circle_outline, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text("PAUSED", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      child: const Text("RESUME", style: TextStyle(fontSize: 18)),
                    )
                  ],
                ),
              ),
            ),

          if (!_isPaused)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("REPS", style: TextStyle(color: Colors.white60)),
                        Text("$_reps", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("ERRORS", style: TextStyle(color: Colors.redAccent)),
                        Text("$_mistakes", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("STATUS", style: TextStyle(color: Colors.white60)),
                          Text(_feedback, textAlign: TextAlign.right, style: TextStyle(color: _feedbackColor, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- 3. SUMMARY SCREEN ---
class SummaryScreen extends StatelessWidget {
  final int reps;
  final int mistakes;
  final ExerciseType exerciseType;

  const SummaryScreen({super.key, required this.reps, required this.mistakes, required this.exerciseType});

  @override
  Widget build(BuildContext context) {
    String exerciseName = "";
    switch(exerciseType) {
      case ExerciseType.squat: exerciseName = "Squats"; break;
      case ExerciseType.pushUp: exerciseName = "Push-Ups"; break;
      case ExerciseType.overheadPress: exerciseName = "Overhead Press"; break;
      case ExerciseType.bicepCurl: exerciseName = "Bicep Curl"; break;
    }

    int totalAttempts = reps + mistakes;
    double accuracy = totalAttempts > 0 ? (reps / totalAttempts) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text("Workout Complete!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text(exerciseName, style: const TextStyle(fontSize: 20, color: Colors.blueAccent)),
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard("Total Reps", "$reps", Colors.white),
                  _buildStatCard("Mistakes", "$mistakes", Colors.redAccent),
                ],
              ),
              const SizedBox(height: 20),
              Text("Form Accuracy: ${accuracy.toStringAsFixed(1)}%", 
                style: TextStyle(fontSize: 18, color: accuracy > 80 ? Colors.green : Colors.orange)
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text("BACK TO MENU", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white60)),
          Text(value, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final Pose pose;
  final double imageWidth;
  final double imageHeight;
  final CameraLensDirection lensDirection;

  PosePainter(this.pose, this.imageWidth, this.imageHeight, this.lensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4.0..color = Colors.greenAccent;
    final double scaleX = size.width / imageHeight; 
    final double scaleY = size.height / imageWidth;

    void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
      final p1 = pose.landmarks[type1];
      final p2 = pose.landmarks[type2];
      if (p1 == null || p2 == null) return;
      double x1 = p1.x * scaleX;
      double y1 = p1.y * scaleY;
      double x2 = p2.x * scaleX;
      double y2 = p2.y * scaleY;
      if (lensDirection == CameraLensDirection.front) {
        x1 = size.width - x1;
        x2 = size.width - x2;
      }
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}