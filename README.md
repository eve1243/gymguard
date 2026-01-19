# GymGuard - Intelligenter Fitness-Trainer 🏋️‍♂️

**GymGuard** ist eine plattformübergreifende mobile Anwendung (Android/iOS), die als intelligenter, Echtzeit-Personal-Trainer fungiert.

Im Gegensatz zu herkömmlichen Fitness-Trackern verwendet diese App **Computer Vision (Google ML Kit)**, um Sie beim Training über die Smartphone-Kamera zu "beobachten". Sie analysiert Ihre Biomechanik in Echtzeit, um Wiederholungen zu zählen, die Körperhaltung zu korrigieren und ein sicheres Bewegungstempo zu gewährleisten - alles wird lokal auf Ihrem Gerät verarbeitet für maximalen Datenschutz.

* Funktioniert für **jeden Benutzer** auf **iOS und Android**!

---

## 📱 Hauptfunktionen

### ✅ Intelligente Übungsanalyse:
* **Squats (Kniebeugen):** Überprüfung der Tiefe (Bewegungsumfang) und sicheres Tempo
* **Push-Ups (Liegestütze):** Intelligente Erkennung, die nur zählt, wenn Sie sich in horizontaler Position befinden
* **Bicep Curls:** Verhindert "Schwingen", gewährleistet kontrollierte Hubgeschwindigkeit und **erkennt Schulterheben**
* **Overhead Press (Schulterdrücken):** Überprüft vollständige Armstreckung

### ✅ Echtzeit-Feedback:
* **Visuelles Skelett-Overlay:** Sehen Sie Ihre Körperhaltung in Echtzeit
* **Text-to-Speech Audio-Führung:** Sprachliches Coaching während des Trainings (ein-/ausschaltbar)
* **Sofortige Formkorrekturen:** Unmittelbares Feedback bei Fehlern

### ✅ Erweiterte Formerkennung:
* **Mehrpunkt-Tracking** für Schulterstabilität und ordnungsgemäße Biomechanik
* **KI-gestützte Bewegungsanalyse** für präzise Fehlererkennung
* **Anpassbare Schwellenwerte** für verschiedene Fitnesslevel

### ✅ Benutzerverwaltung:
* **Benutzerprofile:** Speichern Sie Name, Alter und Gewicht lokal
* **Trainingshistorie:** Automatische Verfolgung Ihrer Trainingseinheiten
* **Datenschutz first:** Keine Videos werden jemals hochgeladen - alles läuft auf dem Gerät

---

## 🏆 MoSCoW-Anforderungen (aus SRS_final)

### 🟢 MUSS-Kriterien (Vollständig implementiert)
- ✅ **Pose Estimation:** Erkennt Gelenkpunkte mittels Google ML Kit
- ✅ **Übungsidentifikation:** Analysiert Bodyweight-Übungen (Squat, Push-Up, Bicep Curl, Overhead Press)
- ✅ **Fehlhaltungserkennung:** Erkennt typische Probleme (Haltung, Bewegungsradius, Stabilität)
- ✅ **Trainingssteuerung:** Start, Pause und Beendigung von Trainingseinheiten
- ✅ **Wiederholungszählung:** Zählt und markiert gültige/ungültige Reps
- ✅ **Datenschutz:** Kameradaten werden NICHT gespeichert ohne Zustimmung
- ✅ **Datenverschlüsselung:** Alle Nutzerdaten werden verschlüsselt gespeichert

### 🟡 SOLL-Kriterien (Größtenteils implementiert)
- ❌ **Mehrere Kamerawinkel:** Unterstützt verschiedene Aufstellungen
- ✅ **Workout-Zusammenfassungen:** Zeigt Fehlerquote und Rep-Qualität nach dem Training
- ❌ **Hands-free Modus:** Automatische Erkennung ohne manuelle Eingaben während des Trainings

### 🔵 KANN-Kriterien (Vollständig implementiert)
- ✅ **Personalisierte Coaching-Hinweise:** Intelligentes, kontextuelles Feedback
- ✅ **Audio-Feedback (TTS):** Text-to-Speech Sprachausgabe (ein-/ausschaltbar)
- ✅ **Nutzerprofile:** Vollständige Profilsverwaltung mit sicherer Speicherung
- ✅ **Trainingsverlauf:** Detaillierte Speicherung und Anzeige der Trainingshistorie

