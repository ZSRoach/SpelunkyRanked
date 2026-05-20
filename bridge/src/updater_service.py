"""Selective updater backend for S2Ranked."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

import requests

import settings_store
from config import (
    APP_FOLDER_NAME,
    BRIDGE_ASSET_NAME,
    BRIDGE_COMPONENT_VERSION,
    BRIDGE_VERSION,
    GAME_ASSET_NAME,
    GAME_COMPONENT_VERSION,
    GITHUB_OWNER,
    GITHUB_REPO,
    LATEST_RELEASE_API,
    MOD_SUBPATH,
)


def normalize_version(value) -> str:
    if value is None:
        return ""
    if isinstance(value, float):
        return f"{value:.2f}".rstrip("0").rstrip(".")
    return str(value).strip()


def current_app_dir() -> str:
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))


def default_app_install_dir() -> str:
    saved = settings_store.get_update_app_dir().strip()
    if saved:
        return saved
    if getattr(sys, "frozen", False):
        return current_app_dir()
    return os.path.join(str(Path.home() / "Downloads"), APP_FOLDER_NAME)


def find_game_root() -> str | None:
    candidates = [
        settings_store.get_update_game_dir().strip(),
        r"C:\Program Files (x86)\Steam\steamapps\common\Spelunky 2",
        r"C:\Program Files\Steam\steamapps\common\Spelunky 2",
        os.path.join(os.environ.get("ProgramFiles(x86)", ""), "Steam", "steamapps", "common", "Spelunky 2"),
        os.path.join(os.environ.get("ProgramFiles", ""), "Steam", "steamapps", "common", "Spelunky 2"),
    ]
    for path in candidates:
        if path and (
            os.path.exists(os.path.join(path, "Spel2.exe"))
            or os.path.exists(os.path.join(path, "Mods"))
        ):
            return path
    return None


def download_file(url: str, out_path: str, progress_callback=None):
    headers = {
        "User-Agent": "S2Ranked-Updater",
        "Accept": "application/octet-stream",
    }
    with requests.get(url, stream=True, timeout=60, headers=headers) as r:
        r.raise_for_status()
        total = int(r.headers.get("content-length", 0))
        done = 0
        with open(out_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024 * 64):
                if not chunk:
                    continue
                f.write(chunk)
                done += len(chunk)
                if progress_callback and total > 0:
                    progress_callback(done, total)


def get_release_payload() -> dict:
    headers = {
        "User-Agent": "S2Ranked-Updater",
        "Accept": "application/vnd.github+json",
    }
    r = requests.get(LATEST_RELEASE_API, headers=headers, timeout=30)
    r.raise_for_status()
    return r.json()


def resolve_release_assets(server_version_info: dict | None = None) -> dict:
    payload = get_release_payload()
    assets = payload.get("assets", [])

    bridge_asset = next((a for a in assets if a.get("name") == BRIDGE_ASSET_NAME), None)
    mod_asset = next((a for a in assets if a.get("name") == GAME_ASSET_NAME), None)

    if not bridge_asset or not mod_asset:
        raise RuntimeError(
            f"Latest release is missing required assets: {BRIDGE_ASSET_NAME} or {GAME_ASSET_NAME}"
        )

    info = server_version_info or {}
    comps = info.get("component_versions", {}) or {}

    bridge_component_latest = normalize_version(
        comps.get("bridge") or payload.get("tag_name") or BRIDGE_COMPONENT_VERSION
    )
    game_component_latest = normalize_version(
        comps.get("game") or payload.get("tag_name") or GAME_COMPONENT_VERSION
    )

    return {
        "tag": payload.get("tag_name", "Unknown"),
        "repo": f"{GITHUB_OWNER}/{GITHUB_REPO}",
        "standard_version": normalize_version(info.get("version", BRIDGE_VERSION)),
        "bridge_component_latest": bridge_component_latest,
        "game_component_latest": game_component_latest,
        "bridge_url": bridge_asset.get("browser_download_url", ""),
        "game_url": mod_asset.get("browser_download_url", ""),
    }


def _extract_single_root(extract_dir: str) -> str:
    entries = [os.path.join(extract_dir, name) for name in os.listdir(extract_dir)]
    dirs = [p for p in entries if os.path.isdir(p)]
    files = [p for p in entries if os.path.isfile(p)]
    return dirs[0] if len(dirs) == 1 and not files else extract_dir


def copy_contents(src_dir: str, dst_dir: str):
    for item in os.listdir(src_dir):
        src = os.path.join(src_dir, item)
        dst = os.path.join(dst_dir, item)
        if os.path.isdir(src):
            shutil.copytree(src, dst, dirs_exist_ok=True)
        else:
            shutil.copy2(src, dst)


def install_game_mod(zip_path: str, game_root: str):
    extract_dir = tempfile.mkdtemp(prefix="s2ranked_mod_")
    try:
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(extract_dir)

        src_root = _extract_single_root(extract_dir)
        dst = os.path.join(game_root, MOD_SUBPATH)
        os.makedirs(dst, exist_ok=True)
        copy_contents(src_root, dst)
    finally:
        shutil.rmtree(extract_dir, ignore_errors=True)


def _write_version_file(target_dir: str, version_text: str):
    try:
        Path(os.path.join(target_dir, "version.txt")).write_text(version_text, encoding="utf-8")
    except Exception:
        pass


def install_bridge(zip_path: str, target_dir: str, version_text: str) -> tuple[bool, str | None]:
    extract_dir = tempfile.mkdtemp(prefix="s2ranked_bridge_")
    try:
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(extract_dir)

        src_root = _extract_single_root(extract_dir)
        os.makedirs(target_dir, exist_ok=True)

        same_running_dir = (
            os.path.abspath(target_dir) == os.path.abspath(current_app_dir())
            and getattr(sys, "frozen", False)
        )

        if same_running_dir:
            staging_dir = os.path.join(target_dir, "_pending_update")
            if os.path.exists(staging_dir):
                shutil.rmtree(staging_dir, ignore_errors=True)

            shutil.copytree(src_root, staging_dir)
            _write_version_file(staging_dir, version_text)

            exe_path = sys.executable
            bat_path = os.path.join(target_dir, "apply_update.bat")
            current_pid = os.getpid()

            lines = [
                "@echo off",
                "setlocal",
                ":wait_for_exit",
                f'tasklist /FI "PID eq {current_pid}" | find "{current_pid}" >nul',
                "if not errorlevel 1 (",
                "    timeout /t 1 /nobreak >nul",
                "    goto wait_for_exit",
                ")",
                f'robocopy "{staging_dir}" "{target_dir}" /E /MOVE /NFL /NDL /NJH /NJS /NC /NS >nul',
                f'rmdir /S /Q "{staging_dir}"',
                f'start "" "{exe_path}"',
                'del "%~f0"',
                "endlocal",
            ]
            with open(bat_path, "w", encoding="utf-8", newline="\r\n") as f:
                f.write("\r\n".join(lines) + "\r\n")

            return True, bat_path

        copy_contents(src_root, target_dir)
        _write_version_file(target_dir, version_text)
        return False, None
    finally:
        shutil.rmtree(extract_dir, ignore_errors=True)


def launch_update_script(script_path: str):
    creationflags = 0
    if os.name == "nt":
        creationflags = getattr(subprocess, "CREATE_NO_WINDOW", 0)

    subprocess.Popen(
        ["cmd.exe", "/c", script_path] if os.name == "nt" else [script_path],
        creationflags=creationflags,
        close_fds=True,
    )