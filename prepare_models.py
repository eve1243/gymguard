"""
Pose Detection Model Preparation Script
This script helps download and prepare TensorFlow Lite models for pose estimation
Supports both TensorFlow Hub models (MoveNet) and MediaPipe models
"""

import os
import urllib.request
import tensorflow as tf
import numpy as np
import mediapipe as mp

def download_movenet_model(output_dir='models'):
    """
    Download MoveNet TensorFlow Lite model
    MoveNet is recommended for real-time pose estimation on mobile devices
    """
    os.makedirs(output_dir, exist_ok=True)
    
    # MoveNet Lightning (faster, less accurate)
    movenet_lightning_url = 'https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/int8/4?lite-format=tflite'
    
    # MoveNet Thunder (slower, more accurate)
    movenet_thunder_url = 'https://tfhub.dev/google/lite-model/movenet/singlepose/thunder/tflite/int8/4?lite-format=tflite'
    
    print("Downloading MoveNet Lightning model...")
    lightning_path = os.path.join(output_dir, 'movenet_lightning.tflite')
    try:
        urllib.request.urlretrieve(movenet_lightning_url, lightning_path)
        print(f"✓ MoveNet Lightning saved to {lightning_path}")
    except Exception as e:
        print(f"✗ Error downloading Lightning model: {e}")
    
    print("\nDownloading MoveNet Thunder model...")
    thunder_path = os.path.join(output_dir, 'movenet_thunder.tflite')
    try:
        urllib.request.urlretrieve(movenet_thunder_url, thunder_path)
        print(f"✓ MoveNet Thunder saved to {thunder_path}")
    except Exception as e:
        print(f"✗ Error downloading Thunder model: {e}")
    
    return lightning_path, thunder_path

def test_model(model_path):
    """
    Test the TensorFlow Lite model to ensure it works correctly
    """
    print(f"\nTesting model: {model_path}")
    
    try:
        # Load the TFLite model
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        
        # Get input and output details
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print("\n--- Model Information ---")
        print(f"Input shape: {input_details[0]['shape']}")
        print(f"Input type: {input_details[0]['dtype']}")
        print(f"Output shape: {output_details[0]['shape']}")
        print(f"Output type: {output_details[0]['dtype']}")
        
        # Test with dummy input
        input_shape = input_details[0]['shape']
        dummy_input = np.zeros(input_shape, dtype=input_details[0]['dtype'])
        
        interpreter.set_tensor(input_details[0]['index'], dummy_input)
        interpreter.invoke()
        
        output = interpreter.get_tensor(output_details[0]['index'])
        print(f"\n✓ Model tested successfully!")
        print(f"Output contains {output.shape[-1]} keypoints")
        
        return True
    except Exception as e:
        print(f"✗ Error testing model: {e}")
        return False

def create_model_info():
    """
    Create a JSON file with model information for Flutter app
    """
    info = {
        "models": [
            {
                "name": "MoveNet Lightning",
                "file": "movenet_lightning.tflite",
                "description": "Fast pose estimation, good for real-time processing",
                "input_size": [192, 192],
                "keypoints": 17
            },
            {
                "name": "MoveNet Thunder",
                "file": "movenet_thunder.tflite",
                "description": "More accurate pose estimation, slightly slower",
                "input_size": [256, 256],
                "keypoints": 17
            }
        ],
        "keypoint_names": [
            "nose", "left_eye", "right_eye", "left_ear", "right_ear",
            "left_shoulder", "right_shoulder", "left_elbow", "right_elbow",
            "left_wrist", "right_wrist", "left_hip", "right_hip",
            "left_knee", "right_knee", "left_ankle", "right_ankle"
        ]
    }
    
    import json
    with open('models/model_info.json', 'w') as f:
        json.dump(info, f, indent=2)
    
    print("\n✓ Model info saved to models/model_info.json")

def test_mediapipe():
    """Test MediaPipe Pose detection with example"""
    print("\n=== Testing MediaPipe Pose ===")
    try:
        mp_pose = mp.solutions.pose
        pose = mp_pose.Pose(
            static_image_mode=True,
            model_complexity=2,
            enable_segmentation=False,
            min_detection_confidence=0.5
        )
        print("✓ MediaPipe Pose initialized successfully")
        print(f"✓ MediaPipe version: {mp.__version__}")
        print("✓ Ready for real-time pose detection")
        pose.close()
        return True
    except Exception as e:
        print(f"✗ MediaPipe error: {e}")
        return False

def main():
    print("=== GymGuard Pose Detection Model Setup ===\n")
    print(f"Python Version: 3.12.10")
    print(f"TensorFlow Version: {tf.__version__}")
    print(f"MediaPipe Version: {mp.__version__}\n")
    
    # Test MediaPipe
    mediapipe_ok = test_mediapipe()
    
    # Download MoveNet models (alternative)
    print("\n=== Downloading MoveNet Models (TensorFlow Hub) ===")
    lightning_path, thunder_path = download_movenet_model()
    
    # Test models
    if os.path.exists(lightning_path):
        test_model(lightning_path)
    
    if os.path.exists(thunder_path):
        test_model(thunder_path)
    
    # Create model info
    create_model_info()
    
    print("\n=== Setup Complete ===")
    if mediapipe_ok:
        print("\n✅ MediaPipe is ready! This is the recommended option for GymGuard.")
        print("   MediaPipe provides excellent pose detection without separate .tflite files.")
    print("\n📋 Available Options:")
    print("   Option 1 (Recommended): Use MediaPipe directly in Python backend")
    print("   Option 2: Use MoveNet .tflite models in Flutter app")
    print("\nNext steps:")
    print("1. For MediaPipe: See examples in python_scripts/mediapipe_example.py")
    print("2. For MoveNet: Copy .tflite files from 'models/' to 'gym_guard_app/assets/models/'")
    print("3. Update pubspec.yaml to include the assets")
    print("4. Implement pose detection in pose_detector.dart")

if __name__ == "__main__":
    main()