### 🚫 Abgrenzungs-Kriterien (Bewusst NICHT implementiert)
- ❌ Keine medizinische Diagnose oder Therapieempfehlung
- ❌ Kein vollständiger Ersatz für professionelle Coaches
- ❌ Kein Ernährungsplaner oder Diet-Tracking
- ❌ Keine Integration externer Fitnessgeräte
- ❌ Keine komplexen 3D-Modellierungen
- ❌ Keine Multiplayer- oder Live-Video-Coaching-Funktionen
- ❌ Kein automatischer Muskel- oder Kraftmessalgorithmus
- ❌ Keine Speicherung von Kamerastreams ohne ausdrückliche Zustimmung

---

## 🚀 Installation & Setup

### Schnellstart für Endbenutzer

#### Voraussetzungen:
- **Android-Gerät** (API Level 21+) oder **iOS-Gerät** (iOS 11.0+)
- **Funktionsfähige Kamera**
- **Internetverbindung** für den ersten Download

#### 📱 Installation Schritt für Schritt:

**Option 1: Für Entwickler/Tester**
```bash
# Repository klonen
git clone https://github.com/eve1243/gymguard.git
cd gymguard

# Automatischer Start (Windows)
run_application.bat

# Automatischer Start (macOS/Linux)
chmod +x run_application.sh && ./run_application.sh
```

**Option 2: Manuelle Installation**
```bash
# Flutter Dependencies installieren
flutter pub get

# Auf verbundenem Gerät ausführen
flutter run
```

#### 🔧 Geräte-Setup:

**📱 Android-Vorbereitung:**
1. **Entwickleroptionen aktivieren:**
   - Gehen Sie zu Einstellungen > Über das Telefon
   - Tippen Sie 7x auf "Build-Nummer"
   - Entwickleroptionen sind nun verfügbar

2. **USB-Debugging aktivieren:**
   - Einstellungen > Entwickleroptionen
   - "USB-Debugging" aktivieren

3. **Gerät verbinden:**
   - USB-Kabel anschließen
   - "Computer vertrauen" bestätigen
   - Kameraberechtigung bei App-Start erteilen

**🍎 iOS-Vorbereitung:**
1. **Gerät verbinden:**
   - USB-Kabel anschließen
   - "Diesem Computer vertrauen" bestätigen
   - Passcode eingeben falls erforderlich

2. **Berechtigungen:**
   - Kamerazugriff bei App-Start erlauben
   - Mikrofonzugriff für TTS-Feedback erlauben

---

## 📖 Benutzerhandbuch

### 🎯 Erste Schritte:

1. **App starten** und Kameraberechtigungen erteilen
2. **Benutzerprofil erstellen:**
   - Namen eingeben
   - Alter und Gewicht angeben (optional)
   - Profil wird verschlüsselt lokal gespeichert

3. **Übung auswählen:**
   - Squats (Beine/ROM-Check)
   - Push-Ups (Brust/Smart Mode)
   - Overhead Press (Schultern)
   - Bicep Curl (Arme/Striktes Tempo)

### 🏋️‍♀️ Training durchführen:

#### Vor dem Training:
- **Handy aufstellen:** 1-2 Meter Abstand, Körper vollständig sichtbar
- **Beleuchtung prüfen:** Gute Lichtverhältnisse für optimale Erkennung
- **Platz schaffen:** Ausreichend Bewegungsraum

#### Während des Trainings:
- **Voice Control:** 🔊 Button zum Ein-/Ausschalten der Sprachführung
- **Kamera wechseln:** 📷 Button für Front-/Rückkamera
- **Pause/Resume:** ⏸️▶️ Button zum Anhalten/Fortsetzen
- **Training beenden:** "FINISH" Button für Abschluss

#### Echtzeit-Feedback:
- **Grüne Meldungen:** Perfekte Ausführung ✅
- **Gelbe Warnungen:** Kleine Korrekturen erforderlich ⚠️
- **Rote Fehler:** Wichtige Formkorrekturen nötig ❌

### 📊 Nach dem Training:
- **Automatische Zusammenfassung:** Reps, Fehlerrate, Formgenauigkeit
- **Historien-Speicherung:** Alle Daten werden sicher gespeichert
- **Fortschritt verfolgen:** Verbesserung über Zeit sichtbar

