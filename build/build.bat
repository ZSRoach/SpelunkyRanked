@echo off
REM Build script for Windows
REM Requires Python 3.10+ installed (not Windows Store version)

echo Building S2Ranked Bridge...
python build_bridge.py

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build complete! Check the executables folder.
pause
