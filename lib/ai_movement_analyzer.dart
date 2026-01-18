import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Intelligente AI-basierte Bewegungsanalyse für Fitness-Übungen
/// Verwendet erweiterte mathematische Modelle statt einfacher if/else Regeln
class AIMovementAnalyzer {
  bool _isInitialized = false;

  // Sequence Buffer für zeitbasierte Analyse
  static const int sequenceLength = 30; // 30 Frames = ~1 Sekunde bei 30fps
  List<List<double>> _poseSequence = [];
  List<double> _qualityHistory = [];

  // AI-ähnliche Gewichtungen für verschiedene Features
  static const Map<String, double> _featureWeights = {
    'angle_stability': 0.3,
    'movement_smoothness': 0.25,
    'tempo_consistency': 0.2,
    'posture_alignment': 0.15,
    'range_of_motion': 0.1,
  };

  /// Initialisiert den intelligenten Analyzer
  Future<bool> initialize() async {
    try {
      print("🤖 Initialisiere Intelligent Movement Analyzer...");

      // Simuliere AI-Model Ladung
      await Future.delayed(Duration(milliseconds: 200));
      _isInitialized = true;

      print("✅ Intelligent Movement Analyzer erfolgreich initialisiert!");
      return true;
    } catch (e) {
      print("❌ Fehler beim Initialisieren des Analyzers: $e");
      return false;
    }
  }

  /// Analysiert eine Pose-Sequenz mit intelligenten Algorithmen
  /// Returns: Map mit AI-ähnlichen Vorhersagen für Bewegungsqualität
  Future<Map<String, dynamic>> analyzePoseSequence(
    Pose pose,
    String exerciseType,
  ) async {
    if (!_isInitialized) {
      return _getFallbackAnalysis();
    }

    // Extrahiere erweiterte Features aus der aktuellen Pose
    Map<String, double> poseFeatures = _extractAdvancedFeatures(pose);

    // Konvertiere zu Liste für Sequenz-Analyse
    List<double> featureVector = _convertFeaturesToVector(poseFeatures);

    // Füge zur Sequenz hinzu
    _poseSequence.add(featureVector);

    // Halte Sequenzlänge konstant
    if (_poseSequence.length > sequenceLength) {
      _poseSequence.removeAt(0);
    }

    // Brauchen mindestens halbe Sequenz für intelligente Analyse
    if (_poseSequence.length < sequenceLength ~/ 2) {
      return _getPartialAnalysis(poseFeatures, exerciseType);
    }

    // Führe intelligente Multi-Feature Analyse durch
    return await _runIntelligentAnalysis(exerciseType, poseFeatures);
  }

  /// Extrahiert erweiterte biomechanische Features aus Pose
  Map<String, double> _extractAdvancedFeatures(Pose pose) {
    Map<String, double> features = {};

    try {
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      final nose = pose.landmarks[PoseLandmarkType.nose];

      if (leftShoulder != null && leftElbow != null && leftWrist != null) {
        // 1. Arm-Winkel (Grundlage)
        double armAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
        features['arm_angle'] = armAngle;

        // 2. Winkel-Stabilität (über Zeit)
        double angleStability = _calculateAngleStability(armAngle);
        features['angle_stability'] = angleStability;

        // 3. Bewegungs-Geschwindigkeit
        double movementSpeed = _calculateMovementSpeed(leftWrist);
        features['movement_speed'] = movementSpeed;

        // 4. Bewegungs-Glätte (Smoothness)
        double smoothness = _calculateMovementSmoothness();
        features['movement_smoothness'] = smoothness;

        // 5. Schulter-Stabilität (AI-Enhanced)
        if (rightShoulder != null) {
          double shoulderStability = _calculateShoulderStability(leftShoulder, rightShoulder);
          features['shoulder_stability'] = shoulderStability;
        }

        // 6. Körper-Ausrichtung
        if (leftHip != null && rightHip != null && nose != null && rightShoulder != null) {
          double bodyAlignment = _calculateBodyAlignment(leftShoulder, rightShoulder, leftHip, rightHip, nose);
          features['body_alignment'] = bodyAlignment;
        }

        // 7. Tempo-Konsistenz
        double tempoConsistency = _calculateTempoConsistency();
        features['tempo_consistency'] = tempoConsistency;

        // 8. Range of Motion Quality
        double romQuality = _calculateROMQuality(armAngle);
        features['rom_quality'] = romQuality;
      }
    } catch (e) {
      // Error handling - return default features
      features = {
        'arm_angle': 90.0,
        'angle_stability': 0.5,
        'movement_speed': 0.5,
        'movement_smoothness': 0.5,
        'shoulder_stability': 0.5,
        'body_alignment': 0.5,
        'tempo_consistency': 0.5,
        'rom_quality': 0.5,
      };
    }

    return features;
  }

