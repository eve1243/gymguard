# GymGuard Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GYMGUARD APP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              PRESENTATION LAYER (UI)                   │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │                                                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │    │
│  │  │ MenuScreen   │  │ WorkoutScreen│  │SummaryScreen│ │    │
│  │  │              │  │              │  │             │ │    │
│  │  │ - Exercise   │  │ - Camera     │  │ - Results   │ │    │
│  │  │   selection  │  │   preview    │  │ - Stats     │ │    │
│  │  │ - History    │  │ - Skeleton   │  │ - Accuracy  │ │    │
│  │  └──────┬───────┘  └──────┬───────┘  └─────────────┘ │    │
│  │         │                 │                            │    │
│  └─────────┼─────────────────┼────────────────────────────┘    │
│            │                 │                                  │
│  ┌─────────▼─────────────────▼────────────────────────────┐    │
│  │           BUSINESS LOGIC LAYER                         │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │                                                         │    │
│  │  Exercise Analyzers:                                   │    │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │    │
│  │  │_analyzeSquat│ │_analyzePushUp│ │_analyzeBicep│     │    │
│  │  │            │  │            │  │   Curl      │       │    │
│  │  │ - Depth    │  │ - Orient.  │  │ - Anti-cheat│       │    │
│  │  │ - Tempo    │  │ - Range    │  │ - Form      │       │    │
│  │  │ - ROM      │  │            │  │             │       │    │
│  │  └─────┬──────┘  └─────┬──────┘  └──────┬──────┘       │    │
│  │        │               │                │              │    │
│  │        └───────────────┼────────────────┘              │    │
│  │                        │                                │    │
│  │  ┌─────────────────────▼──────────────────┐            │    │
│  │  │     _calculateAngle()                   │            │    │
│  │  │  (Geometric angle computation)          │            │    │
│  │  └─────────────────────────────────────────┘            │    │
│  │                                                         │    │
│  │  ┌──────────────────────────────────────────┐          │    │
│  │  │  State Machine Logic                     │          │    │
│  │  │  - "up" / "down" / "start"              │          │    │
│  │  │  - Rep counting                          │          │    │
│  │  │  - Mistake tracking                      │          │    │
│  │  └──────────────────────────────────────────┘          │    │
│  └─────────────────────────────────────────────────────────┘    │
│            │                                                    │
│  ┌─────────▼─────────────────────────────────────────────┐     │
│  │              DATA LAYER                               │     │
│  ├───────────────────────────────────────────────────────┤     │
│  │                                                        │     │
│  │  ┌──────────────────┐    ┌─────────────────────┐     │     │
│  │  │ Camera Pipeline  │    │ Pose Detection      │     │     │
│  │  │                  │    │                     │     │     │
│  │  │ CameraController │───▶│ ML Kit PoseDetector│     │     │
│  │  │      ▼           │    │         ▼           │     │     │
│  │  │ CameraImage      │    │  List<Pose>         │     │     │
│  │  │      ▼           │    │    (33 landmarks)   │     │     │
│  │  │ InputImage       │    │                     │     │     │
│  │  └──────────────────┘    └─────────────────────┘     │     │
│  │                                                        │     │
│  │  ┌──────────────────┐    ┌─────────────────────┐     │     │
│  │  │ Storage          │    │ Voice Feedback      │     │     │
│  │  │                  │    │                     │     │     │
│  │  │SharedPreferences │    │   FlutterTTS        │     │     │
│  │  │  (JSON history)  │    │   (Audio cues)      │     │     │
│  │  └──────────────────┘    └─────────────────────┘     │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    REAL-TIME PROCESSING LOOP                     │
│                         (~30 FPS)                                │
└─────────────────────────────────────────────────────────────────┘

    ┌────────────┐
    │   CAMERA   │
    │   Device   │
    └──────┬─────┘
           │
           │ Raw frame bytes (NV21/BGRA8888)
           │
           ▼
    ┌──────────────────┐
    │ _processCameraImage│
    │                   │
    │ 1. Throttle check │
    │ 2. Format convert │
    └──────┬────────────┘
           │
           │ InputImage
           │
           ▼
    ┌──────────────────┐
    │  PoseDetector    │
    │   processImage() │
    │                  │
    │  ML Kit model    │
    │  (On-device AI)  │
    └──────┬───────────┘
           │
           │ List<Pose> (33 landmarks)
           │
           ▼
    ┌──────────────────────┐
    │  Exercise Analyzer   │
    │                      │
    │  switch(exerciseType)│
    │    case squat:       │
    │    case pushUp:      │
    │    ...               │
    └──────┬───────────────┘
           │
           │ Updated state variables
           │ (_reps, _mistakes, _feedback)
           │
           ├──────────────┬─────────────────┬────────────────┐
           │              │                 │                │
           ▼              ▼                 ▼                ▼
    ┌──────────┐  ┌─────────────┐  ┌──────────┐   ┌────────────┐
    │PosePainter│  │  _feedback  │  │FlutterTTS│   │SharedPrefs│
    │ (Skeleton)│  │   (Text)    │  │ (Voice)  │   │(On finish) │
    └─────┬─────┘  └──────┬──────┘  └────┬─────┘   └────────────┘
          │               │              │
          └───────────────┼──────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │  setState()  │
                   │              │
                   │  UI Update   │
                   └──────────────┘
                          │
                          │ Screen refresh
                          │
                          ▼
                   ┌──────────────┐
                   │   Display    │
                   │              │
                   │ - Camera feed│
                   │ - Skeleton   │
                   │ - Stats      │
                   │ - Feedback   │
                   └──────────────┘
