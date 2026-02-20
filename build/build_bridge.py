#!/usr/bin/env python3
"""Build script to create the S2Ranked Bridge executable.

Run this script from a Python environment with PyInstaller installed.
On Windows, use a standard Python installation (not from Windows Store).

Usage:
    python build_bridge.py
"""

import os
import subprocess
import sys

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXECUTABLES_DIR = os.path.join(ROOT_DIR, "executables")
BUILD_DIR = os.path.dirname(os.path.abspath(__file__))


def ensure_pyinstaller():
    """Ensure PyInstaller is installed."""
    try:
        import PyInstaller
        print(f"PyInstaller version: {PyInstaller.__version__}")
    except ImportError:
        print("Installing PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])


def build_bridge():
    """Build the S2Ranked application."""
    print("\n" + "=" * 50)
    print("Building S2Ranked Application...")
    print("=" * 50)

    bridge_dir = os.path.join(ROOT_DIR, "Bridge")

    # Install Bridge dependencies
    requirements = os.path.join(bridge_dir, "requirements.txt")
    if os.path.exists(requirements):
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", requirements])

    assets_dir = os.path.join(bridge_dir, "assets")
    icon_path = os.path.join(assets_dir, "appicon.ico")

    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--name", "S2Ranked",
        "--onedir",
        "--noconsole",
        "--icon", icon_path,
        "--add-data", f"{assets_dir}{os.pathsep}assets",
        "--distpath", EXECUTABLES_DIR,
        "--workpath", os.path.join(BUILD_DIR, "bridge"),
        "--specpath", BUILD_DIR,
        "--clean",
        "--noconfirm",
        # Hidden imports for PySide6 and socketio
        "--hidden-import", "PySide6.QtCore",
        "--hidden-import", "PySide6.QtGui",
        "--hidden-import", "PySide6.QtWidgets",
        "--hidden-import", "socketio",
        "--hidden-import", "engineio",
        "--hidden-import", "engineio.async_drivers.threading",
        "--hidden-import", "websocket",
        os.path.join(bridge_dir, "app.py"),
    ]

    subprocess.check_call(cmd, cwd=bridge_dir)

    # Create firewall setup batch file in the output directory
    setup_bat_path = os.path.join(EXECUTABLES_DIR, "S2Ranked", "setup.bat")
    setup_bat_content = (
        '@echo off\n'
        '\n'
        'REM -----------------------------------------------------------------------\n'
        'REM S2Ranked Bridge - Firewall Setup\n'
        'REM Run this once as Administrator to allow the Bridge app to communicate\n'
        'REM with the game. Required for matchmaking to work correctly.\n'
        'REM -----------------------------------------------------------------------\n'
        '\n'
        'REM Check for administrator privileges -- required by netsh\n'
        'net session >nul 2>&1\n'
        'if %errorlevel% neq 0 (\n'
        '    echo Please right-click this file and select "Run as administrator"\n'
        '    pause\n'
        '    exit /b 1\n'
        ')\n'
        '\n'
        'REM Remove ALL existing firewall rules for S2Ranked.exe regardless of their\n'
        'REM name. This is important because Windows may have auto-created a BLOCK rule\n'
        'REM the first time the app ran (from the "Allow access?" security dialog).\n'
        'REM Block rules take precedence over allow rules, so they must be removed first.\n'
        'netsh advfirewall firewall delete rule name=all program="%~dp0S2Ranked.exe" >nul 2>&1\n'
        '\n'
        'REM Also remove our named port rule from any previous run of this script.\n'
        'netsh advfirewall firewall delete rule name="S2Ranked Bridge UDP Port" >nul 2>&1\n'
        '\n'
        'REM Allow all inbound TCP traffic to the Bridge executable on all network\n'
        'REM profiles (domain, private, and public). Required for server communication.\n'
        'netsh advfirewall firewall add rule name="S2Ranked Bridge TCP" dir=in action=allow program="%~dp0S2Ranked.exe" protocol=tcp profile=any enable=yes\n'
        '\n'
        'REM Allow all inbound UDP traffic to the Bridge executable on all network profiles.\n'
        'netsh advfirewall firewall add rule name="S2Ranked Bridge UDP" dir=in action=allow program="%~dp0S2Ranked.exe" protocol=udp profile=any enable=yes\n'
        '\n'
        'REM Allow inbound UDP on port 21588 specifically.\n'
        'REM This is the port the Bridge listens on for messages from the game.\n'
        'REM This port-based rule does not depend on the executable path, so it\n'
        'REM serves as a reliable fallback if the program-based rules above fail to match.\n'
        'netsh advfirewall firewall add rule name="S2Ranked Bridge UDP Port" dir=in action=allow protocol=udp localport=21588 profile=any\n'
        '\n'
        'echo Firewall rules added successfully.\n'
        'pause\n'
    )
    with open(setup_bat_path, "w") as f:
        f.write(setup_bat_content)
    print(f"Created setup.bat at: {setup_bat_path}")

    print("Bridge build complete!")


def main():
    print("S2Ranked - Build Script")
    print("=" * 50)

    # Create output directories
    os.makedirs(EXECUTABLES_DIR, exist_ok=True)

    ensure_pyinstaller()

    try:
        build_bridge()
    except subprocess.CalledProcessError as e:
        print(f"\nBuild failed with error: {e}")
        sys.exit(1)

    print("\n" + "=" * 50)
    print("BUILD COMPLETE!")
    print("=" * 50)
    print(f"\nExecutable is in: {EXECUTABLES_DIR}")
    print("  - S2Ranked/S2Ranked(.exe)")


if __name__ == "__main__":
    main()
