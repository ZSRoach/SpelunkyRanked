#!/bin/bash
# Build script for Linux/macOS
# Requires Python 3.10+ with shared library support

echo "Building S2Ranked Bridge..."
python3 build_bridge.py

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Build complete! Check the executables folder."
