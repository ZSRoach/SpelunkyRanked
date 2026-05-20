from __future__ import annotations

import shutil
import tempfile

from PySide6.QtCore import QObject, QThread, Signal, Slot, Qt, QTimer
from PySide6.QtGui import QFont
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QFrame,
    QFileDialog,
    QProgressBar,
    QMessageBox,
    QSizePolicy,
)

import api_client
import settings_store
import updater_service
from config import (
    BRIDGE_COMPONENT_VERSION,
    BRIDGE_VERSION,
    CLR_WIDGET_BG,
    CLR_BUTTON_BG,
    CLR_TEXT,
    CLR_TEXT_BRIGHT,
    CLR_ACTIVE_BTN,
)


class UpdateCheckWorker(QObject):
    finished = Signal(dict, dict)
    error = Signal(str)

    @Slot()
    def run(self):
        try:
            info = api_client.get_server_version()
            comps = info.get("component_versions", {}) or {}
            info = {
                **info,
                "version_text": updater_service.normalize_version(info.get("version", "")),
                "bridge_component_version": updater_service.normalize_version(comps.get("bridge", "")) or "Not provided",
                "game_component_version": updater_service.normalize_version(comps.get("game", "")) or "Not provided",
            }
            release = updater_service.resolve_release_assets(info)
            self.finished.emit(info, release)
        except Exception as e:
            self.error.emit(str(e))


class UpdateInstallWorker(QObject):
    progress = Signal(int)
    status = Signal(str, object)
    finished = Signal(bool)
    error = Signal(str)
    restart_needed = Signal(str)
    refresh_needed = Signal()

    def __init__(self, latest_release: dict, update_bridge: bool, update_game: bool):
        super().__init__()
        self._latest_release = latest_release
        self._update_bridge = update_bridge
        self._update_game = update_game

    @Slot()
    def run(self):
        temp_dir = tempfile.mkdtemp(prefix="s2ranked_update_")
        try:
            bridge_zip = None
            game_zip = None

            if self._update_bridge:
                bridge_zip = f"{temp_dir}/S2Ranked.zip"
                self.status.emit("Downloading bridge files...", None)

                def bridge_progress(done, total):
                    value = int((done / total) * 40) if total else 0
                    self.progress.emit(value)

                updater_service.download_file(
                    self._latest_release["bridge_url"],
                    bridge_zip,
                    bridge_progress,
                )

            if self._update_game:
                game_zip = f"{temp_dir}/SpelunkyRanked.zip"
                self.status.emit("Downloading game mod files...", None)
                base = 40 if self._update_bridge else 0

                def game_progress(done, total):
                    value = base + (int((done / total) * 40) if total else 0)
                    self.progress.emit(value)

                updater_service.download_file(
                    self._latest_release["game_url"],
                    game_zip,
                    game_progress,
                )

            if self._update_game and game_zip:
                self.status.emit("Installing game mod...", None)
                game_root = updater_service.find_game_root()
                if not game_root:
                    raise RuntimeError("Spelunky 2 folder not found.")
                updater_service.install_game_mod(game_zip, game_root)
                self.progress.emit(85 if self._update_bridge else 100)

            if self._update_bridge and bridge_zip:
                self.status.emit("Installing bridge...", None)
                needs_restart, script_path = updater_service.install_bridge(
                    bridge_zip,
                    updater_service.default_app_install_dir(),
                    self._latest_release["bridge_component_latest"] or self._latest_release["tag"],
                )
                self.progress.emit(100)

                if needs_restart and script_path:
                    self.status.emit("Bridge update staged. Restarting to finish update...", True)
                    self.restart_needed.emit(script_path)
                    return

            self.status.emit("Update complete.", True)
            self.refresh_needed.emit()
            self.finished.emit(True)

        except Exception as e:
            self.error.emit(str(e))
        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)


