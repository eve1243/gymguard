@echo off
echo ===================================================
echo              GymGuard Application
echo ===================================================
echo.

cd /d "C:\Users\Everl\StudioProjects\gymguard"
if %errorlevel% neq 0 (
    echo ERROR: Could not change to project directory!
    pause
    exit /b 1
)

echo Current directory: %CD%
echo.
echo OPTIMIZATIONS ACTIVE:
echo ✓ Higher camera resolution for better motion detection
echo ✓ Frame skipping for smooth Android performance
echo ✓ Optimized pose detection thresholds
echo ✓ Enhanced error handling and validation
echo ✓ Java 17 compatibility ensured
echo.

echo Starting GymGuard...
call flutter run
if %errorlevel% neq 0 (
    echo Failed to start GymGuard!
    echo.
    echo Common solutions:
    echo - Ensure your device is connected and USB debugging is enabled
    echo - Try running: flutter clean
    echo - Check camera permissions on your device
    pause
    exit /b %errorlevel%
)

echo.
echo GymGuard started successfully!
pause
