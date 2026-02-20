"""Main window with sidebar navigation and page stack.

Sidebar layout (top to bottom):
  Active Matches, Match History, Leaderboard, Fastest Times, (stretch), Overlay, Settings, Profile
"""

from PySide6.QtCore import Qt, QTimer
from PySide6.QtWidgets import (
    QMainWindow,
    QWidget,
    QHBoxLayout,
    QVBoxLayout,
    QPushButton,
    QStackedWidget,
    QLabel,
    QFrame,
)

from login_page import LoginPage
from profile_page import ProfilePage
from active_matches_page import ActiveMatchesPage
from match_history_page import MatchHistoryPage
from match_detail_page import MatchDetailPage
from leaderboard_page import LeaderboardPage
from fastest_times_page import FastestTimesPage
from settings_page import SettingsPage
from overlay_window import OverlayWindow
from config import CLR_MAIN_BG, CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_ACTIVE_BTN, CLR_TEXT, CLR_TEXT_BRIGHT


# Style constants
_SIDEBAR_BTN = (
    f"QPushButton {{ text-align: center; padding: 10px 16px; border: none; "
    f"border-radius: 4px; color: {CLR_TEXT}; font-size: 18px; font-weight: bold; }} "
    f"QPushButton:hover {{ background-color: {CLR_BUTTON_BG}; }} "
    f"QPushButton:checked {{ background-color: {CLR_ACTIVE_BTN}; color: white; font-weight: bold; }} "
    f"QPushButton:disabled {{ color: #555; }}"
)