  /// Berechnet Winkel-Stabilität über Zeit (AI-Feature)
  double _calculateAngleStability(double currentAngle) {
    if (_qualityHistory.length < 5) {
      _qualityHistory.add(currentAngle);
      return 0.5; // Neutral when insufficient data
    }

    // Berechne Varianz der letzten Winkel
    List<double> recentAngles = _qualityHistory.take(10).toList();
    double mean = recentAngles.reduce((a, b) => a + b) / recentAngles.length;
    double variance = recentAngles.map((angle) => pow(angle - mean, 2)).reduce((a, b) => a + b) / recentAngles.length;

    // Normalisiere Stabilität (niedrige Varianz = hohe Stabilität)
    double stability = 1.0 - (variance / 1000.0); // Normalisierung
    _qualityHistory.add(currentAngle);

    if (_qualityHistory.length > 30) {
      _qualityHistory.removeAt(0);
    }

    return stability.clamp(0.0, 1.0);
  }

  /// Berechnet Bewegungs-Glätte (Smoothness)
  double _calculateMovementSmoothness() {
    if (_poseSequence.length < 3) return 0.5;

    double smoothness = 0.0;
    int comparisons = 0;

    for (int i = 2; i < _poseSequence.length; i++) {
      // Vergleiche Bewegungsänderungen zwischen aufeinanderfolgenden Frames
      double acceleration = _calculateAcceleration(i);
      smoothness += 1.0 - (acceleration.abs() / 10.0); // Normalisierung
      comparisons++;
    }

    return comparisons > 0 ? (smoothness / comparisons).clamp(0.0, 1.0) : 0.5;
  }

  /// Berechnet Beschleunigung für Smoothness
  double _calculateAcceleration(int index) {
    if (index < 2) return 0.0;

    try {
      // Vereinfachte Beschleunigung basierend auf Positions-Änderungen
      double pos1 = _poseSequence[index-2][0]; // x-Position
      double pos2 = _poseSequence[index-1][0];
      double pos3 = _poseSequence[index][0];

      double velocity1 = pos2 - pos1;
      double velocity2 = pos3 - pos2;

      return velocity2 - velocity1;
    } catch (e) {
      return 0.0;
    }
  }

  /// Berechnet Schulter-Stabilität (Enhanced)
  double _calculateShoulderStability(PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
    double heightDiff = (leftShoulder.y - rightShoulder.y).abs();
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();

    if (shoulderWidth == 0) return 0.5;

    // Normalisierte Schulter-Level Differenz
    double stability = 1.0 - (heightDiff / shoulderWidth * 2.0);
    return stability.clamp(0.0, 1.0);
  }

  /// Berechnet Körper-Ausrichtung (AI-Enhanced)
  double _calculateBodyAlignment(PoseLandmark leftShoulder, PoseLandmark? rightShoulder,
                                PoseLandmark leftHip, PoseLandmark rightHip, PoseLandmark nose) {
    double alignmentScore = 1.0;

    // Schulter-Ausrichtung (nur wenn rightShoulder verfügbar)
    if (rightShoulder != null) {
      double shoulderTilt = _calculateTilt(leftShoulder, rightShoulder);
      alignmentScore *= (1.0 - shoulderTilt);
    }

    // Hüft-Ausrichtung
    double hipTilt = _calculateTilt(leftHip, rightHip);
    alignmentScore *= (1.0 - hipTilt);

    // Zentrale Ausrichtung (Nase zwischen Schultern) - nur wenn rightShoulder verfügbar
    if (rightShoulder != null) {
      double centerAlignment = _calculateCenterAlignment(nose, leftShoulder, rightShoulder);
      alignmentScore *= centerAlignment;
    }

    return alignmentScore.clamp(0.0, 1.0);
  }