```

## Exercise Analysis State Machines

### Squat State Machine

```
                    START
                      │
                      │ User enters frame
                      ▼
                 ┌─────────┐
           ┌────▶│   UP    │◀────┐
           │     │ (>160°) │     │
           │     └────┬────┘     │
           │          │          │
           │    angle < 140°     │ angle > 160°
           │          │          │
           │          ▼          │
           │     ┌────────┐      │
           │     │  DOWN  │──────┘
           │     │ (<140°)│
           │     └────┬───┘
           │          │
           │    Track minAngle
           │          │
           └──────────┘
                (Check quality:
                 - Depth (< 90°)
                 - Tempo (> 1.5s)
                 → Count rep or mistake)
```

### Push-Up State Machine

```
                    START
                      │
                      │ Orientation check
                      ▼
              ┌───────────────┐
              │  Horizontal?  │
              └───┬───────┬───┘
                  │       │
             Yes  │       │ No
                  │       └──▶ "GET ON FLOOR"
                  ▼
             ┌─────────┐
        ┌───▶│   UP    │◀────┐
        │    │ (>160°) │     │
        │    └────┬────┘     │
        │         │          │
        │   angle < 90°      │ angle > 160°
        │         │          │
        │         ▼          │
        │    ┌────────┐      │
        │    │  DOWN  │──────┘
        │    │ (<90°) │
        │    └────────┘
        │         │
        └─────────┘
           (Count rep)
```

### Bicep Curl State Machine

```
                    START
                      │
                      ▼
                 ┌─────────┐
            ┌───▶│  DOWN   │◀────┐
            │    │ (>160°) │     │
            │    └────┬────┘     │
            │         │          │
            │    Record          │ angle > 160°
            │    shoulderX       │
            │         │          │
            │   angle < 50°      │
            │         ▼          │
            │    ┌────────┐      │
            │    │   UP   │──────┘
            │    │ (<50°) │
            │    └────┬───┘
            │         │
            │    Check swing
            │    (shoulderX movement)
            │         │
            └─────────┘
                (Count rep if no swing,
                 else count mistake)
```

## Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      WorkoutScreen                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  State Variables:                                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ _reps: 0                                                  │  │
│  │ _mistakes: 0                                              │  │
│  │ _feedback: "Get Ready"                                    │  │
│  │ _stage: "start"                                           │  │
│  │ _isDetecting: false                                       │  │
│  │ _isPaused: false                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Controllers:                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │CameraController PoseDetector   │  │  FlutterTts  │         │
│  │              │  │              │  │              │         │
│  │ - initialize │  │ - processImage│  │ - speak()    │         │
│  │ - startStream│  │ - close()    │  │ - stop()     │         │
│  │ - dispose()  │  │              │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  Custom Widgets:                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Stack:                                                    │  │
│  │   - CameraPreview (background)                           │  │
│  │   - CustomPaint (PosePainter - skeleton overlay)         │  │
│  │   - Bottom panel (reps, mistakes, feedback)              │  │
│  │   - Pause overlay (conditional)                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## ML Kit Pose Landmarks Map

```
                    0 (nose)
                   /│\
                  / │ \
        1,2 (eyes)  │  3,4 (ears)
                    │
                    │
              ┌─────┴─────┐
              │           │
          5 (left)    6 (right)
         shoulder    shoulder
              │           │
              │           │
          7 (left)    8 (right)
           elbow       elbow
              │           │
              │           │
          9 (left)   10 (right)
           wrist       wrist
              │           │
         ┌────┴───────────┴────┐
         │                     │
     11 (left)            12 (right)
        hip                   hip
         │                     │
         │                     │
     13 (left)            14 (right)
        knee                  knee
         │                     │
         │                     │
     15 (left)            16 (right)
       ankle                 ankle
         │                     │
     ┌───┴───┬───────────┬────┴───┐
     │       │           │        │
   heel    index       heel     index
  (29-30) (19-20)    (31-32)  (23-24)