class MainWindow(QMainWindow):
    """Top-level window managing sidebar, pages, and match mode."""

    def __init__(self, controller):
        super().__init__()
        self._controller = controller
        self.setWindowTitle("S2Ranked")
        self.resize(960, 640)

        # Central widget
        central = QWidget()
        central.setStyleSheet(f"background-color: {CLR_MAIN_BG};")
        self.setCentralWidget(central)
        root = QHBoxLayout(central)
        root.setContentsMargins(0, 0, 0, 0)
        root.setSpacing(0)

        # ---- Sidebar ----
        self._sidebar = QFrame()
        self._sidebar.setFixedWidth(170)
        self._sidebar.setStyleSheet(f"QFrame {{ background-color: {CLR_WIDGET_BG}; }}")
        sidebar_layout = QVBoxLayout(self._sidebar)
        sidebar_layout.setContentsMargins(8, 12, 8, 12)
        sidebar_layout.setSpacing(4)

        self._nav_buttons: list[QPushButton] = []

        self._active_matches_btn = self._add_nav_btn("Active\nMatches", sidebar_layout)
        self._history_btn = self._add_nav_btn("Match History", sidebar_layout)
        self._leaderboard_btn = self._add_nav_btn("Leaderboard", sidebar_layout)
        self._fastest_btn = self._add_nav_btn("Fastest Times", sidebar_layout)

        sidebar_layout.addStretch()

        self._overlay_btn = QPushButton("Overlay")
        self._overlay_btn.setStyleSheet(_SIDEBAR_BTN)
        self._overlay_btn.clicked.connect(self._toggle_overlay)
        sidebar_layout.addWidget(self._overlay_btn)

        self._settings_btn = self._add_nav_btn("Settings", sidebar_layout)
        self._profile_btn = self._add_nav_btn("Profile", sidebar_layout)

        root.addWidget(self._sidebar)

        # ---- Page stack ----
        self._stack = QStackedWidget()
        root.addWidget(self._stack, stretch=1)

        # Page indices
        self._login_page = LoginPage(self._controller)
        self._profile_page = ProfilePage(self._controller)
        self._active_matches_page = ActiveMatchesPage(self._controller)
        self._history_page = MatchHistoryPage(self._controller)
        self._detail_page = MatchDetailPage(self._controller)
        self._leaderboard_page = LeaderboardPage(self._controller)
        self._fastest_page = FastestTimesPage(self._controller)
        self._settings_page = SettingsPage(self._controller)
        self._match_mode_page = self._create_match_mode_page()

        self._LOGIN_IDX = self._stack.addWidget(self._login_page)
        self._PROFILE_IDX = self._stack.addWidget(self._profile_page)
        self._ACTIVE_MATCHES_IDX = self._stack.addWidget(self._active_matches_page)
        self._HISTORY_IDX = self._stack.addWidget(self._history_page)
        self._DETAIL_IDX = self._stack.addWidget(self._detail_page)
        self._LEADERBOARD_IDX = self._stack.addWidget(self._leaderboard_page)
        self._FASTEST_IDX = self._stack.addWidget(self._fastest_page)
        self._SETTINGS_IDX = self._stack.addWidget(self._settings_page)
        self._version_mismatch_page = self._create_version_mismatch_page()
        self._disconnected_page = self._create_disconnected_page()
        self._MATCHMODE_IDX = self._stack.addWidget(self._match_mode_page)
        self._VERSION_MISMATCH_IDX = self._stack.addWidget(self._version_mismatch_page)
        self._DISCONNECTED_IDX = self._stack.addWidget(self._disconnected_page)

        # Map nav buttons to page indices
        self._btn_page_map = {
            self._active_matches_btn: self._ACTIVE_MATCHES_IDX,
            self._history_btn: self._HISTORY_IDX,
            self._leaderboard_btn: self._LEADERBOARD_IDX,
            self._fastest_btn: self._FASTEST_IDX,
            self._settings_btn: self._SETTINGS_IDX,
            self._profile_btn: self._PROFILE_IDX,
        }

        for btn in self._btn_page_map:
            btn.clicked.connect(lambda checked=False, b=btn: self._nav_to(b))

        # Back from detail page
        self._detail_page.set_back_callback(
            lambda: self._stack.setCurrentIndex(self._HISTORY_IDX)
        )

        # Match card click → detail page
        self._history_page.match_selected.connect(self._show_match_detail)

        # Overlay window (created but hidden)
        self._overlay = OverlayWindow(self._controller)

        # Start/stop active matches polling when navigating to/from active matches page
        self._stack.currentChanged.connect(self._on_page_changed)

        # ---- Connect controller signals ----
        self._controller.login_success.connect(self._on_login_success)
        self._controller.login_failed.connect(self._on_login_failed)
        self._controller.match_started.connect(self._enter_match_mode)
        self._controller.match_result.connect(self._exit_match_mode)
        self._controller.match_scrapped.connect(self._exit_match_mode)
        self._controller.game_version_mismatch.connect(self._show_game_version_mismatch)
        self._controller.ws_connected.connect(self._on_ws_reconnected)
        self._controller.ws_disconnected.connect(self._on_ws_disconnected)
        self._settings_page.logout_requested.connect(self._on_logout)

        # Reconnect timer
        self._reconnect_timer = QTimer(self)
        self._reconnect_timer.setInterval(10000)
        self._reconnect_timer.timeout.connect(self._attempt_reconnect)

        # Start on login page, sidebar hidden
        self._sidebar.setVisible(False)
        self._stack.setCurrentIndex(self._LOGIN_IDX)

        # Attempt auto-login with cached credentials
        self._login_page.try_auto_login()

    # ---- Helpers ----

    def _add_nav_btn(self, text: str, layout: QVBoxLayout) -> QPushButton:
        btn = QPushButton(text)
        btn.setCheckable(True)
        btn.setStyleSheet(_SIDEBAR_BTN)
        layout.addWidget(btn)
        self._nav_buttons.append(btn)
        return btn

    def _nav_to(self, btn: QPushButton):
        idx = self._btn_page_map.get(btn)
        if idx is not None:
            self._stack.setCurrentIndex(idx)
        for b in self._nav_buttons:
            b.setChecked(b is btn)

    def _create_match_mode_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setAlignment(Qt.AlignCenter)
        label = QLabel("Match in Progress")
        label.setStyleSheet(f"color: {CLR_ACTIVE_BTN}; font-size: 36px; font-weight: bold;")
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label)
        sub = QLabel("Navigation is locked during the match.\nUse the Overlay button to view opponent progress.")
        sub.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 20px; font-weight: bold;")
        sub.setAlignment(Qt.AlignCenter)
        layout.addWidget(sub)
        return page

    def _create_version_mismatch_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setAlignment(Qt.AlignCenter)
        label = QLabel("Version Mismatch")
        label.setStyleSheet(f"color: #ff6666; font-size: 36px; font-weight: bold;")
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label)
        self._version_mismatch_label = QLabel("")
        self._version_mismatch_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 20px; font-weight: bold;")
        self._version_mismatch_label.setAlignment(Qt.AlignCenter)
        self._version_mismatch_label.setOpenExternalLinks(True)
        self._version_mismatch_label.setTextFormat(Qt.RichText)
        layout.addWidget(self._version_mismatch_label)
        return page

    def _create_disconnected_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setAlignment(Qt.AlignCenter)
        label = QLabel("Can't connect to the server.")
        label.setStyleSheet(f"color: #ff6666; font-size: 30px; font-weight: bold;")
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label)
        self._reconnect_status = QLabel("Retrying in 10s...")
        self._reconnect_status.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 20px; font-weight: bold;")
        self._reconnect_status.setAlignment(Qt.AlignCenter)
        layout.addWidget(self._reconnect_status)
        return page

    # ---- Slots ----

    def _on_ws_disconnected(self):
        # Don't show disconnect page if we're on login or version mismatch
        current = self._stack.currentIndex()
        if current in (self._LOGIN_IDX, self._VERSION_MISMATCH_IDX):
            return
        self._sidebar.setVisible(False)
        self._stack.setCurrentIndex(self._DISCONNECTED_IDX)
        self._reconnect_status.setText("Retrying in 10s...")
        self._reconnect_timer.start()

    def _attempt_reconnect(self):
        self._reconnect_status.setText("Reconnecting...")
        self._controller.ws.reconnect()

    def _on_ws_reconnected(self):
        self._reconnect_timer.stop()
        # Only restore UI if we're on the disconnected page
        if self._stack.currentIndex() == self._DISCONNECTED_IDX:
            self._sidebar.setVisible(True)
            self._stack.setCurrentIndex(self._PROFILE_IDX)
            self._profile_btn.setChecked(True)
            self._controller.refresh_player_data()

    def _on_page_changed(self, index: int):
        if index == self._ACTIVE_MATCHES_IDX:
            self._controller.start_active_matches_polling()
        else:
            self._controller.stop_active_matches_polling()

    def _on_login_success(self, data: dict):
        self._sidebar.setVisible(True)
        self._stack.setCurrentIndex(self._PROFILE_IDX)
        self._profile_btn.setChecked(True)
        self._controller.start_networking()
        self._controller.initialize_match_cache()

    def _on_login_failed(self, msg: str):
        # Stay on login page; LoginPage handles its own status display
        pass

    def _show_game_version_mismatch(self, download_url: str):
        """Lock the UI to a version mismatch page with a download link for the game mod."""
        self._version_mismatch_label.setText(
            f'Your game mod is outdated. Download the latest version:<br>'
            f'<a href="{download_url}" style="color: #66aaff;">{download_url}</a>'
        )
        self._sidebar.setVisible(False)
        self._stack.setCurrentIndex(self._VERSION_MISMATCH_IDX)

    def _enter_match_mode(self, data=None):
        self._stack.setCurrentIndex(self._MATCHMODE_IDX)
        for btn in self._nav_buttons:
            btn.setEnabled(False)
            btn.setChecked(False)

    def _exit_match_mode(self, data=None):
        for btn in self._nav_buttons:
            btn.setEnabled(True)
        self._stack.setCurrentIndex(self._PROFILE_IDX)
        self._profile_btn.setChecked(True)
        # Refresh profile after match
        self._controller.refresh_player_data()

    def _on_logout(self):
        self._reconnect_timer.stop()
        self._controller.logout()
        if self._overlay.isVisible():
            self._overlay.hide()
            self._update_overlay_btn_style()
        for btn in self._nav_buttons:
            btn.setChecked(False)
        self._sidebar.setVisible(False)
        self._login_page.reset()
        self._stack.setCurrentIndex(self._LOGIN_IDX)

    def _toggle_overlay(self):
        if self._overlay.isVisible():
            self._overlay.hide()
        else:
            self._overlay.show()
        self._update_overlay_btn_style()

    def _update_overlay_btn_style(self):
        if self._overlay.isVisible():
            self._overlay_btn.setStyleSheet(
                f"QPushButton {{ text-align: center; padding: 10px 16px; border: none; "
                f"border-radius: 4px; color: white; font-size: 18px; font-weight: bold; "
                f"background-color: {CLR_ACTIVE_BTN}; }}"
            )
        else:
            self._overlay_btn.setStyleSheet(_SIDEBAR_BTN)

    def _show_match_detail(self, match_data: dict):
        self._detail_page.load_match(match_data)
        self._stack.setCurrentIndex(self._DETAIL_IDX)

    def closeEvent(self, event):
        self._controller.stop_networking()
        self._overlay.close()
        super().closeEvent(event)
