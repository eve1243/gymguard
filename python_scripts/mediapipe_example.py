"""
MediaPipe Pose Detection Beispiel für GymGuard
Zeigt wie man MediaPipe für Echtzeit-Pose-Erkennung verwendet
"""

import cv2
import mediapipe as mp
import numpy as np

# MediaPipe Setup
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

def process_image(image_path):
    """Verarbeite ein einzelnes Bild"""
    with mp_pose.Pose(
        static_image_mode=True,
        model_complexity=2,
        enable_segmentation=False,
        min_detection_confidence=0.5
    ) as pose:
        
        # Bild laden
        image = cv2.imread(image_path)
        if image is None:
            print(f"❌ Konnte Bild nicht laden: {image_path}")
            return
        
        # BGR zu RGB konvertieren
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Pose Detection
        results = pose.process(image_rgb)
        
        # Ergebnisse zeichnen
        if results.pose_landmarks:
            print("✅ Pose erkannt!")
            
            # Landmarks auf Bild zeichnen
            annotated_image = image.copy()
            mp_drawing.draw_landmarks(
                annotated_image,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS,
                landmark_drawing_spec=mp_drawing_styles.get_default_pose_landmarks_style()
            )
            
            # Landmarks ausgeben
            print("\n📍 Erkannte Keypoints:")
            for idx, landmark in enumerate(results.pose_landmarks.landmark):
                print(f"  {mp_pose.PoseLandmark(idx).name}: "
                      f"x={landmark.x:.3f}, y={landmark.y:.3f}, "
                      f"z={landmark.z:.3f}, visibility={landmark.visibility:.3f}")
            
            # Bild speichern
            output_path = image_path.replace('.', '_annotated.')
            cv2.imwrite(output_path, annotated_image)
            print(f"\n💾 Annotiertes Bild gespeichert: {output_path}")
            
            return results.pose_landmarks
        else:
            print("❌ Keine Pose erkannt")
            return None

def process_webcam():
    """Echtzeit-Pose-Erkennung mit Webcam"""
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("❌ Konnte Webcam nicht öffnen")
        return
    
    print("\n📹 Starte Webcam... (Drücke 'q' zum Beenden)")
    
    with mp_pose.Pose(
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
        model_complexity=1  # 0=lite, 1=full, 2=heavy
    ) as pose:
        
        while cap.isOpened():
            success, frame = cap.read()
            if not success:
                print("❌ Konnte Frame nicht lesen")
                break
            
            # BGR zu RGB
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_rgb.flags.writeable = False
            
            # Pose Detection
            results = pose.process(frame_rgb)
            
            # Frame wieder beschreibbar machen
            frame_rgb.flags.writeable = True
            frame = cv2.cvtColor(frame_rgb, cv2.COLOR_RGB2BGR)
            
            # Pose zeichnen
            if results.pose_landmarks:
                mp_drawing.draw_landmarks(
                    frame,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    landmark_drawing_spec=mp_drawing_styles.get_default_pose_landmarks_style()
                )
                
                # Status anzeigen
                cv2.putText(frame, 'Pose erkannt', (10, 30),
                           cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            else:
                cv2.putText(frame, 'Keine Pose', (10, 30),
                           cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
            
            # Frame anzeigen
            cv2.imshow('GymGuard - MediaPipe Pose Detection', frame)
            
            # Beenden mit 'q'
            if cv2.waitKey(5) & 0xFF == ord('q'):
                break
    
    cap.release()
    cv2.destroyAllWindows()
    print("✅ Webcam beendet")

def calculate_angle(a, b, c):
    """
    Berechne Winkel zwischen drei Punkten
    Nützlich für Übungserkennung (z.B. Armbeugung)
    
    Args:
        a, b, c: Landmarks (mit x, y Koordinaten)
    Returns:
        Winkel in Grad
    """
    a = np.array([a.x, a.y])
    b = np.array([b.x, b.y])
    c = np.array([c.x, c.y])
    
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - \
              np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    
    if angle > 180.0:
        angle = 360 - angle
    
    return angle

def analyze_squat(landmarks):
    """
    Beispiel: Kniebeuge-Analyse
    Berechnet Kniewinkel
    """
    # Keypoints für linkes Bein: Hüfte, Knie, Knöchel
    left_hip = landmarks.landmark[mp_pose.PoseLandmark.LEFT_HIP]
    left_knee = landmarks.landmark[mp_pose.PoseLandmark.LEFT_KNEE]
    left_ankle = landmarks.landmark[mp_pose.PoseLandmark.LEFT_ANKLE]
    
    # Winkel berechnen
    angle = calculate_angle(left_hip, left_knee, left_ankle)
    
    # Feedback
    if angle > 160:
        status = "Stehend"
    elif angle > 90:
        status = "Teilweise gebeugt"
    else:
        status = "Tief in der Hocke"
    
    return angle, status

def main():
    print("=== GymGuard MediaPipe Pose Detection ===\n")
    print(f"MediaPipe Version: {mp.__version__}")
    print(f"OpenCV Version: {cv2.__version__}\n")
    
    print("Optionen:")
    print("1. Webcam-Demo (Echtzeit)")
    print("2. Bild verarbeiten")
    print("3. Beenden")
    
    choice = input("\nWähle Option (1-3): ").strip()
    
    if choice == "1":
        process_webcam()
    elif choice == "2":
        image_path = input("Bildpfad eingeben: ").strip()
        landmarks = process_image(image_path)
        
        if landmarks:
            # Beispiel: Squat-Analyse
            angle, status = analyze_squat(landmarks)
            print(f"\n🏋️ Squat-Analyse:")
            print(f"   Kniewinkel: {angle:.1f}°")
            print(f"   Status: {status}")
    else:
        print("👋 Auf Wiedersehen!")

if __name__ == "__main__":
    main()