Total: 33 landmarks
Each has: x, y, z, likelihood
```

## Performance Optimization Strategy

```
┌──────────────────────────────────────────────┐
│         Performance Bottlenecks              │
├──────────────────────────────────────────────┤
│                                              │
│  1. Camera Frame Rate (30-60 FPS)           │
│     ▼                                        │
│     Solution: Use ResolutionPreset.low      │
│               (~240p instead of 1080p)      │
│                                              │
│  2. ML Kit Inference (~100ms per frame)     │
│     ▼                                        │
│     Solution: Throttle with _isDetecting    │
│               flag (skip frames if busy)    │
│                                              │
│  3. UI Redraws (every setState)             │
│     ▼                                        │
│     Solution: Only setState when needed     │
│               Use const constructors        │
│                                              │
│  4. Memory Usage (image buffers)            │
│     ▼                                        │
│     Solution: Process in-place              │
│               Dispose controllers properly  │
│                                              │
│  5. Voice Spam (TTS calls)                  │
│     ▼                                        │
│     Solution: 2-second throttle             │
│               Track _lastSpeech time        │
│                                              │
└──────────────────────────────────────────────┘

Result: Smooth 30 FPS on mid-range devices
```

## Storage Schema

```
┌─────────────────────────────────────────────┐
│     SharedPreferences Structure             │
├─────────────────────────────────────────────┤
│                                             │
│  Key: "workout_history"                    │
│  Type: String (JSON array)                 │
│                                             │
│  Value:                                     │
│  [                                          │
│    {                                        │
│      "type": "Squats",                     │
│      "reps": 15,                           │
│      "mistakes": 2,                        │
│      "date": "Dec 3, 14:30"                │
│    },                                       │
│    {                                        │
│      "type": "Push-Ups",                   │
│      "reps": 20,                           │
│      "mistakes": 1,                        │
│      "date": "Dec 3, 15:00"                │
│    },                                       │
│    ...                                      │
│  ]                                          │
│                                             │
│  Operations:                                │
│  - Load: json.decode(historyJson)          │
│  - Save: json.encode(history)              │
│  - Display: Last 5 entries on MenuScreen   │
│                                             │
└─────────────────────────────────────────────┘
```

## Color Coding System

```
┌──────────────────────────────────────────────┐
│          Feedback Color Scheme               │
├──────────────────────────────────────────────┤
│                                              │
│  🟢 GREEN (greenAccent)                      │
│     - "PERFECT!"                             │
│     - "GOOD!"                                │
│     - Success state                          │
│                                              │
│  🔵 BLUE (blueAccent)                        │
│     - "UP!"                                  │
│     - "PUSH UP!"                             │
│     - Instructional state                    │
│                                              │
│  🟠 ORANGE (orangeAccent)                    │
│     - "LOWER..."                             │
│     - "GET ON FLOOR"                         │
│     - Warning state                          │
│                                              │
│  🔴 RED (redAccent)                          │
│     - "TOO FAST!"                            │
│     - "TOO SHALLOW!"                         │
│     - "DON'T SWING!"                         │
│     - Error state                            │
│                                              │
│  ⚪ WHITE                                     │
│     - "Get Ready"                            │
│     - "Not visible"                          │
│     - Neutral state                          │
│                                              │
└──────────────────────────────────────────────┘
```

## Navigation Flow

```
┌──────────────┐
│ MenuScreen   │
│              │
│ - Squats btn │──┐
│ - PushUp btn │──┤
│ - Press btn  │──┼─▶┌───────────────┐
│ - Curl btn   │──┘  │ WorkoutScreen │
│ - History    │     │               │
└──────────────┘     │ - Live camera │
                     │ - Analysis    │
                     │               │
                     │ [FINISH] ─────┼─▶┌───────────────┐
                     └───────────────┘  │ SummaryScreen │
                                        │               │
                                        │ - Stats       │
                                        │ - Accuracy    │
                                        │               │
                                        │ [BACK TO MENU]│
                                        └───────┬───────┘
                                                │
                                                ▼
                                        ┌──────────────┐
                                        │ MenuScreen   │
                                        │ (refreshed)  │
                                        └──────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────┐
│         Error Handling Strategy             │
├─────────────────────────────────────────────┤
│                                             │
│  Camera Initialization Error                │
│    try {                                    │
│      await _controller!.initialize();       │
│    } catch (e) {                            │
│      debugPrint("Camera error: $e");        │
│    }                                        │
│                                             │
│  Pose Detection Error                       │
│    try {                                    │
│      poses = await processImage();          │
│    } catch (e) {                            │
│      debugPrint("Error: $e");               │
│    } finally {                              │
│      _isDetecting = false;  // Always reset │
│    }                                        │
│                                             │
│  Null Safety Checks                         │
│    if (hip == null || knee == null) return; │
│    if (hip.likelihood < 0.5) return;        │
│                                             │
│  Graceful Degradation                       │
│    if (poses.isEmpty) {                     │
│      _feedback = "Not visible";             │
│      _customPaint = null;  // Hide skeleton │
│    }                                        │
│                                             │
└─────────────────────────────────────────────┘
```

This architecture supports:
- **Real-time performance** (30 FPS)
- **Modular exercise logic** (easy to add new exercises)
- **Robust error handling** (graceful degradation)
- **Responsive UI** (async processing)
- **Persistent storage** (workout history)
