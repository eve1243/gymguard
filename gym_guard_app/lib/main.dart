import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Camera Error: $e');
  }
  runApp(const GymGuardApp());
}

class GymGuardApp extends StatelessWidget {
  const GymGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymGuard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
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

// --- 1. MENU SCREEN ---
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _history = [];
  
  // FR-14: User Profile Data
  String _userName = "Guest";
  String _userAge = "--";
  String _userWeight = "--";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load History
    final String? historyJson = prefs.getString('workout_history');
    if (historyJson != null) {
      setState(() {
        _history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      });
    }

    // Load Profile (FR-14)
    setState(() {
      _userName = prefs.getString('user_name') ?? "Guest";
      _userAge = prefs.getString('user_age') ?? "--";
      _userWeight = prefs.getString('user_weight') ?? "--";
    });
  }

  void _openProfileSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    _loadData(); // Reload after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GymGuard AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blueAccent),
            onPressed: _openProfileSettings,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FR-14: User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.2)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5))
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello, $_userName!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      Text("Age: $_userAge  |  Weight: $_userWeight kg", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Start Workout",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(context, "Squats", "Legs (ROM check)", Icons.accessibility_new, ExerciseType.squat),
            const SizedBox(height: 15),
            _buildMenuButton(context, "Push-Ups", "Chest (Smart Mode)", Icons.fitness_center, ExerciseType.pushUp),
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
        _loadData(); // Reload history
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

// --- NEW: PROFILE SCREEN (FR-14) ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? "";
      _ageController.text = prefs.getString('user_age') ?? "";
      _weightController.text = prefs.getString('user_weight') ?? "";
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_age', _ageController.text);
    await prefs.setString('user_weight', _weightController.text);
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.monitor_weight)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("SAVE PROFILE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _saveProfile,
              ),
            )
          ],
        ),
      ),
    );
  }
}

enum ExerciseType { squat, pushUp, overheadPress, bicepCurl }

// --- 2. WORKOUT SCREEN ---
class WorkoutScreen extends StatefulWidget {
  final ExerciseType exerciseType;

  const WorkoutScreen({super.key, required this.exerciseType});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  PoseDetector? _poseDetector;
  FlutterTts flutterTts = FlutterTts();
  bool _isDetecting = false;
  bool _isPaused = false;
  int _cameraIndex = 1;
  
  // Logic Variables
  int _reps = 0;
  int _mistakes = 0;
  String _feedback = "Get Ready";
  Color _feedbackColor = Colors.white;
  String _stage = "start"; 
  double _minAngle = 180.0;
  double _startShoulderX = 0.0;
  DateTime _repStartTime = DateTime.now();
  
  // Logic helpers
  DateTime _lastRepTime = DateTime.now();
  DateTime _lastSpeech = DateTime.now();
  CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initTTS();
    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }

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

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _poseDetector == null || _isPaused) return;
    _isDetecting = true;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isDetecting = false;
      return;
    }

    try {
      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isNotEmpty) {
        final pose = poses.first;
        
        switch (widget.exerciseType) {
          case ExerciseType.squat: _analyzeSquat(pose); break;
          case ExerciseType.pushUp: _analyzePushUp(pose); break;
          case ExerciseType.overheadPress: _analyzeOverheadPress(pose); break;
          case ExerciseType.bicepCurl: _analyzeBicepCurl(pose); break;
        }
        
        if (mounted) {
          final painter = PosePainter(pose, image.width.toDouble(), image.height.toDouble(), _controller!.description.lensDirection);
          _customPaint = CustomPaint(painter: painter);
        }
      } else {
        _customPaint = null;
        _feedback = "Not visible";
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() {});
      _isDetecting = false;
    }
  }

  // --- 1. SQUAT ---
  void _analyzeSquat(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (hip == null || knee == null || ankle == null) return;
    if (hip.likelihood < 0.5 || knee.likelihood < 0.5) return;

    double angle = _calculateAngle(hip, knee, ankle);
    
    if (_stage == "down" && angle < _minAngle) {
      _minAngle = angle;
    }

    if (angle > 160) {
      if (_stage == "down") {
        if (DateTime.now().difference(_lastRepTime).inSeconds < 1) return;
        _lastRepTime = DateTime.now();

        final duration = DateTime.now().difference(_repStartTime);
        if (duration.inMilliseconds < 1500) { 
           setState(() => _mistakes++);
           _feedback = "TOO FAST!";
           _feedbackColor = Colors.redAccent;
           _speak("Slow down");
        } 
        else if (_minAngle < 90) {
          setState(() => _reps++);
          _feedback = "PERFECT!";
          _feedbackColor = Colors.greenAccent;
          _speak("Good");
        } else {
          setState(() => _mistakes++);
          _feedback = "TOO SHALLOW!";
          _feedbackColor = Colors.redAccent;
          _speak("Go lower");
        }
      }
      _stage = "up";
      _minAngle = 180.0;
    } else if (angle < 140) {
      if (_stage == "up") {
        _stage = "down";
        _minAngle = angle;
        _repStartTime = DateTime.now(); 
      }
      if (angle < 90) {
        _feedback = "UP!";
        _feedbackColor = Colors.blueAccent;
      } else {
        _feedback = "LOWER...";
        _feedbackColor = Colors.orangeAccent;
      }
    }
  }

  // --- 2. PUSH-UP (Smart Mode) ---
