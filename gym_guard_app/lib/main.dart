import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/services.dart';

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
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GymGuard AI")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select Workout",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            _buildMenuButton(context, "Squats", "Legs (ROM check)", Icons.accessibility_new, ExerciseType.squat),
            const SizedBox(height: 20),
            _buildMenuButton(context, "Overhead Press", "Shoulders (Elbow check)", Icons.fitness_center, ExerciseType.overheadPress),
            const SizedBox(height: 20),
            _buildMenuButton(context, "Bicep Curl", "Arms (Swing check)", Icons.sports_gymnastics, ExerciseType.bicepCurl),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String subtitle, IconData icon, ExerciseType type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        backgroundColor: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.blueAccent)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutScreen(exerciseType: type)),
        );
      },
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54),
        ],
      ),
    );
  }
}

enum ExerciseType { squat, overheadPress, bicepCurl }

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
  bool _isDetecting = false;
  bool _isPaused = false;
  
  // Stats
  int _reps = 0;
  int _mistakes = 0;
  String _feedback = "Get Ready";
  Color _feedbackColor = Colors.white;
  
  // Logic State
  String _stage = "start"; 
  double _minAngle = 180.0; // For Squat depth
  double _maxShoulderMove = 0.0; // For Curl swinging
  double _startShoulderX = 0.0;

  CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;
    CameraDescription description = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      description,
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

  // --- LOGIC 1: SQUAT (Check Depth/ROM) ---
  void _analyzeSquat(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (hip == null || knee == null || ankle == null) return;
    if (hip.likelihood < 0.5 || knee.likelihood < 0.5) return;

    double angle = _calculateAngle(hip, knee, ankle);
    
    // Track depth
    if (_stage == "down" && angle < _minAngle) {
      _minAngle = angle;
    }

    if (angle > 160) {
      if (_stage == "down") {
        if (_minAngle < 90) {
          setState(() => _reps++);
          _feedback = "GOOD SQUAT!";
          _feedbackColor = Colors.greenAccent;
        } else {
          setState(() => _mistakes++);
          _feedback = "TOO SHALLOW!"; // Error: Bad ROM
          _feedbackColor = Colors.redAccent;
        }
      }
      _stage = "up";
      _minAngle = 180.0;
    } else if (angle < 140) {
      if (_stage == "up") {
        _stage = "down";
        _minAngle = angle;
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

  // --- LOGIC 2: OVERHEAD PRESS (Check Elbow Flare) ---
  void _analyzeOverheadPress(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final hip = pose.landmarks[PoseLandmarkType.leftHip]; // For vertical reference

    if (shoulder == null || elbow == null || wrist == null || hip == null) return;

    // Angle 1: Arm extension (Shoulder-Elbow-Wrist)
    double extensionAngle = _calculateAngle(shoulder, elbow, wrist);
    
    // Angle 2: Elbow Flare (Hip-Shoulder-Elbow) - roughly
    // Ideally we want elbows somewhat tucked, not 90 degrees out constantly, 
    // but for simple logic we check full extension.

    if (extensionAngle > 160 && wrist.y < shoulder.y) {
      // Arms up
      if (_stage == "down") {
        setState(() => _reps++);
        _feedback = "STRONG PRESS!";
        _feedbackColor = Colors.greenAccent;
      }
      _stage = "up";
    } else if (extensionAngle < 90 && wrist.y > (shoulder.y - 100)) {
      // Arms down
      _stage = "down";
      _feedback = "PUSH UP!";
      _feedbackColor = Colors.blueAccent;
    } else {
      // FR-11 Check: If elbows drop too low or weird angle?
      // Simple check: keep wrist above elbow
      if (wrist.y > elbow.y) {
         _feedback = "WATCH ELBOWS!";
         _feedbackColor = Colors.orangeAccent;
      }
    }
  }

  // --- LOGIC 3: BICEP CURL (Check Swinging/Cheating) ---
  void _analyzeBicepCurl(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    
    if (shoulder == null || elbow == null || wrist == null) return;

    double angle = _calculateAngle(shoulder, elbow, wrist);

    // Track shoulder movement (Cheating detection)
    if (_stage == "down") {
       _startShoulderX = shoulder.x; // Remember start pos
    }
    
    // If shoulder moves too much forward/back relative to body size -> swinging
    double bodyScale = (shoulder.y - elbow.y).abs(); // Approx upper arm length
    if (_stage == "up" && (shoulder.x - _startShoulderX).abs() > (bodyScale * 0.2)) {
       _feedback = "DON'T SWING!";
       _feedbackColor = Colors.redAccent;
       // We don't count mistake immediately to avoid spam, but warn user
    }

    if (angle > 160) {
      _stage = "down";
      _feedback = "CURL UP!";
      _feedbackColor = Colors.blueAccent;
    } else if (angle < 50) {
      if (_stage == "down") {
        if (_feedback == "DON'T SWING!") {
           setState(() => _mistakes++); // Count cheat as mistake
        } else {
           setState(() => _reps++);
           _feedback = "GOOD CURL!";
           _feedbackColor = Colors.greenAccent;
        }
      }
      _stage = "up";
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

  void _finishWorkout() {
    _controller?.stopImageStream();
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
      case ExerciseType.overheadPress: title = "Overhead Press"; break;
      case ExerciseType.bicepCurl: title = "Bicep Curl"; break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
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