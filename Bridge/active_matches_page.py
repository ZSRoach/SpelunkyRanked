"""Active matches page showing live and recently-finished matches."""

from datetime import datetime, timezone

from PySide6.QtCore import Qt, QTimer
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QFrame,
    QScrollArea,
)

from config import (
    THEME_NAMES, FINISHED_MATCH_DISPLAY_SECONDS,
    CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_ACTIVE_BTN,
)
from rank_utils import create_rank_icon, apply_rank_label_style


class ActiveMatchToast(QFrame):
    """Card displaying a single active match — styled to match MatchCard."""

    def __init__(self, match_data: dict, parent=None):
        super().__init__(parent)
        self.match_id = match_data["match_id"]
        self._match_data = match_data
        self.setFixedHeight(90)
        self.setStyleSheet(
            f"ActiveMatchToast {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 8px; }}"
        )
        self._build_ui(match_data)

    def _build_ui(self, d: dict) -> None:
        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 4, 12, 4)
        layout.setSpacing(8)

        # ---- Player 1 (left) ----
        p1_section = QVBoxLayout()
        p1_section.setSpacing(2)

        p1_top = QHBoxLayout()
        p1_top.setSpacing(4)

        self._p1_icon = create_rank_icon(d["player_1_elo"], size=24)
        p1_top.addWidget(self._p1_icon)

        self._p1_name = QLabel(d["player_1_name"])
        apply_rank_label_style(self._p1_name, d["player_1_elo"], 24, "background: transparent;")
        self._p1_name.setFixedWidth(140)
        self._p1_name.setAlignment(Qt.AlignLeft | Qt.AlignVCenter)
        p1_top.addWidget(self._p1_name)

        self._p1_elo = QLabel(str(d["player_1_elo"]))
        self._p1_elo.setStyleSheet(
            f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;"
        )
        self._p1_elo.setFixedWidth(50)
        self._p1_elo.setAlignment(Qt.AlignCenter)
        p1_top.addWidget(self._p1_elo)

        p1_section.addLayout(p1_top)

        self._p1_area = QLabel(self._area_text(d.get("player_1_area", 0), d.get("player_1_theme", 0)))
        self._p1_area.setStyleSheet(
            f"background: transparent; color: {CLR_ACTIVE_BTN}; font-size: 24px; font-weight: bold;"
        )
        self._p1_area.setAlignment(Qt.AlignLeft | Qt.AlignVCenter)
        p1_section.addWidget(self._p1_area)

        layout.addLayout(p1_section)

        layout.addStretch()

        # ---- Center: time / category ----
        center = QVBoxLayout()
        center.setSpacing(0)

        cat_label = QLabel(d.get("category", ""))
        cat_label.setStyleSheet(
            f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;"
        )
        cat_label.setAlignment(Qt.AlignCenter)
        center.addWidget(cat_label)

        self._time_label = QLabel(self._time_text(d))
        self._time_label.setStyleSheet(
            f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;"
        )
        self._time_label.setAlignment(Qt.AlignCenter)
        center.addWidget(self._time_label)

        layout.addLayout(center)

        layout.addStretch()

        # ---- Player 2 (right) ----
        p2_section = QVBoxLayout()
        p2_section.setSpacing(2)

        p2_top = QHBoxLayout()
        p2_top.setSpacing(4)

        self._p2_elo = QLabel(str(d["player_2_elo"]))
        self._p2_elo.setStyleSheet(
            f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;"
        )
        self._p2_elo.setFixedWidth(50)
        self._p2_elo.setAlignment(Qt.AlignCenter)
        p2_top.addWidget(self._p2_elo)

        self._p2_name = QLabel(d["player_2_name"])
        apply_rank_label_style(self._p2_name, d["player_2_elo"], 24, "background: transparent;")
        self._p2_name.setFixedWidth(140)
        self._p2_name.setAlignment(Qt.AlignRight | Qt.AlignVCenter)
        p2_top.addWidget(self._p2_name)

        self._p2_icon = create_rank_icon(d["player_2_elo"], size=24)
        p2_top.addWidget(self._p2_icon)

        p2_section.addLayout(p2_top)

        self._p2_area = QLabel(self._area_text(d.get("player_2_area", 0), d.get("player_2_theme", 0)))
        self._p2_area.setStyleSheet(
            f"background: transparent; color: {CLR_ACTIVE_BTN}; font-size: 24px; font-weight: bold;"
        )
        self._p2_area.setAlignment(Qt.AlignRight | Qt.AlignVCenter)
        p2_section.addWidget(self._p2_area)

        layout.addLayout(p2_section)

    @staticmethod
    def _area_text(area: int, theme: int) -> str:
        if area > 0 and theme in THEME_NAMES:
            return f"Entered {THEME_NAMES[theme]}"
        return ""

    @staticmethod
    def _time_text(d: dict) -> str:
        start_str = d.get("match_start_time")
        if not start_str:
            return ""
        try:
            start = datetime.fromisoformat(start_str)
            elapsed = (datetime.now(timezone.utc) - start).total_seconds()
            minutes = max(0, int(elapsed // 60))
            if minutes == 0:
                return "Started just now"
            elif minutes == 1:
                return "Started 1 minute ago"
            else:
                return f"Started {minutes} minutes ago"
        except (ValueError, TypeError):
            return ""

    def update_data(self, d: dict) -> None:
        """Refresh time and area labels in-place (no widget rebuild)."""
        self._match_data = d
        self._p1_area.setText(self._area_text(d.get("player_1_area", 0), d.get("player_1_theme", 0)))
        self._p2_area.setText(self._area_text(d.get("player_2_area", 0), d.get("player_2_theme", 0)))
        self._time_label.setText(self._time_text(d))

    def mark_finished(self, winner_id: str) -> None:
        """Highlight the winner's name in gold + underline. Update time to 'Finished just now'."""
        gold_style = (
            "background: transparent; color: #FFD700; font-size: 24px; "
            "font-weight: bold; text-decoration: underline;"
        )
        if winner_id == self._match_data.get("player_1_id"):
            self._p1_name.setStyleSheet(gold_style)
        elif winner_id == self._match_data.get("player_2_id"):
            self._p2_name.setStyleSheet(gold_style)
        self._time_label.setText("Finished just now")


class ActiveMatchesPage(QWidget):
    """Scrollable list of active and recently-finished matches."""

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._known_match_ids: set[int] = set()
        self._toast_widgets: dict[int, ActiveMatchToast] = {}
        self._finished_timers: dict[int, QTimer] = {}

        self._setup_ui()
        self._controller.active_matches_updated.connect(self._on_data)

    def _setup_ui(self) -> None:
        outer = QVBoxLayout(self)
        outer.setContentsMargins(24, 16, 24, 16)
        outer.setSpacing(8)

        # Scrollable match list with filled border — matches match history style
        self._scroll_frame = QFrame()
        self._scroll_frame.setStyleSheet(
            f"QFrame#activeMatchListFrame {{ background-color: {CLR_WIDGET_BG}; "
            f"border: 2px solid {CLR_BUTTON_BG}; border-radius: 8px; }}"
        )
        self._scroll_frame.setObjectName("activeMatchListFrame")
        scroll_frame_layout = QVBoxLayout(self._scroll_frame)
        scroll_frame_layout.setContentsMargins(4, 4, 4, 4)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.NoFrame)
        scroll_frame_layout.addWidget(scroll)

        self._container = QWidget()
        self._container.setStyleSheet(f"background-color: {CLR_WIDGET_BG};")
        self._list_layout = QVBoxLayout(self._container)
        self._list_layout.setContentsMargins(0, 0, 0, 0)
        self._list_layout.setSpacing(4)

        self._empty_label = QLabel("No Matches In Progress")
        self._empty_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
        self._empty_label.setAlignment(Qt.AlignCenter)
        self._list_layout.addWidget(self._empty_label, stretch=1)

        self._list_layout.addStretch()

        scroll.setWidget(self._container)
        outer.addWidget(self._scroll_frame, stretch=1)

    def _on_data(self, data: dict) -> None:
        active_list = data.get("active_matches", [])
        recently_finished_list = data.get("recently_finished", [])

        active_ids = {m["match_id"] for m in active_list}
        active_map = {m["match_id"]: m for m in active_list}
        finished_map = {m["match_id"]: m for m in recently_finished_list}

        # Detect newly finished: was known & active, now absent from active but in recently_finished
        for mid in list(self._known_match_ids):
            if mid not in active_ids and mid in finished_map and mid not in self._finished_timers:
                toast = self._toast_widgets.get(mid)
                if toast:
                    winner_id = finished_map[mid].get("winner_id", "")
                    toast.mark_finished(winner_id)
                    timer = QTimer(self)
                    timer.setSingleShot(True)
                    timer.setInterval(FINISHED_MATCH_DISPLAY_SECONDS * 1000)
                    timer.timeout.connect(lambda m=mid: self._remove_match(m))
                    timer.start()
                    self._finished_timers[mid] = timer

        # Update existing active toasts
        for mid, match_data in active_map.items():
            if mid in self._toast_widgets and mid not in self._finished_timers:
                self._toast_widgets[mid].update_data(match_data)

        # Add new matches (not already displayed), sorted by start time (oldest first)
        new_matches = []
        for m in active_list:
            mid = m["match_id"]
            if mid not in self._toast_widgets:
                new_matches.append(m)
        new_matches.sort(key=lambda m: m.get("match_start_time", ""))

        for m in new_matches:
            mid = m["match_id"]
            toast = ActiveMatchToast(m)
            self._toast_widgets[mid] = toast

            # Add divider before card if there are already matches
            widget_count = sum(1 for w in self._toast_widgets.values() if w is not toast)
            if widget_count > 0:
                divider = QFrame()
                divider.setFrameShape(QFrame.HLine)
                divider.setObjectName(f"divider_{mid}")
                divider.setStyleSheet(f"background-color: {CLR_BUTTON_BG}; max-height: 1px;")
                idx = self._list_layout.count() - 1
                self._list_layout.insertWidget(idx, divider)

            # Insert before the trailing stretch
            idx = self._list_layout.count() - 1
            self._list_layout.insertWidget(idx, toast)

        self._known_match_ids = active_ids | set(self._finished_timers.keys())

        # Update empty state
        has_visible = bool(self._toast_widgets)
        self._empty_label.setVisible(not has_visible)

    def _remove_match(self, match_id: int) -> None:
        """Remove a toast widget and its timer."""
        toast = self._toast_widgets.pop(match_id, None)
        if toast:
            self._list_layout.removeWidget(toast)
            toast.deleteLater()
        # Remove associated divider if present
        for i in range(self._list_layout.count()):
            item = self._list_layout.itemAt(i)
            if item and item.widget() and item.widget().objectName() == f"divider_{match_id}":
                w = item.widget()
                self._list_layout.removeWidget(w)
                w.deleteLater()
                break
        timer = self._finished_timers.pop(match_id, None)
        if timer:
            timer.stop()
        self._known_match_ids.discard(match_id)
        has_visible = bool(self._toast_widgets)
        self._empty_label.setVisible(not has_visible)

    def _clear_all(self) -> None:
        """Remove all toasts and cancel all timers."""
        for timer in self._finished_timers.values():
            timer.stop()
        self._finished_timers.clear()
        for toast in self._toast_widgets.values():
            self._list_layout.removeWidget(toast)
            toast.deleteLater()
        self._toast_widgets.clear()
        self._known_match_ids.clear()
        # Also remove any dividers
        while self._list_layout.count() > 2:  # keep empty_label + stretch
            item = self._list_layout.takeAt(1)
            if item.widget():
                item.widget().deleteLater()
        self._empty_label.setVisible(True)

    def showEvent(self, event) -> None:
        super().showEvent(event)
        self._clear_all()

    def hideEvent(self, event) -> None:
        super().hideEvent(event)
        self._clear_all()