void _analyzePushUp(Pose pose) {
  final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final hip = pose.landmarks[PoseLandmarkType.leftHip];
  final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
  final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
  final knee = pose.landmarks[PoseLandmarkType.leftKnee];
  if (shoulder == null || hip == null || elbow == null || wrist == null || knee == null) return;

  final DateTime now = DateTime.now();

  // ===== PARAMETER =====
  const double minDownAngle = 95;     // tiefer runter
  const double minUpAngle = 155;      // oben fast ganz strecken
  const int minRepTimeMs = 700;       // nicht zu schnell
  const double postureMin = 150;      // Körper gerader
  const double postureMax = 215;
  // ====================

  // Lage-Check (wirklich am Boden)
  double diffY = (shoulder.y - hip.y).abs();
  double diffX = (shoulder.x - hip.x).abs();
  if (diffY > diffX * 1.2) {
    _feedback = "GET ON FLOOR";
    _feedbackColor = Colors.orangeAccent;
    return;
  }

  double armAngle = _calculateAngle(shoulder, elbow, wrist);
  double bodyAngle = _calculateAngle(shoulder, hip, knee);
  bool badPosture = bodyAngle < postureMin || bodyAngle > postureMax;

  // Startposition (unten)
  if (armAngle < minDownAngle) {
    _stage = "down";
    _repStartTime = now;
    _feedback = badPosture ? "BACK STRAIGHT" : "PUSH UP";
    _feedbackColor = badPosture ? Colors.redAccent : Colors.blueAccent;
    return;
  }

  // Endposition (oben)
  if (_stage == "down" && armAngle > minUpAngle) {
    final int repTime = now.difference(_repStartTime).inMilliseconds;
    _stage = "up";
    _lastRepTime = now;

    if (repTime < minRepTimeMs) {
      setState(() => _mistakes++);
      _feedback = "TOO FAST";
      _feedbackColor = Colors.redAccent;
      _speak("Slow down");
      return;
    }

    if (badPosture) {
      setState(() => _mistakes++);
      _feedback = "BAD FORM";
      _feedbackColor = Colors.redAccent;
      _speak("Straighten body");
      return;
    }

    setState(() => _reps++);
    _feedback = "GOOD PUSHUP";
    _feedbackColor = Colors.greenAccent;
    _speak("Good");
  }

  // Zwischenphase
  if (_stage == "up" && armAngle < 140 && armAngle > minDownAngle) {
    _feedback = "LOWER";
    _feedbackColor = Colors.orangeAccent;
  }
}

  // --- 3. OVERHEAD PRESS ---
