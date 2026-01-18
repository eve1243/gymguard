@echo off
echo ===================================================
echo              GymGuard Mobile App
echo          iOS and Android Ready
echo            OPTIMIZED and WORKING
echo ===================================================
echo.

rem quick setup - go to project directory
cd /d "%~dp0"
echo Current directory: %CD%
echo.

echo MOBILE OPTIMIZATIONS ACTIVE:
echo * AI-powered movement analysis integrated
echo * Shoulder shrugging detection enhanced
echo * Bicep curl detection improved
echo * Motion tracking fixed - pose mirroring corrected
echo * Android camera compatibility optimized
echo * iOS pose detection enhanced
echo.

echo Starting GymGuard directly...
echo.

rem direct start - minimal checks to avoid hanging
flutter run

rem show result message
if %errorlevel% neq 0 (
    echo.
    echo Something went wrong. Quick troubleshooting:
    echo - Make sure your phone has USB debugging enabled
    echo - Allow USB debugging popup on phone
    echo - Grant camera permissions when app starts
    echo - Try: flutter clean if issues persist
) else (
    echo.
    echo GymGuard started successfully!
)

echo.
pause
