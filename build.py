"""
Root build script.
Builds the bridge executable and packages
the mod and bridge into zips in dist/.

Usage:
    uv run build.py
"""

import subprocess
import sys
import zipfile
from pathlib import Path

ROOT_DIR = Path(__file__).parent
MOD_DIR = ROOT_DIR / "mod"
BRIDGE_DIR = ROOT_DIR / "bridge"
BRIDGE_EXECUTABLE_DIR = BRIDGE_DIR / "dist" / "S2Ranked"

DIST_DIR = ROOT_DIR / "dist"
BRIDGE_NAME = "S2Ranked.zip"
MOD_NAME = "SpelunkyRanked.zip"


def build_bridge():
    """Build the bridge executable via PyInstaller."""

    print("Building bridge...")
    subprocess.check_call(["uv", "run", "build_bridge.py"], cwd=BRIDGE_DIR / "build")


def create_zip(src: Path, out: Path):
    """Zip all files in src into out, optionally nesting under prefix."""

    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for file in src.rglob("*"):
            if file.is_file():
                archive_path = file.relative_to(src)
                zf.write(file, archive_path)
    print(f"  -> {out}")


def zip_mod():
    """Package mod lua files"""

    print("Zipping mod...")
    create_zip(MOD_DIR, DIST_DIR / MOD_NAME)


def zip_bridge():
    """Package bridge executable"""

    print("Zipping bridge...")
    create_zip(BRIDGE_EXECUTABLE_DIR, DIST_DIR / BRIDGE_NAME)


def main():
    DIST_DIR.mkdir(parents=True, exist_ok=True)

    try:
        build_bridge()
        zip_mod()
        zip_bridge()
    except subprocess.CalledProcessError as e:
        print(f"Build failed: {e}")
        sys.exit(1)

    print("\nBuild complete!")


if __name__ == "__main__":
    main()
