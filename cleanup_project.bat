@echo off
echo ========================================
echo     GymGuard Project Cleanup Script
echo ========================================
echo.
echo This script will safely remove unnecessary files and folders
echo to make your project cleaner and more readable.
echo.
echo WHAT WILL BE REMOVED:
echo ❌ gym_guard_app/ (duplicate folder with old code)
echo ❌ python_scripts/ (unused Python examples)
echo ❌ build/ (build cache - will be regenerated)
echo ❌ ios/main.dart (misplaced file)
echo ❌ windows/, linux/, macos/, web/ (unused platforms - only iOS + Android needed)
echo ❌ Multiple documentation files (keeping README.md)
echo ❌ Setup scripts (new.sh, prepare_models.py)
echo ❌ Extra batch files (keeping optimized version)
echo.
echo WHAT WILL BE KEPT:
echo ✓ lib/ (your main Flutter code)
echo ✓ android/ (Android platform files)
echo ✓ ios/ (iOS platform files - except misplaced main.dart)
echo ✓ test/ (unit tests)
echo ✓ README.md (main documentation)
echo ✓ pubspec.yaml (dependencies)
echo ✓ Essential configuration files
echo.
set /p confirm="Do you want to proceed? (y/N): "
if /i "%confirm%"=="y" (
    echo.
    echo Starting cleanup...

    echo [1/8] Removing duplicate gym_guard_app folder...
    if exist "gym_guard_app" (
        rmdir /s /q "gym_guard_app"
        echo ✓ Removed gym_guard_app/
    )

    echo [2/8] Removing Python scripts...
    if exist "python_scripts" (
        rmdir /s /q "python_scripts"
        echo ✓ Removed python_scripts/
    )

    echo [3/8] Removing build cache...
    if exist "build" (
        rmdir /s /q "build"
        echo ✓ Removed build/
    )

    echo [4/8] Removing misplaced iOS file...
    if exist "ios\main.dart" (
        del "ios\main.dart"
        echo ✓ Removed ios/main.dart
    )

    echo [5/8] Removing excess documentation...
    if exist "INSTALLATION.md" del "INSTALLATION.md"
    if exist "PYTHON_INSTALLATION.md" del "PYTHON_INSTALLATION.md"
    if exist "POSE_ESTIMATION_READY.md" del "POSE_ESTIMATION_READY.md"
    if exist "SETUP_SUMMARY.md" del "SETUP_SUMMARY.md"
    if exist "NEXT_STEPS.md" del "NEXT_STEPS.md"
    if exist "QUICKSTART.md" del "QUICKSTART.md"
    echo ✓ Removed excess documentation files

    echo [6/8] Removing setup scripts...
    if exist "new.sh" del "new.sh"
    if exist "prepare_models.py" del "prepare_models.py"
    echo ✓ Removed setup scripts

    echo [7/9] Removing unused platform folders...
    if exist "windows" (
        rmdir /s /q "windows"
        echo ✓ Removed windows/
    )
    if exist "linux" (
        rmdir /s /q "linux"
        echo ✓ Removed linux/
    )
    if exist "macos" (
        rmdir /s /q "macos"
        echo ✓ Removed macos/
    )
    if exist "web" (
        rmdir /s /q "web"
        echo ✓ Removed web/
    )

    echo [8/9] Consolidating batch files...
    if exist "run_flutter_fixed.bat" del "run_flutter_fixed.bat"
    if exist "run_java17_forced.bat" del "run_java17_forced.bat"
    if exist "run_updated_versions.bat" del "run_updated_versions.bat"
    echo ✓ Removed old batch files (keeping optimized version)

    echo [9/9] Creating clean project structure summary...
    echo # GymGuard Project Structure > PROJECT_STRUCTURE.md
    echo. >> PROJECT_STRUCTURE.md
    echo ## Core Files: >> PROJECT_STRUCTURE.md
    echo - lib/main.dart (Main Flutter application) >> PROJECT_STRUCTURE.md
    echo - pubspec.yaml (Dependencies) >> PROJECT_STRUCTURE.md
    echo - README.md (Documentation) >> PROJECT_STRUCTURE.md
    echo. >> PROJECT_STRUCTURE.md
    echo ## Platform Files: >> PROJECT_STRUCTURE.md
    echo - android/ (Android configuration) >> PROJECT_STRUCTURE.md
    echo - ios/ (iOS configuration) >> PROJECT_STRUCTURE.md
    echo. >> PROJECT_STRUCTURE.md
    echo ## Development Files: >> PROJECT_STRUCTURE.md
    echo - test/ (Unit tests) >> PROJECT_STRUCTURE.md
    echo - analysis_options.yaml (Dart analysis) >> PROJECT_STRUCTURE.md
    echo - run_motion_optimized.bat (Launch script) >> PROJECT_STRUCTURE.md
    echo ✓ Created PROJECT_STRUCTURE.md

    echo.
    echo ========================================
    echo ✅ CLEANUP COMPLETED SUCCESSFULLY!
    echo ========================================
    echo.
    echo Your project is now much cleaner and more readable.
    echo The main application is in lib/main.dart
    echo Use run_motion_optimized.bat to launch the app
    echo.
    echo Project size reduced and structure simplified!

) else (
    echo.
    echo Cleanup cancelled. No files were removed.
)
echo.
pause
