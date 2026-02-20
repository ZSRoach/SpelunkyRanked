"""Match History page with My Matches / All Matches toggle and pagination."""

import threading

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QFontMetrics
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QScrollArea,
    QFrame,
)

import match_cache
from rank_utils import create_rank_icon
from config import CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_ACTIVE_BTN, CLR_TEXT, CLR_TEXT_BRIGHT, format_time, relative_time


def _elo_change_text(change: int) -> str:
    return f"+{change}" if change >= 0 else str(change)



def _make_name_label(text: str, color: str, alignment: Qt.AlignmentFlag, max_width: int = 180) -> "QLabel":
    """Create a player name label that shrinks font size to fit within max_width."""
    size = 24
    f = QFont()
    f.setPixelSize(size)
    f.setBold(True)
    while size > 10 and QFontMetrics(f).horizontalAdvance(text) > max_width:
        size -= 2
        f.setPixelSize(size)
    lbl = QLabel(text)
    lbl.setStyleSheet(f"background: transparent; color: {color}; font-size: {size}px; font-weight: bold;")
    lbl.setFixedWidth(max_width)
    lbl.setAlignment(alignment)
    return lbl


class MatchCard(QFrame):
    """A single match entry displayed as a horizontal card."""

    clicked = Signal(dict)

    def __init__(self, match_data: dict, parent=None):
        super().__init__(parent)
        self._data = match_data
        self.setCursor(Qt.PointingHandCursor)
        self.setFixedHeight(96)
        self.setStyleSheet(
            f"MatchCard {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 8px; }}"
            f"MatchCard:hover {{ background-color: {CLR_BUTTON_BG}; }}"
        )

        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 4, 12, 4)
        layout.setSpacing(8)

        p1_id = match_data.get("player_1_id", "")
        p2_id = match_data.get("player_2_id", "")
        winner_id = match_data.get("winner_id", "")
        p1_elo = match_data.get("player_1_elo", 0)
        p2_elo = match_data.get("player_2_elo", 0)
        category = match_data.get("category", "")
        comp_time = match_data.get("completion_time", 0)
        match_type = match_data.get("match_type", "normal")

        if match_type == "draw":
            p1_color = CLR_TEXT_BRIGHT
            p2_color = CLR_TEXT_BRIGHT
            p1_change_color = "#ffee44"
            p2_change_color = "#ffee44"
            time_str = "Draw"
            time_color = "#ffee44"
        elif match_type == "forfeit":
            p1_color = "#66ff66" if p1_id == winner_id else "#ff6666"
            p2_color = "#66ff66" if p2_id == winner_id else "#ff6666"
            p1_change_color = p1_color
            p2_change_color = p2_color
            time_str = "Forfeit"
            time_color = "#ffaa44"
        else:
            p1_color = "#66ff66" if p1_id == winner_id else "#ff6666"
            p2_color = "#66ff66" if p2_id == winner_id else "#ff6666"
            p1_change_color = p1_color
            p2_change_color = p2_color
            time_str = format_time(comp_time) if comp_time else "—"
            time_color = CLR_TEXT_BRIGHT

        # Player 1 (icon + name + elo), fixed widths keep left/right sides symmetric
        p1_icon = create_rank_icon(p1_elo, size=24)
        layout.addWidget(p1_icon)
        p1_name = _make_name_label(
            match_data.get("player_1_name") or p1_id, p1_color, Qt.AlignLeft | Qt.AlignVCenter
        )
        layout.addWidget(p1_name)
        p1_elo_widget = QWidget()
        p1_elo_widget.setFixedWidth(50)
        p1_elo_widget.setStyleSheet("background: transparent;")
        p1_elo_col = QVBoxLayout(p1_elo_widget)
        p1_elo_col.setSpacing(0)
        p1_elo_col.setContentsMargins(0, 0, 0, 0)
        p1_elo_lbl = QLabel(str(p1_elo))
        p1_elo_lbl.setStyleSheet(f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        p1_elo_lbl.setAlignment(Qt.AlignCenter)
        p1_elo_col.addWidget(p1_elo_lbl)
        p1_change = match_data.get("player_1_elo_change")
        if p1_change is not None:
            p1_change_lbl = QLabel(_elo_change_text(p1_change))
            p1_change_lbl.setStyleSheet(f"background: transparent; color: {p1_change_color}; font-size: 18px; font-weight: bold;")
            p1_change_lbl.setAlignment(Qt.AlignCenter)
            p1_elo_col.addWidget(p1_change_lbl)
        layout.addWidget(p1_elo_widget)

        layout.addStretch()

        # Center: category + time — flanked by equal stretches so it stays at midpoint
        center = QVBoxLayout()
        center.setSpacing(0)
        cat_lbl = QLabel(category)
        cat_lbl.setStyleSheet(f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        cat_lbl.setAlignment(Qt.AlignCenter)
        center.addWidget(cat_lbl)

        time_lbl = QLabel(time_str)
        time_lbl.setStyleSheet(f"background: transparent; color: {time_color}; font-size: 22px; font-weight: bold;")
        time_lbl.setAlignment(Qt.AlignCenter)
        center.addWidget(time_lbl)

        rel_lbl = QLabel(relative_time(match_data.get("match_start_time", "")))
        rel_lbl.setStyleSheet(f"background: transparent; color: {CLR_TEXT}; font-size: 20px;")
        rel_lbl.setAlignment(Qt.AlignCenter)
        center.addWidget(rel_lbl)

        layout.addLayout(center)

        layout.addStretch()

        # Player 2 (elo + name + icon), mirrors player 1 widths exactly
        p2_elo_widget = QWidget()
        p2_elo_widget.setFixedWidth(50)
        p2_elo_widget.setStyleSheet("background: transparent;")
        p2_elo_col = QVBoxLayout(p2_elo_widget)
        p2_elo_col.setSpacing(0)
        p2_elo_col.setContentsMargins(0, 0, 0, 0)
        p2_elo_lbl = QLabel(str(p2_elo))
        p2_elo_lbl.setStyleSheet(f"background: transparent; color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        p2_elo_lbl.setAlignment(Qt.AlignCenter)
        p2_elo_col.addWidget(p2_elo_lbl)
        p2_change = match_data.get("player_2_elo_change")
        if p2_change is not None:
            p2_change_lbl = QLabel(_elo_change_text(p2_change))
            p2_change_lbl.setStyleSheet(f"background: transparent; color: {p2_change_color}; font-size: 18px; font-weight: bold;")
            p2_change_lbl.setAlignment(Qt.AlignCenter)
            p2_elo_col.addWidget(p2_change_lbl)
        layout.addWidget(p2_elo_widget)
        p2_name = _make_name_label(
            match_data.get("player_2_name") or p2_id, p2_color, Qt.AlignRight | Qt.AlignVCenter
        )
        layout.addWidget(p2_name)
        p2_icon = create_rank_icon(p2_elo, size=24)
        layout.addWidget(p2_icon)

    def mousePressEvent(self, event):
        self.clicked.emit(self._data)


class MatchHistoryPage(QWidget):
    """Match history list with toggle and pagination."""

    match_selected = Signal(dict)  # Emitted when a match card is clicked
    _batch_ready = Signal(list)    # Internal signal for thread-safe UI update

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._my_matches_mode = True
        self._offset = 0
        self._matches: list[dict] = []
        self._batch_ready.connect(self._do_append_matches)
        self._setup_ui()

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 16, 24, 16)
        layout.setSpacing(8)

        # Toggle row — centered, 2x bigger buttons
        toggle_row = QHBoxLayout()
        toggle_row.setSpacing(0)
        toggle_row.setAlignment(Qt.AlignCenter)

        self._my_btn = QPushButton("My Matches")
        self._my_btn.setCheckable(True)
        self._my_btn.setChecked(True)
        self._my_btn.setFixedHeight(64)
        self._my_btn.setFixedWidth(180)
        self._my_btn.clicked.connect(lambda: self._set_mode(True))
        toggle_row.addWidget(self._my_btn)

        self._all_btn = QPushButton("All Matches")
        self._all_btn.setCheckable(True)
        self._all_btn.setFixedHeight(64)
        self._all_btn.setFixedWidth(180)
        self._all_btn.clicked.connect(lambda: self._set_mode(False))
        toggle_row.addWidget(self._all_btn)

        layout.addLayout(toggle_row)

        self._update_toggle_style()

        # Scrollable match list with filled border
        self._scroll_frame = QFrame()
        self._scroll_frame.setStyleSheet(
            f"QFrame#matchListFrame {{ background-color: {CLR_WIDGET_BG}; "
            f"border: 2px solid {CLR_BUTTON_BG}; border-radius: 8px; }}"
        )
        self._scroll_frame.setObjectName("matchListFrame")
        scroll_frame_layout = QVBoxLayout(self._scroll_frame)
        scroll_frame_layout.setContentsMargins(4, 4, 4, 4)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.NoFrame)
        scroll_frame_layout.addWidget(scroll)

        self._list_container = QWidget()
        self._list_container.setStyleSheet(f"background-color: {CLR_WIDGET_BG};")
        self._list_layout = QVBoxLayout(self._list_container)
        self._list_layout.setSpacing(4)
        self._list_layout.setContentsMargins(0, 0, 0, 0)

        # Empty state label — centered in the frame
        self._empty_label = QLabel("No matches played.")
        self._empty_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
        self._empty_label.setAlignment(Qt.AlignCenter)
        self._list_layout.addWidget(self._empty_label, stretch=1)

        # Show More button — lives inside the scroll list so it scrolls with the content
        self._more_btn = QPushButton("Show More")
        self._more_btn.setFixedHeight(40)
        self._more_btn.setStyleSheet(
            f"QPushButton {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT}; "
            f"border-radius: 4px; font-size: 24px; font-weight: bold; }}"
            f"QPushButton:hover {{ background-color: #3e4278; }}"
        )
        self._more_btn.clicked.connect(self._load_more)
        self._more_btn.setVisible(False)
        self._list_layout.addWidget(self._more_btn)

        scroll.setWidget(self._list_container)

        layout.addWidget(self._scroll_frame, stretch=1)

    def _update_toggle_style(self):
        active = (
            f"QPushButton {{ background-color: {CLR_ACTIVE_BTN}; color: white; "
            f"border-radius: 4px; font-weight: bold; font-size: 24px; padding: 0 16px; }}"
        )
        inactive = (
            f"QPushButton {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT}; "
            f"border-radius: 4px; font-weight: bold; font-size: 24px; padding: 0 16px; }}"
            f"QPushButton:hover {{ background-color: #3e4278; }}"
        )
        self._my_btn.setStyleSheet(active if self._my_matches_mode else inactive)
        self._all_btn.setStyleSheet(inactive if self._my_matches_mode else active)
        self._my_btn.setChecked(self._my_matches_mode)
        self._all_btn.setChecked(not self._my_matches_mode)

    def _set_mode(self, my_matches: bool):
        if self._my_matches_mode == my_matches:
            return
        self._my_matches_mode = my_matches
        self._update_toggle_style()
        self._offset = 0
        self._matches.clear()
        self._clear_list()
        self.refresh()

    def showEvent(self, event):
        super().showEvent(event)
        if not self._matches:
            self.refresh()

    def refresh(self):
        self._offset = 0
        self._matches.clear()
        self._clear_list()
        self._load_batch()

    def _load_more(self):
        self._load_batch()

    def _load_batch(self):
        def _do():
            try:
                if self._my_matches_mode:
                    # Try cache first for offset 0
                    if self._offset == 0:
                        cached = match_cache.load_cached_matches()
                        if cached:
                            batch = cached[:10]
                            self._offset = len(cached)
                            self._append_matches(batch)
                            return
                    batch = self._controller.fetch_my_matches(
                        offset=self._offset, limit=10
                    )
                else:
                    batch = self._controller.fetch_all_matches(
                        offset=self._offset, limit=10
                    )
                self._offset += len(batch)
                self._append_matches(batch)
            except Exception:
                pass

        threading.Thread(target=_do, daemon=True).start()

    def _append_matches(self, batch: list[dict]):
        # Emit signal to update UI on the main thread
        self._batch_ready.emit(batch)

    def _do_append_matches(self, batch):
        if not isinstance(batch, list):
            return

        # Hide empty label once we have matches
        if batch:
            self._empty_label.setVisible(False)

        for m in batch:
            # Add divider before card if there are already matches
            if self._matches:
                divider = QFrame()
                divider.setFrameShape(QFrame.HLine)
                divider.setStyleSheet(f"background-color: {CLR_BUTTON_BG}; max-height: 1px;")
                idx = self._list_layout.count() - 1
                self._list_layout.insertWidget(idx, divider)

            self._matches.append(m)
            card = MatchCard(m)
            card.clicked.connect(self.match_selected.emit)
            # Insert before the stretch
            idx = self._list_layout.count() - 1
            self._list_layout.insertWidget(idx, card)

        self._more_btn.setVisible(len(batch) >= 10)

        # Show empty label if still no matches
        if not self._matches:
            self._empty_label.setVisible(True)

    def _clear_list(self):
        # Keep the empty label and trailing stretch
        while self._list_layout.count() > 2:  # keep empty_label + stretch
            item = self._list_layout.takeAt(1)  # take after empty_label
            if item.widget():
                item.widget().deleteLater()
        self._empty_label.setVisible(True)
