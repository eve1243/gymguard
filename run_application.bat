@echo off
echo ===================================================
echo              GymGuard Mobile App
echo          iOS and Android Ready
echo            OPTIMIZED and WORKING
echo ===================================================
echo.

cd /d "%~dp0"
echo Current directory: %CD%
echo.

REM Quick Flutter check
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo MOBILE OPTIMIZATIONS ACTIVE:
echo * AI-powered movement analysis integrated
echo * Shoulder shrugging detection enhanced
echo * Bicep curl detection improved
echo * Motion tracking fixed (pose mirroring corrected)
echo * Android camera compatibility optimized
echo * iOS pose detection enhanced
echo * Enhanced visual feedback with angle display
echo.

echo Checking connected devices...
flutter devices
echo.

echo Starting GymGuard on your mobile device...
echo (This may take a moment for the first build)
echo.

REM Simple direct run - the issue was with 'call' command
flutter run

if %errorlevel% neq 0 (
    echo.
    echo App failed to start. Common solutions:
    echo.
    echo ANDROID:
    echo - Enable USB Debugging in Developer Options
    echo - Accept "Allow USB Debugging" on phone
    echo - Try: adb kill-server ^&^& adb start-server
    echo.
    echo iOS:
    echo - Trust this computer when prompted
    echo - Ensure device is unlocked
    echo.
    echo GENERAL:
    echo - Try: flutter clean ^&^& flutter pub get
    echo - Grant camera permissions when app starts
    echo.
    pause
    exit /b %errorlevel%
)

echo.
echo ===================================================
echo          GymGuard Successfully Started!
echo ===================================================
echo.
echo Your AI-enhanced workout companion is now running!
echo.
echo Features active:
echo * Real-time pose detection
echo * AI movement quality analysis
echo * Voice coaching and feedback
echo * Exercise counting and form correction
echo.
pause