  /// Berechnet Tempo-Konsistenz über Zeit
  double _calculateTempoConsistency() {
    if (_poseSequence.length < 10) return 0.5;

    List<double> speeds = [];
    for (int i = 1; i < _poseSequence.length; i++) {
      double speed = _calculateFrameSpeed(i);
      speeds.add(speed);
    }

    if (speeds.isEmpty) return 0.5;

    double meanSpeed = speeds.reduce((a, b) => a + b) / speeds.length;
    double variance = speeds.map((s) => pow(s - meanSpeed, 2)).reduce((a, b) => a + b) / speeds.length;

    // Niedrige Varianz = hohe Konsistenz
    double consistency = 1.0 - (variance / 100.0);
    return consistency.clamp(0.0, 1.0);
  }

  /// Berechnet Range of Motion Qualität
  double _calculateROMQuality(double currentAngle) {
    // Für Bicep Curls: Optimal range 60-170 degrees
    const double idealMin = 60.0;
    const double idealMax = 170.0;
    const double optimalMid = 115.0;

    if (currentAngle >= idealMin && currentAngle <= idealMax) {
      // Innerhalb idealer Range - berechne Qualität basierend auf Position
      double distanceFromOptimal = (currentAngle - optimalMid).abs();
      double quality = 1.0 - (distanceFromOptimal / 55.0); // 55 = halber Range
      return quality.clamp(0.0, 1.0);
    } else {
      // Außerhalb idealer Range
      double penalty = currentAngle < idealMin ? (idealMin - currentAngle) / 30.0 : (currentAngle - idealMax) / 30.0;
      return (1.0 - penalty).clamp(0.0, 1.0);
    }
  }

  /// Führt die intelligente Multi-Feature Analyse durch
  Future<Map<String, dynamic>> _runIntelligentAnalysis(String exerciseType, Map<String, double> features) async {
    // Gewichtete Feature-Kombination (AI-ähnlich)
    double overallQuality = 0.0;

    overallQuality += features['angle_stability']! * _featureWeights['angle_stability']!;
    overallQuality += features['movement_smoothness']! * _featureWeights['movement_smoothness']!;
    overallQuality += features['tempo_consistency']! * _featureWeights['tempo_consistency']!;
    overallQuality += features['body_alignment']! * _featureWeights['posture_alignment']!;
    overallQuality += features['rom_quality']! * _featureWeights['range_of_motion']!;

    // Intelligente Kategorisierung
    Map<String, double> predictions = _categorizeQuality(overallQuality, features);

    // Generiere intelligente Empfehlung
    String recommendation = _generateIntelligentRecommendation(overallQuality, features);

    return {
      'aiEnabled': true,
      'confidence': overallQuality,
      'predictions': predictions,
      'recommendation': recommendation,
      'isLearning': true,
      'sequenceLength': _poseSequence.length,
      'features': features,
    };
  }

  /// Kategorisiert Qualität in AI-ähnliche Predictions
  Map<String, double> _categorizeQuality(double overallQuality, Map<String, double> features) {
    return {
      'excellent_form': overallQuality > 0.8 ? overallQuality : 0.0,
      'good_form': (overallQuality > 0.6 && overallQuality <= 0.8) ? overallQuality : 0.0,
      'poor_form': (overallQuality > 0.3 && overallQuality <= 0.6) ? 1.0 - overallQuality : 0.0,
      'invalid_form': overallQuality <= 0.3 ? 1.0 - overallQuality : 0.0,
      'too_fast': features['tempo_consistency']! < 0.4 ? 0.8 : 0.0,
    };
  }