void _analyzeOverheadPress(Pose pose) {
  final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
  final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
  final hip = pose.landmarks[PoseLandmarkType.leftHip];
  if (shoulder == null || elbow == null || wrist == null || hip == null) return;

  final double elbowAngle = _calculateAngle(shoulder, elbow, wrist);
  final DateTime now = DateTime.now();

  // ===== PARAMETER =====
  const double downAngle = 100;   // unten klar gebeugt
  const double upAngle = 165;     // oben fast gestreckt
  const int minPressTimeMs = 800; // zu schnell ❌
  const double leanTolerance = 0.25; // Hohlkreuz-Toleranz
  // ====================

  // Lean-Back / Schwung Check
  final double bodyScale = (shoulder.y - hip.y).abs();
  if ((shoulder.x - hip.x).abs() > bodyScale * leanTolerance) {
    _feedback = "NO LEAN BACK";
    _feedbackColor = Colors.redAccent;
    return;
  }

  // Startposition (unten)
  if (elbowAngle < downAngle && wrist.y > shoulder.y - 40) {
    _stage = "down";
    _repStartTime = now;
    _feedback = "PRESS UP";
    _feedbackColor = Colors.blueAccent;
    return;
  }

  // Endposition (oben)
  if (_stage == "down" && elbowAngle > upAngle && wrist.y < shoulder.y) {
    final int pressTime = now.difference(_repStartTime).inMilliseconds;
    _stage = "up";

    // ❌ zu schnell
    if (pressTime < minPressTimeMs) {
      setState(() => _mistakes++);
      _feedback = "TOO FAST";
      _feedbackColor = Colors.redAccent;
      _speak("Too fast");
      return;
    }

    // ✅ sauberer Rep
    setState(() => _reps++);
    _feedback = "GOOD PRESS";
    _feedbackColor = Colors.greenAccent;
    _speak("Good");
  }
}

  // --- 4. BICEP CURL (Balanced) ---
void _analyzeBicepCurl(Pose pose) {
  final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
  final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
  if (shoulder == null || elbow == null || wrist == null) return;

  final double angle = _calculateAngle(shoulder, elbow, wrist);
  final DateTime now = DateTime.now();

  // ===== PARAMETER (HIER KANNST DU FEINTUNEN) =====
  const int minRepTimeMs = 900;   // zu schnell darunter ❌
  const int maxRepTimeMs = 2500;  // zu langsam darüber ❌
  const double downAngle = 155;   // Arm fast gestreckt
  const double upAngle = 60;      // Arm klar gebeugt
  const double swingFactor = 0.30; // Schwung-Toleranz
  // ===============================================

  // Startposition (unten)
  if (angle > downAngle) {
    _stage = "down";
    _startShoulderX = shoulder.x;
    _repStartTime = now;
    return;
  }

  // Während Bewegung: Schwung prüfen
  if (_stage == "down" && angle < downAngle && angle > upAngle) {
    final double bodyScale = (shoulder.y - elbow.y).abs();
    if ((shoulder.x - _startShoulderX).abs() > bodyScale * swingFactor) {
      _feedback = "DON'T SWING";
      _feedbackColor = Colors.redAccent;
      return;
    }
  }

  // Endposition (oben)
  if (_stage == "down" && angle < upAngle) {
    final int repTime = now.difference(_repStartTime).inMilliseconds;

    _stage = "up";
    _lastRepTime = now;

    // ❌ ZU SCHNELL
    if (repTime < minRepTimeMs) {
      setState(() => _mistakes++);
      _feedback = "TOO FAST";
      _feedbackColor = Colors.redAccent;
      _speak("Too fast");
      return;
    }

    // ❌ ZU LANGSAM
    if (repTime > maxRepTimeMs) {
      setState(() => _mistakes++);
      _feedback = "TOO SLOW";
      _feedbackColor = Colors.orangeAccent;
      _speak("Faster");
      return;
    }

    // ✅ SAUBERER REP
    setState(() => _reps++);
    _feedback = "GOOD REP";
    _feedbackColor = Colors.greenAccent;
    _speak("Good");
  }
}

  double _calculateAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
                     math.atan2(first.y - mid.y, first.x - mid.x);
    double degrees = radians * 180.0 / math.pi;
    degrees = degrees.abs();
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
    final double scaleX = size.width / imageWidth;
    final double scaleY = size.height / imageHeight;

void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
  final p1 = pose.landmarks[type1];
  final p2 = pose.landmarks[type2];
  if (p1 == null || p2 == null) return;

  double x1 = p1.x * scaleX;
  double y1 = p1.y * scaleY;
  double x2 = p2.x * scaleX;
  double y2 = p2.y * scaleY;

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
