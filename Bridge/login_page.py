"""Login page with Steam OpenID authentication."""

import threading

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QLabel,
    QPushButton,
    QLineEdit,
    QHBoxLayout,
)


import settings_store
from steam_auth import SteamAuthWorker
from config import CLR_TEXT, CLR_TEXT_BRIGHT, CLR_WIDGET_BG, CLR_BUTTON_BG


class LoginPage(QWidget):
    """Login screen shown on app launch."""

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._steam_id = ""
        self._setup_ui()

        # When the server says this is a new player, show the name prompt
        self._controller.registration_needed.connect(self._show_name_prompt)
        # Registration error (name taken, blocked, etc.) — stay on name prompt
        self._controller.registration_failed.connect(self._on_registration_failed)
        # Bridge version mismatch
        self._controller.bridge_version_mismatch.connect(self._show_version_mismatch)
        # On login failure, reset to normal login state
        self._controller.login_failed.connect(self._on_login_failed)

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setAlignment(Qt.AlignCenter)
        layout.setSpacing(16)

        title = QLabel("S2Ranked")
        title.setStyleSheet(f"font-size: 40px; font-weight: bold; color: {CLR_TEXT_BRIGHT};")
        title.setAlignment(Qt.AlignCenter)
        layout.addWidget(title)

        self._subtitle = QLabel("Login with your Steam account to continue")
        self._subtitle.setStyleSheet(f"font-size: 24px; font-weight: bold; color: {CLR_TEXT_BRIGHT};")
        self._subtitle.setAlignment(Qt.AlignCenter)
        layout.addWidget(self._subtitle)

        layout.addSpacing(20)

        self._login_btn = QPushButton("Login with Steam")
        self._login_btn.setFixedWidth(300)
        self._login_btn.setFixedHeight(52)
        self._login_btn.setStyleSheet(
            "QPushButton { background-color: #1b2838; color: white; "
            "font-size: 26px; font-weight: bold; border-radius: 6px; border: 1px solid #2a475e; } "
            "QPushButton:hover { background-color: #2a475e; } "
            "QPushButton:disabled { background-color: #555; color: #999; }"
        )
        self._login_btn.clicked.connect(self._start_steam_auth)
        layout.addWidget(self._login_btn, alignment=Qt.AlignCenter)

        # --- Name registration section (hidden until needed) ---
        self._name_section = QWidget()
        name_layout = QVBoxLayout(self._name_section)
        name_layout.setAlignment(Qt.AlignCenter)
        name_layout.setSpacing(8)

        name_label = QLabel("Choose a display name:")
        name_label.setStyleSheet(f"font-size: 24px; font-weight: bold; color: {CLR_TEXT_BRIGHT};")
        name_label.setAlignment(Qt.AlignCenter)
        name_layout.addWidget(name_label)

        name_row = QHBoxLayout()
        name_row.setSpacing(8)
        self._reg_name_input = QLineEdit()
        self._reg_name_input.setPlaceholderText("Display Name")
        self._reg_name_input.setFixedWidth(220)
        self._reg_name_input.setStyleSheet(f"background-color: {CLR_WIDGET_BG};")
        name_row.addWidget(self._reg_name_input)

        self._reg_btn = QPushButton("Confirm")
        self._reg_btn.setFixedWidth(100)
        self._reg_btn.setStyleSheet(
            f"QPushButton {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"font-size: 20px; font-weight: bold; border-radius: 4px; border: 1px solid #444; }} "
            f"QPushButton:hover {{ background-color: #3e4377; }}"
        )
        self._reg_btn.clicked.connect(self._submit_registration)
        name_row.addWidget(self._reg_btn)

        name_layout.addLayout(name_row)
        self._name_section.hide()
        layout.addWidget(self._name_section, alignment=Qt.AlignCenter)

        self._status_label = QLabel("")
        self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")
        self._status_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self._status_label)

    def try_auto_login(self):
        """Attempt to log in with a cached steam_id. Call once after UI is ready."""
        cached = settings_store.get_steam_id()
        if cached:
            self._steam_id = cached
            self._login_btn.setEnabled(False)
            self._status_label.setText("Logging in...")
            self._status_label.setStyleSheet("color: #66ff66; font-size: 22px; font-weight: bold;")
            self._controller.login(cached)

    def reset(self):
        """Reset to the default login page state (used by logout)."""
        self._steam_id = ""
        self._login_btn.show()
        self._login_btn.setEnabled(True)
        self._name_section.hide()
        self._subtitle.setText("Login with your Steam account to continue")
        self._status_label.setText("")
        self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")

    def _on_login_failed(self, msg: str):
        """Auto-login or manual login failed — restore the login button."""
        self._login_btn.show()
        self._login_btn.setEnabled(True)
        self._status_label.setText(f"Login failed: {msg}")
        self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")

    def _start_steam_auth(self):
        self._login_btn.setEnabled(False)
        self._name_section.hide()
        self._status_label.setText("Opening Steam login in browser...")

        self._auth_worker = SteamAuthWorker()
        self._auth_worker.finished.connect(self._on_steam_auth_done)
        threading.Thread(target=self._auth_worker.run, daemon=True).start()

    def _on_steam_auth_done(self, steam_id: str):
        self._login_btn.setEnabled(True)
        # Bring app window back to front after browser auth
        window = self.window()
        if window:
            window.showMinimized()
            window.showNormal()
            window.activateWindow()
        if steam_id:
            self._steam_id = steam_id
            settings_store.set_steam_id(steam_id)
            self._status_label.setText(f"Authenticated as {steam_id}. Logging in...")
            self._status_label.setStyleSheet("color: #66ff66; font-size: 22px; font-weight: bold;")
            self._controller.login(steam_id)
        else:
            self._status_label.setText("Steam authentication failed. Try again.")
            self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")

    def _show_name_prompt(self, steam_id: str):
        """Called when the server says this steam_id is unregistered."""
        self._steam_id = steam_id
        self._subtitle.setText("New account \u2014 choose a display name")
        self._login_btn.hide()
        self._name_section.show()
        self._reg_name_input.setFocus()
        self._status_label.setText("")
        self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")

    def _show_version_mismatch(self, download_url: str):
        """Show bridge version mismatch with download link."""
        self._login_btn.hide()
        self._name_section.hide()
        self._subtitle.setText("Bridge version mismatch")
        self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")
        self._status_label.setText(
            f'Your bridge is outdated. Download the latest version: '
            f'<a href="{download_url}" style="color: #66aaff;">{download_url}</a>'
        )
        self._status_label.setOpenExternalLinks(True)
        self._status_label.setTextFormat(Qt.RichText)

    def _on_registration_failed(self, msg: str):
        """Registration was rejected (name taken, blocked, etc.) — stay on name prompt."""
        self._reg_btn.setEnabled(True)
        self._reg_name_input.setEnabled(True)
        self._status_label.setText(msg)
        self._status_label.setStyleSheet("color: #ff6666; font-size: 22px; font-weight: bold;")

    def _submit_registration(self):
        name = self._reg_name_input.text().strip()
        if not name:
            self._status_label.setText("Display name cannot be empty.")
            return
        self._reg_btn.setEnabled(False)
        self._reg_name_input.setEnabled(False)
        self._status_label.setText("Registering...")
        self._status_label.setStyleSheet("color: #66ff66; font-size: 22px; font-weight: bold;")
        self._controller.register(self._steam_id, name)
