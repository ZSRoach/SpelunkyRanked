# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['C:\\Users\\ZSRoach\\Documents\\Programming\\AI Stuff\\codespaces-blank\\Bridge\\app.py'],
    pathex=[],
    binaries=[],
    datas=[('C:\\Users\\ZSRoach\\Documents\\Programming\\AI Stuff\\codespaces-blank\\Bridge\\assets', 'assets')],
    hiddenimports=['PySide6.QtCore', 'PySide6.QtGui', 'PySide6.QtWidgets', 'socketio', 'engineio', 'engineio.async_drivers.threading', 'websocket'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='S2Ranked',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['C:\\Users\\ZSRoach\\Documents\\Programming\\AI Stuff\\codespaces-blank\\Bridge\\assets\\appicon.ico'],
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='S2Ranked',
)