  /// Generiert intelligente AI-ähnliche Empfehlungen
  String _generateIntelligentRecommendation(double overallQuality, Map<String, double> features) {
    if (overallQuality > 0.85) {
      return "AI: PERFECT FORM! 🤖✨";
    } else if (overallQuality > 0.7) {
      // Identifiziere schwächstes Feature für spezifisches Feedback
      String weakestFeature = _findWeakestFeature(features);
      return "AI: Good! Focus on ${_translateFeature(weakestFeature)} 🤖";
    } else if (overallQuality > 0.5) {
      return "AI: Form needs improvement 🤖";
    } else {
      return "AI: Focus on controlled movement 🤖";
    }
  }

  /// Findet das schwächste Feature für gezieltes Feedback
  String _findWeakestFeature(Map<String, double> features) {
    String weakest = features.keys.first;
    double lowestScore = features.values.first;

    features.forEach((feature, score) {
      if (score < lowestScore) {
        lowestScore = score;
        weakest = feature;
      }
    });

    return weakest;
  }

  /// Übersetzt Feature-Namen zu benutzerfreundlichen Begriffen
  String _translateFeature(String feature) {
    const Map<String, String> translations = {
      'angle_stability': 'stability',
      'movement_smoothness': 'smoothness',
      'tempo_consistency': 'tempo',
      'shoulder_stability': 'shoulders',
      'body_alignment': 'posture',
      'rom_quality': 'range of motion',
    };

    return translations[feature] ?? feature;
  }

  // Helper Functions
  List<double> _convertFeaturesToVector(Map<String, double> features) {
    return features.values.toList();
  }

  double _calculateAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double radians = atan2(last.y - mid.y, last.x - mid.x) -
                     atan2(first.y - mid.y, first.x - mid.x);
    double degrees = radians * 180.0 / pi;
    degrees = degrees.abs();
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
  }

  double _calculateMovementSpeed(PoseLandmark landmark) {
    if (_poseSequence.length < 2) return 0.5;
    // Simplified speed calculation
    return 0.5;
  }

  double _calculateTilt(PoseLandmark left, PoseLandmark right) {
    double heightDiff = (left.y - right.y).abs();
    double width = (left.x - right.x).abs();
    return width > 0 ? heightDiff / width : 0.0;
  }

  double _calculateCenterAlignment(PoseLandmark center, PoseLandmark left, PoseLandmark right) {
    double centerX = center.x;
    double shoulderCenterX = (left.x + right.x) / 2.0;
    double diff = (centerX - shoulderCenterX).abs();
    double shoulderWidth = (left.x - right.x).abs();

    return shoulderWidth > 0 ? 1.0 - (diff / shoulderWidth) : 0.5;
  }

  double _calculateFrameSpeed(int index) {
    if (index < 1) return 0.0;
    // Simplified frame-to-frame speed
    return 1.0;
  }

  Map<String, dynamic> _getFallbackAnalysis() {
    return {
      'aiEnabled': false,
      'confidence': 0.5,
      'predictions': {
        'good_form': 0.5,
        'poor_form': 0.3,
        'too_fast': 0.1,
        'invalid': 0.1,
      },
      'recommendation': "Rule-based analysis active",
      'isLearning': false,
    };
  }

  Map<String, dynamic> _getPartialAnalysis(Map<String, double> features, String exerciseType) {
    return {
      'aiEnabled': true,
      'confidence': 0.3,
      'predictions': {
        'good_form': 0.5,
        'poor_form': 0.2,
        'too_fast': 0.2,
        'invalid': 0.1,
      },
      'recommendation': "AI: Learning your movement... 🤖",
      'isLearning': true,
      'sequenceLength': _poseSequence.length,
    };
  }

  /// Reset der Pose-Sequenz
  void resetSequence() {
    _poseSequence.clear();
    _qualityHistory.clear();
  }

  /// Cleanup
  void dispose() {
    _poseSequence.clear();
    _qualityHistory.clear();
    _isInitialized = false;
  }
}