---

## 🛠️ Entwickler-Voraussetzungen

Für Entwickler, die an GymGuard arbeiten möchten:

- **Flutter SDK** (neueste stabile Version)
- **Android Studio** (mit Android SDK)
- **Xcode** (für iOS-Entwicklung, nur macOS)
- **VS Code** mit Flutter & Dart Extensions
- **Git** für Versionskontrolle

### Development Setup:
```bash
# Dependencies installieren
flutter pub get

# Code-Analyse
flutter analyze

# Tests ausführen
flutter test

# Build für Produktion
flutter build apk          # Android
flutter build ipa          # iOS
```

---

## 🔧 Fehlerbehebung

### Häufige Probleme:

**❓ "Kein Gerät gefunden"**
- USB-Debugging aktiviert? (Android)
- Computer vertraut? (iOS)
- Anderes USB-Kabel/Port versuchen

**❓ "Kamera funktioniert nicht"**
- Kameraberechtigungen erteilt?
- Andere Apps schließen, die Kamera nutzen
- Gerät neu starten

**❓ "Build-Fehler"**
```bash
flutter clean
flutter pub get
flutter run
```

**❓ "Pose Detection ungenau"**
- Bessere Beleuchtung sicherstellen
- Vollständige Sichtbarkeit des Körpers
- Stabiler Kamerawinkel

**❓ "Voice Control funktioniert nicht"**
- 🔊 Button überprüfen (blau = aktiv, grau = inaktiv)
- Lautstärke des Geräts prüfen
- Mikrofonberechtigungen kontrollieren

### Support-Ressourcen:
- **Code-Repository:** GitHub Issues für Bug-Reports
- **Dokumentation:** Inline-Code-Kommentare
- **Community:** Flutter/Dart Community für allgemeine Fragen

---

## 🔒 Datenschutz & Sicherheit

### Unsere Datenschutz-Prinzipien:
- ✅ **Lokale Verarbeitung:** Alle Analysen erfolgen auf dem Gerät
- ✅ **Keine Cloud-Uploads:** Videos/Bilder verlassen NIE das Gerät
- ✅ **Verschlüsselung:** Benutzerdaten werden verschlüsselt gespeichert
- ✅ **Minimale Daten:** Nur notwendige Informationen werden gespeichert
- ✅ **Volle Kontrolle:** Benutzer kann alle Daten jederzeit löschen

### Was wird NICHT gespeichert:
- Kamera-Streams oder Videos
- Bilder oder Screenshots
- Persönliche medizinische Daten
- Daten auf externen Servern

### Was wird lokal gespeichert:
- Benutzername (optional)
- Trainingsstatistiken
- App-Einstellungen
- Trainingshistorie (anonymisiert)

---

## 🎯 Zielgruppe

**Perfekt für:**
- **Fitness-Einsteiger:** Die korrekte Form lernen möchten
- **Erfahrene Sportler:** Die ihre Technik verfeinern wollen
- **Home-Workout Enthusiasten:** Die ohne Trainer trainieren
- **Datenschutz-bewusste Nutzer:** Die lokale Lösungen bevorzugen
- **Tech-affine Personen:** Die KI-gestütztes Fitness-Coaching erleben möchten

**Weniger geeignet für:**
- Personen mit schweren Verletzungen (medizinische Beratung erforderlich)
- Professionelle Athleten (persönlicher Trainer empfohlen)
- Nutzer ohne Smartphone/Kamera

---

## 🚀 Zukunft von GymGuard

### Geplante Verbesserungen:
- **Weitere Übungen:** Lunges, Planks, Burpees
- **Verbesserte KI:** Noch präzisere Fehlererkennung
- **Workout-Pläne:** Strukturierte Trainingsprogramme
- **Mehrsprachen-Support:** Internationale Verfügbarkeit
- **Wearables-Integration:** Herzfrequenz-Monitoring
- **Social Features:** Freunde herausfordern (optional)

### Vision:
GymGuard soll der **zugänglichste, sicherste und intelligenteste Personal Trainer** werden, der jedem ermöglicht, sicher und effektiv zu trainieren - unabhängig von Fitnessstudio-Mitgliedschaften oder teuren Personal Trainern.

---

**Entwickelt mit ❤️ für die Fitness-Community**

*Version 1.0 - Januar 2026*

