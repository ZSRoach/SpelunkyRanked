@echo off
REM Build script for Windows
REM Requires uv installed

echo Building S2Ranked Bridge...
uv run build_bridge.py

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build complete! Check the dist folder.
pause
