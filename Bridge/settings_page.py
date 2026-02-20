"""Settings page with overlay background color picker."""

from PySide6.QtCore import Qt
from PySide6.QtGui import QColor
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QColorDialog,
    QFrame,
)

from PySide6.QtCore import Signal

import settings_store
from config import CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_TEXT, CLR_TEXT_BRIGHT


class SettingsPage(QWidget):
    """Settings page — overlay background color and logout."""

    logout_requested = Signal()

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._setup_ui()

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        header = QLabel("Settings")
        header.setStyleSheet(f"font-size: 36px; font-weight: bold; color: {CLR_TEXT_BRIGHT};")
        layout.addWidget(header)

        # Overlay color setting
        color_frame = QFrame()
        color_frame.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 8px; padding: 16px; }}"
        )
        color_layout = QHBoxLayout(color_frame)

        label = QLabel("Overlay Background Color")
        label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        color_layout.addWidget(label)

        color_layout.addStretch()

        self._color_preview = QFrame()
        self._color_preview.setFixedSize(40, 40)
        self._color_preview.setStyleSheet("border-radius: 4px; border: 1px solid #555;")
        color_layout.addWidget(self._color_preview)

        self._color_btn = QPushButton("Choose Color")
        self._color_btn.setFixedHeight(40)
        self._color_btn.setStyleSheet(
            f"QPushButton {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT}; "
            f"border-radius: 4px; padding: 0 16px; font-size: 19px; font-weight: bold; }}"
            f"QPushButton:hover {{ background-color: #3e4278; }}"
        )
        self._color_btn.clicked.connect(self._pick_color)
        color_layout.addWidget(self._color_btn)

        layout.addWidget(color_frame)

        layout.addStretch()

        # Logout button
        self._logout_btn = QPushButton("Log Out")
        self._logout_btn.setFixedWidth(200)
        self._logout_btn.setFixedHeight(44)
        self._logout_btn.setStyleSheet(
            "QPushButton { background-color: #8b2020; color: white; "
            "font-size: 19px; font-weight: bold; border-radius: 6px; } "
            "QPushButton:hover { background-color: #a52a2a; }"
        )
        self._logout_btn.clicked.connect(self._on_logout)
        layout.addWidget(self._logout_btn, alignment=Qt.AlignLeft)

        self._load_current_color()

    def _load_current_color(self):
        color = settings_store.get_overlay_color()
        self._set_preview_color(color)

    def _set_preview_color(self, hex_color: str):
        self._color_preview.setStyleSheet(
            f"background-color: {hex_color}; border-radius: 4px; border: 1px solid #555;"
        )

    def _pick_color(self):
        current = QColor(settings_store.get_overlay_color())
        color = QColorDialog.getColor(current, self, "Overlay Background Color")
        if color.isValid():
            hex_color = color.name()
            settings_store.set_overlay_color(hex_color)
            self._set_preview_color(hex_color)

    def _on_logout(self):
        settings_store.clear_steam_id()
        self.logout_requested.emit()
