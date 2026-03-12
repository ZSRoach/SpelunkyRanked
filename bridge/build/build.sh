#!/bin/bash
# Build script for Linux/macOS
# Requires uv

echo "Building S2Ranked Bridge..."
uv run build_bridge.py

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Build complete! Check the dist folder."
