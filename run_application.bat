@echo off
echo ===================================================
echo              GymGuard Mobile App
echo          AI-Powered Fitness Trainer
echo ===================================================
echo.

cd /d "%~dp0"

echo 📱 Starting GymGuard on Android device...
echo.

flutter run

if %errorlevel% neq 0 (
    echo.
    echo ❌ Failed to start GymGuard
    echo.
    echo Quick checklist:
    echo - USB debugging enabled on phone?
    echo - Phone connected and unlocked?
    echo - Allow USB debugging popup accepted?
    echo.
)

echo.
pause