class UpdatePanel(QWidget):
    restart_requested = Signal()
    update_completed = Signal(bool, bool)

    def __init__(
        self,
        controller,
        title="Update Required",
        subtitle="Your Ranked files are out of date. Update below to continue.",
        show_version_info=True,
        parent=None,
    ):
        super().__init__(parent)
        self._controller = controller
        self._title_text = title
        self._subtitle_text = subtitle
        self._show_version_info = show_version_info
        self._latest_release = None
        self._server_version_info = getattr(controller, "last_version_info", {}) or {}

        self._check_thread = None
        self._check_worker = None
        self._install_thread = None
        self._install_worker = None
        self._pending_update_request = None
        self._bridge_outdated: bool | None = None
        self._game_outdated: bool | None = None

        self._setup_ui()
        self.refresh_labels()

    def _base_font_family(self) -> str:
        return "Segoe UI"

    def _card_style(self):
        return f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 8px; padding: 16px; }}"

    def _btn_style(self, primary=False):
        bg = CLR_ACTIVE_BTN if primary else CLR_BUTTON_BG
        fg = "white" if primary else CLR_TEXT
        hover = "#5384e8" if primary else "#3e4278"
        return (
            f"QPushButton {{ font-family: '{self._base_font_family()}'; background-color: {bg}; color: {fg}; border-radius: 4px; padding: 10px 18px; font-size: 15px; font-weight: bold; min-height: 40px; }}"
            f"QPushButton:hover {{ background-color: {hover}; }}"
            "QPushButton:disabled { background-color: #1a1a28; color: #555; }"
        )

    def _row(self, layout, label_text, value_label, button=None):
        row = QHBoxLayout()
        row.setSpacing(12)
        row.setAlignment(Qt.AlignmentFlag.AlignTop)

        label = QLabel(label_text)
        label.setWordWrap(True)
        label.setMinimumHeight(40)
        label.setSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Minimum)
        label.setStyleSheet(
            f"font-family: '{self._base_font_family()}'; color: {CLR_TEXT_BRIGHT}; font-size: 16px; font-weight: bold; padding-top: 4px; padding-bottom: 4px;"
        )

        value_label.setWordWrap(True)
        value_label.setMinimumHeight(40)
        value_label.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Minimum)
        value_label.setStyleSheet(
            f"font-family: '{self._base_font_family()}'; color: {CLR_TEXT}; font-size: 15px; font-weight: bold; padding-top: 4px; padding-bottom: 4px;"
        )

        row.addWidget(label, 0, Qt.AlignmentFlag.AlignTop)
        row.addWidget(value_label, 1, Qt.AlignmentFlag.AlignTop)

        if button:
            row.addWidget(button, 0, Qt.AlignmentFlag.AlignTop)

        layout.addLayout(row)

    def _setup_ui(self):
        root = QVBoxLayout(self)
        root.setContentsMargins(0, 0, 0, 0)
        root.setSpacing(16)

        card = QFrame()
        card.setStyleSheet(self._card_style())
        root.addWidget(card)

        layout = QVBoxLayout(card)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(14)

        if self._title_text.strip():
            title_font = QFont(self._base_font_family(), 18)
            title_font.setBold(True)

            title = QLabel(self._title_text)
            title.setFont(title_font)
            title.setWordWrap(True)
            title.setMinimumHeight(64)
            title.setSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Minimum)
            title.setStyleSheet(
                f"font-family: '{self._base_font_family()}'; color: {CLR_TEXT_BRIGHT}; padding-top: 8px; padding-bottom: 12px;"
            )
            layout.addWidget(title)
        else:
            layout.setSpacing(10)

        if self._show_version_info and self._subtitle_text:
            subtitle = QLabel(self._subtitle_text)
            subtitle.setWordWrap(True)
            subtitle.setMinimumHeight(44)
            subtitle.setSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Minimum)
            subtitle.setStyleSheet(
                f"font-family: '{self._base_font_family()}'; color: {CLR_TEXT}; font-size: 15px; padding-bottom: 6px;"
            )
            layout.addWidget(subtitle)

        self._installed_bridge = QLabel()
        self._server_standard = QLabel()
        self._app_dir = QLabel()
        self._game_dir = QLabel()

        app_pick = QPushButton("Choose App Folder")
        app_pick.setStyleSheet(self._btn_style())
        app_pick.clicked.connect(self._pick_app_dir)

        game_pick = QPushButton("Choose Game Folder")
        game_pick.setStyleSheet(self._btn_style())
        game_pick.clicked.connect(self._pick_game_dir)

        if self._show_version_info:
            self._row(layout, "Bridge version:", self._installed_bridge)
            self._row(layout, "Server version:", self._server_standard)
        self._row(layout, "App folder:", self._app_dir, app_pick)
        self._row(layout, "Game folder:", self._game_dir, game_pick)

        btns = QHBoxLayout()
        btns.setSpacing(12)

        self._check = QPushButton("Check Latest")
        self._check.setStyleSheet(self._btn_style())
        self._check.clicked.connect(self.check_latest)
        btns.addWidget(self._check)

        self._update_bridge = QPushButton("Update Bridge")
        self._update_bridge.setStyleSheet(self._btn_style(True))
        self._update_bridge.clicked.connect(lambda: self._start_update(True, False))
        btns.addWidget(self._update_bridge)

        self._update_game = QPushButton("Update Game Mod")
        self._update_game.setStyleSheet(self._btn_style(True))
        self._update_game.clicked.connect(lambda: self._start_update(False, True))
        btns.addWidget(self._update_game)

        self._update_both = QPushButton("Update Both")
        self._update_both.setStyleSheet(self._btn_style(True))
        self._update_both.clicked.connect(lambda: self._start_update(True, True))
        btns.addWidget(self._update_both)

        btns.addStretch()
        layout.addLayout(btns)
        layout.addSpacing(10)

        self._progress = QProgressBar()

        self._progress = QProgressBar()
        self._progress.setRange(0, 100)
        self._progress.setValue(0)
        self._progress.setMinimumHeight(30)
        self._progress.setStyleSheet(
            f"QProgressBar {{ font-family: '{self._base_font_family()}'; background-color: #2c315d; border: none; border-radius: 4px; text-align: center; color: white; font-weight: bold; min-height: 30px; }}"
            f"QProgressBar::chunk {{ background-color: {CLR_ACTIVE_BTN}; border-radius: 4px; }}"
        )
        layout.addWidget(self._progress)

        self._status = QLabel("Ready")
        self._status.setWordWrap(True)
        self._status.setMinimumHeight(36)
        self._status.setSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Minimum)
        self._status.setStyleSheet(
            f"font-family: '{self._base_font_family()}'; color: {CLR_TEXT}; font-size: 14px; font-weight: bold; padding-top: 4px;"
        )
        layout.addWidget(self._status)

    def refresh_labels(self):
        info = getattr(self._controller, "last_version_info", {}) or self._server_version_info or {}
        self._server_version_info = info
        self._installed_bridge.setText(str(BRIDGE_COMPONENT_VERSION))
        self._server_standard.setText(info.get("version_text") or str(BRIDGE_VERSION))
        self._app_dir.setText(updater_service.default_app_install_dir().replace("\\", "/"))
        self._game_dir.setText((updater_service.find_game_root() or "Not found").replace("\\", "/"))

    def _set_status(self, text, ok=None):
        color = CLR_TEXT if ok is None else ("#58D68D" if ok else "#FF6B6B")
        self._status.setStyleSheet(
            f"font-family: '{self._base_font_family()}'; color: {color}; font-size: 16px; font-weight: bold; padding-top: 6px;"
        )
        self._status.setText(text)

    def _apply_update_state(self):
        """Set button enabled states and status text based on last version check."""
        if self._bridge_outdated is None:
            for b in [self._check, self._update_bridge, self._update_game, self._update_both]:
                b.setEnabled(True)
            return
        bridge_out = self._bridge_outdated
        game_out = self._game_outdated
        self._check.setEnabled(True)
        self._update_bridge.setEnabled(bridge_out)
        self._update_game.setEnabled(game_out)
        self._update_both.setEnabled(bridge_out and game_out)
        if not bridge_out and not game_out:
            self._set_status("You are up to date!", True)
        elif bridge_out and not game_out:
            self._set_status("Bridge is out of date, update now.", None)
        elif not bridge_out and game_out:
            self._set_status("Game mod is out of date, update now.", None)
        else:
            self._set_status("Bridge and game mod are out of date, update now.", None)

    def _set_busy(self, busy):
        if busy:
            for b in [self._check, self._update_bridge, self._update_game, self._update_both]:
                b.setEnabled(False)
        else:
            self._apply_update_state()

    def _pick_app_dir(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Ranked App folder", self._app_dir.text())
        if folder:
            settings_store.set_update_app_dir(folder)
            self.refresh_labels()

    def _pick_game_dir(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Spelunky 2 folder", self._game_dir.text())
        if folder:
            settings_store.set_update_game_dir(folder)
            self.refresh_labels()

    def check_latest(self):
        if self._check_thread is not None:
            return

        self._set_busy(True)
        self._set_status("Checking latest release...")
        self._progress.setValue(0)

        self._check_thread = QThread(self)
        self._check_worker = UpdateCheckWorker()
        self._check_worker.moveToThread(self._check_thread)

        self._check_thread.started.connect(self._check_worker.run)
        self._check_worker.finished.connect(self._on_check_finished)
        self._check_worker.error.connect(self._on_check_error)

        self._check_worker.finished.connect(self._check_thread.quit)
        self._check_worker.error.connect(self._check_thread.quit)

        self._check_thread.finished.connect(self._cleanup_check_thread)
        self._check_thread.start()

    @Slot(dict, dict)
    def _on_check_finished(self, info, release):
        self._server_version_info = info
        self._controller.last_version_info = info
        self._latest_release = release
        self._progress.setValue(100)
        self.refresh_labels()

        self._bridge_outdated = (
            updater_service.normalize_version(BRIDGE_COMPONENT_VERSION)
            != updater_service.normalize_version(release.get("bridge_component_latest", ""))
        )
        game_root = updater_service.find_game_root()
        installed_game = updater_service.read_installed_game_version(game_root) if game_root else ""
        self._game_outdated = (
            updater_service.normalize_version(installed_game)
            != updater_service.normalize_version(release.get("game_component_latest", ""))
        )

        self._set_busy(False)

        if self._pending_update_request is not None:
            update_bridge, update_game = self._pending_update_request
            self._pending_update_request = None
            QTimer.singleShot(0, lambda: self._start_update(update_bridge, update_game))

    @Slot(str)
    def _on_check_error(self, message):
        self._pending_update_request = None
        self._set_status(f"Check failed: {message}", False)
        self._set_busy(False)

    @Slot()
    def _cleanup_check_thread(self):
        if self._check_worker is not None:
            self._check_worker.deleteLater()
        if self._check_thread is not None:
            self._check_thread.deleteLater()
        self._check_worker = None
        self._check_thread = None

    def _start_update(self, update_bridge, update_game):
        if self._install_thread is not None:
            return

        if not self._latest_release:
            self._pending_update_request = (update_bridge, update_game)
            self.check_latest()
            self._set_status("Checking latest release first...")
            return

        if update_game and not updater_service.find_game_root():
            QMessageBox.warning(self, "Missing game folder", "Choose your Spelunky 2 folder first.")
            return

        self._set_busy(True)
        self._progress.setValue(0)

        self._install_thread = QThread(self)
        self._install_worker = UpdateInstallWorker(self._latest_release, update_bridge, update_game)
        self._install_worker.moveToThread(self._install_thread)

        self._install_thread.started.connect(self._install_worker.run)
        self._install_worker.progress.connect(self._progress.setValue)
        self._install_worker.status.connect(self._set_status)
        self._install_worker.finished.connect(self._on_install_finished)
        self._install_worker.error.connect(self._on_install_error)
        self._install_worker.restart_needed.connect(self._on_restart_needed)
        self._install_worker.refresh_needed.connect(self.refresh_labels)

        self._install_worker.finished.connect(self._install_thread.quit)
        self._install_worker.error.connect(self._install_thread.quit)
        self._install_worker.restart_needed.connect(self._install_thread.quit)

        self._install_thread.finished.connect(self._cleanup_install_thread)
        self._install_thread.start()

    @Slot(bool)
    def _on_install_finished(self, success):
        if success:
            self._bridge_outdated = None
            self._game_outdated = None
        self._set_busy(False)
        if success:
            self.update_completed.emit(self._install_worker._update_bridge if self._install_worker else False, self._install_worker._update_game if self._install_worker else False)
            self._show_update_complete_dialog()

    def _show_update_complete_dialog(self):
        msg = QMessageBox(self)
        msg.setWindowTitle("Update complete")
        msg.setText("Selected components were updated successfully.")
        msg.setStandardButtons(QMessageBox.StandardButton.Ok)
        msg.setStyleSheet(
            f"QMessageBox {{ background-color: {CLR_WIDGET_BG}; }}"
            f"QMessageBox QLabel {{ color: {CLR_TEXT_BRIGHT}; font-size: 17px; font-weight: bold; min-width: 340px; min-height: 60px; }}"
            f"QPushButton {{ background-color: {CLR_ACTIVE_BTN}; color: white; font-size: 15px; font-weight: bold; "
            f"border-radius: 4px; padding: 8px 24px; min-width: 80px; }}"
            f"QPushButton:hover {{ background-color: #5384e8; }}"
        )
        msg.exec()

    @Slot(str)
    def _on_install_error(self, message):
        self._set_busy(False)
        self._set_status(f"Update failed: {message}", False)
        QMessageBox.critical(self, "Update failed", message)

    @Slot(str)
    def _on_restart_needed(self, script_path):
        self._set_status("Update installed. Restarting...", True)
        updater_service.launch_update_script(script_path)
        self.restart_requested.emit()

    @Slot()
    def _cleanup_install_thread(self):
        if self._install_worker is not None:
            self._install_worker.deleteLater()
        if self._install_thread is not None:
            self._install_thread.deleteLater()
        self._install_worker = None
        self._install_thread = None