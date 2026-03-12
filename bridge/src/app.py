"""Entry point for the Bridge application."""

import logging
import os
import sys

from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt
from PySide6.QtGui import QFont, QFontDatabase, QIcon

from bridge_controller import BridgeController
from main_window import MainWindow
from config import (
    ASSETS_DIR, CLR_MAIN_BG, CLR_WIDGET_BG, CLR_BUTTON_BG,
    CLR_ACTIVE_BTN, CLR_TEXT,
)

# ---- Logging setup ----
if getattr(sys, "frozen", False):
    _log_dir = os.path.dirname(sys.executable)
else:
    _log_dir = os.path.dirname(os.path.abspath(__file__))

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(_log_dir, "bridge.log"), encoding="utf-8"),
        logging.StreamHandler(sys.stdout),
    ],
)


def _build_stylesheet(font_family: str) -> str:
    """Build the global dark-theme stylesheet with the given font family."""
    return f"""
QWidget {{
    background-color: {CLR_MAIN_BG};
    color: {CLR_TEXT};
    font-family: "{font_family}", "Segoe UI", sans-serif;
    font-weight: bold;
}}
QLabel {{
    font-weight: bold;
}}
QLineEdit {{
    background-color: {CLR_WIDGET_BG};
    color: {CLR_TEXT};
    border: 1px solid {CLR_BUTTON_BG};
    border-radius: 4px;
    padding: 6px 10px;
    font-size: 19px;
    font-weight: bold;
}}
QLineEdit:focus {{
    border-color: {CLR_ACTIVE_BTN};
}}
QPushButton {{
    background-color: {CLR_BUTTON_BG};
    color: {CLR_TEXT};
    border: none;
    border-radius: 4px;
    padding: 6px 14px;
    font-size: 19px;
    font-weight: bold;
}}
QPushButton:hover {{
    background-color: #3e4278;
}}
QPushButton:pressed {{
    background-color: {CLR_ACTIVE_BTN};
}}
QPushButton:disabled {{
    background-color: #1a1a28;
    color: #555;
}}
QScrollArea {{
    border: none;
}}
QScrollBar:vertical {{
    background-color: transparent;
    width: 8px;
    margin: 0;
}}
QScrollBar::handle:vertical {{
    background-color: {CLR_BUTTON_BG};
    border-radius: 4px;
    min-height: 30px;
}}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{
    height: 0;
}}
QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {{
    background: transparent;
}}
QScrollBar:horizontal {{
    background-color: transparent;
    height: 8px;
    margin: 0;
}}
QScrollBar::handle:horizontal {{
    background-color: {CLR_BUTTON_BG};
    border-radius: 4px;
    min-width: 30px;
}}
QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {{
    width: 0;
}}
QScrollBar::add-page:horizontal, QScrollBar::sub-page:horizontal {{
    background: transparent;
}}
"""


def main():
    app = QApplication(sys.argv)

    # Load custom font
    font_path = os.path.join(ASSETS_DIR, "Tekton-Bold.otf")
    font_id = QFontDatabase.addApplicationFont(font_path)
    if font_id >= 0:
        families = QFontDatabase.applicationFontFamilies(font_id)
        font_family = families[0] if families else "Segoe UI"
    else:
        font_family = "Segoe UI"

    app.setFont(QFont(font_family))
    app.setStyleSheet(_build_stylesheet(font_family))

    # Set application icon
    icon_path = os.path.join(ASSETS_DIR, "appicon.png")
    if os.path.exists(icon_path):
        app.setWindowIcon(QIcon(icon_path))

    controller = BridgeController()
    window = MainWindow(controller)
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
