"""Expanded Match View with top summary and progress timeline."""

from PySide6.QtCore import Qt
from PySide6.QtGui import QFont, QFontMetrics, QPixmap
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QFrame,
    QScrollArea,
)

from rank_utils import create_rank_icon, get_rank_icon_path
from config import CLR_WIDGET_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_ACTIVE_BTN, CLR_BUTTON_BG, CLR_MAIN_BG, RANK_COLORS, format_time, full_match_datetime


def _elo_change_text(change: int) -> str:
    return f"+{change}" if change >= 0 else str(change)



def _apply_name_style(label: "QLabel", text: str, color: str, max_width: int = 180) -> None:
    """Set label text with a font size shrunk to fit within max_width."""
    size = 24
    f = QFont()
    f.setPixelSize(size)
    f.setBold(True)
    while size > 10 and QFontMetrics(f).horizontalAdvance(text) > max_width:
        size -= 2
        f.setPixelSize(size)
    label.setText(text)
    label.setStyleSheet(f"color: {color}; font-size: {size}px; font-weight: bold;")


def _filter_timeline_events(markers: list, player_id: str) -> list:
    """Return timeline events for a player: deaths, restarts, forfeit, and new-furthest-area progress only."""
    filtered = []
    furthest_area = 1  # area 1 is always the starting area, shown as Match Start bar
    for m in markers:
        if m.get("player_id") != player_id:
            continue
        etype = m.get("type", "")
        if etype in ("death", "instant_restart", "forfeit"):
            filtered.append(m)
        elif etype == "progress":
            area = m.get("area", 0)
            if area > furthest_area:
                furthest_area = area
                filtered.append(m)
    return filtered


def _event_color(etype: str) -> str:
    if etype == "progress":
        return "#4a9eff"
    elif etype == "death":
        return "#ff6666"
    elif etype == "instant_restart":
        return "#ffaa44"
    elif etype == "forfeit":
        return "#ff6666"
    return "#aaaaaa"


def _event_text(ev: dict) -> str:
    etype = ev.get("type", "")
    if etype == "progress":
        return f"{ev.get('area', '?')}-{ev.get('level', '?')}"
    elif etype == "death":
        return "Death"
    elif etype == "instant_restart":
        return "Restart"
    elif etype == "forfeit":
        return "Forfeit"
    return etype


def _create_match_start_widget() -> QFrame:
    """Create a full-width Match Start bar for the top of the timeline."""
    frame = QFrame()
    frame.setStyleSheet(
        f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 4px 8px; }}"
    )
    layout = QVBoxLayout(frame)
    layout.setContentsMargins(8, 4, 8, 4)
    label = QLabel("Match Start")
    label.setStyleSheet(
        f"color: {RANK_COLORS['gold']}; font-size: 22px; font-weight: bold; background: transparent;"
    )
    label.setAlignment(Qt.AlignCenter)
    layout.addWidget(label)
    return frame


def _create_finish_widget(comp_time: float) -> QFrame:
    """Create a green Finish toast for the winner."""
    frame = QFrame()
    frame.setStyleSheet(
        f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 4px 8px; }}"
    )
    layout = QVBoxLayout(frame)
    layout.setContentsMargins(8, 4, 8, 4)
    label = QLabel(f"Finish  -  {format_time(comp_time)}")
    label.setStyleSheet("color: #66ff66; font-size: 22px; font-weight: bold; background: transparent;")
    label.setAlignment(Qt.AlignCenter)
    layout.addWidget(label)
    return frame


def _create_event_widget(ev: dict) -> QFrame:
    """Create a single event toast with centered 'event - timestamp' text."""
    frame = QFrame()
    frame.setStyleSheet(
        f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 4px 8px; }}"
    )
    layout = QVBoxLayout(frame)
    layout.setContentsMargins(8, 4, 8, 4)

    etype = ev.get("type", "")
    color = _event_color(etype)
    ts = ev.get("timestamp", 0)

    label = QLabel(f"{_event_text(ev)}  -  {format_time(ts)}")
    label.setStyleSheet(f"color: {color}; font-size: 22px; font-weight: bold; background: transparent;")
    label.setAlignment(Qt.AlignCenter)
    layout.addWidget(label)

    return frame


def _create_win_by_forfeit_widget() -> QFrame:
    """Create a green 'Win by Forfeit' card for the winner's column."""
    frame = QFrame()
    frame.setStyleSheet(
        f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 4px 8px; }}"
    )
    layout = QVBoxLayout(frame)
    layout.setContentsMargins(8, 4, 8, 4)
    label = QLabel("Win by Forfeit")
    label.setStyleSheet("color: #66ff66; font-size: 22px; font-weight: bold; background: transparent;")
    label.setAlignment(Qt.AlignCenter)
    layout.addWidget(label)
    return frame


def _create_draw_end_widget() -> QFrame:
    """Create a full-width 'Match Ended In A Draw' yellow bar for the bottom of the timeline."""
    frame = QFrame()
    frame.setStyleSheet(
        f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 6px; padding: 4px 8px; }}"
    )
    layout = QVBoxLayout(frame)
    layout.setContentsMargins(8, 4, 8, 4)
    label = QLabel("Match Ended In A Draw")
    label.setStyleSheet("color: #ffee44; font-size: 22px; font-weight: bold; background: transparent;")
    label.setAlignment(Qt.AlignCenter)
    layout.addWidget(label)
    return frame


class TimelineWidget(QWidget):
    """Full-width Match Start bar + two-column progress timeline (P1 left, P2 right)."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self._root = QVBoxLayout(self)
        self._root.setContentsMargins(0, 0, 0, 0)
        self._root.setSpacing(4)

        # Match Start bar (full-width, replaced dynamically in load())
        self._match_start_bar = _create_match_start_widget()
        self._root.addWidget(self._match_start_bar)

        # Two-column area
        columns = QHBoxLayout()
        columns.setContentsMargins(0, 0, 0, 0)
        columns.setSpacing(8)

        self._p1_col = QVBoxLayout()
        self._p1_col.setSpacing(4)
        self._p1_col.setContentsMargins(0, 0, 0, 0)

        self._p2_col = QVBoxLayout()
        self._p2_col.setSpacing(4)
        self._p2_col.setContentsMargins(0, 0, 0, 0)

        columns.addLayout(self._p1_col, stretch=1)

        divider = QFrame()
        divider.setFrameShape(QFrame.VLine)
        divider.setStyleSheet(f"color: {CLR_BUTTON_BG};")
        columns.addWidget(divider)

        columns.addLayout(self._p2_col, stretch=1)
        self._root.addLayout(columns)

        self._draw_end_bar: QFrame | None = None

    def load(self, match_data: dict):
        # Clear columns
        for col in (self._p1_col, self._p2_col):
            while col.count():
                item = col.takeAt(0)
                if item.widget():
                    item.widget().deleteLater()

        # Remove previous draw end bar if present
        if self._draw_end_bar is not None:
            self._root.removeWidget(self._draw_end_bar)
            self._draw_end_bar.deleteLater()
            self._draw_end_bar = None

        markers = match_data.get("progress_markers", [])
        p1 = match_data.get("player_1_id", "")
        p2 = match_data.get("player_2_id", "")
        winner = match_data.get("winner_id")
        comp_time = match_data.get("completion_time")
        match_type = match_data.get("match_type", "normal")
        forfeit_player_id = match_data.get("forfeit_player_id")

        p1_events = _filter_timeline_events(markers, p1)
        p2_events = _filter_timeline_events(markers, p2)

        for ev in p1_events:
            self._p1_col.addWidget(_create_event_widget(ev))

        for ev in p2_events:
            self._p2_col.addWidget(_create_event_widget(ev))

        if match_type == "forfeit" and forfeit_player_id:
            # Forfeit card already rendered via _filter_timeline_events for the forfeiting player.
            # Add Win by Forfeit to the winner's column.
            wbf = _create_win_by_forfeit_widget()
            if winner == p1:
                self._p1_col.addWidget(wbf)
            else:
                self._p2_col.addWidget(wbf)
        elif match_type == "normal" and winner and comp_time:
            finish_widget = _create_finish_widget(comp_time)
            if winner == p1:
                self._p1_col.addWidget(finish_widget)
            else:
                self._p2_col.addWidget(finish_widget)

        self._p1_col.addStretch()
        self._p2_col.addStretch()

        if match_type == "draw":
            self._draw_end_bar = _create_draw_end_widget()
            self._root.addWidget(self._draw_end_bar)


class MatchDetailPage(QWidget):
    """Expanded match view with summary header and progress timeline."""

    # Navigation back is handled via a callback set by main_window

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._back_callback = None
        self._setup_ui()

    def set_back_callback(self, cb):
        self._back_callback = cb

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 12)
        layout.setSpacing(8)

        # Back button
        self._back_btn = QPushButton("\u2190 Back")
        self._back_btn.setFixedWidth(120)
        self._back_btn.setStyleSheet(
            f"QPushButton {{ background: transparent; color: {CLR_ACTIVE_BTN}; "
            f"font-size: 24px; font-weight: bold; border: none; text-align: left; }}"
            f"QPushButton:hover {{ color: #7abfff; }}"
        )
        self._back_btn.clicked.connect(self._on_back)
        layout.addWidget(self._back_btn)

        # Played on date/time
        self._played_on_label = QLabel()
        self._played_on_label.setStyleSheet(f"color: {CLR_TEXT}; font-size: 20px;")
        self._played_on_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self._played_on_label)

        # Top summary
        self._summary_frame = QFrame()
        self._summary_frame.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 8px; }}"
        )
        self._summary_layout = QHBoxLayout(self._summary_frame)
        self._summary_layout.setContentsMargins(8, 8, 8, 8)
        self._summary_layout.setSpacing(0)

        # P1 group: icon, name, elo — tightly spaced
        p1_group = QHBoxLayout()
        p1_group.setSpacing(6)
        p1_group.setContentsMargins(0, 0, 0, 0)

        self._p1_icon = QLabel()
        self._p1_icon.setFixedSize(24, 24)
        self._p1_icon.setMinimumSize(24, 24)
        self._p1_icon.setStyleSheet("background: transparent;")
        p1_group.addWidget(self._p1_icon, alignment=Qt.AlignVCenter)

        self._p1_label = QLabel()
        self._p1_label.setStyleSheet("font-size: 24px; font-weight: bold;")
        self._p1_label.setMaximumWidth(180)
        p1_group.addWidget(self._p1_label, alignment=Qt.AlignVCenter)

        p1_elo_container = QWidget()
        p1_elo_container.setStyleSheet("background: transparent;")
        p1_elo_col = QVBoxLayout(p1_elo_container)
        p1_elo_col.setSpacing(0)
        p1_elo_col.setContentsMargins(0, 0, 0, 0)
        self._p1_elo_label = QLabel()
        self._p1_elo_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        self._p1_elo_label.setAlignment(Qt.AlignCenter)
        p1_elo_col.addWidget(self._p1_elo_label)
        self._p1_elo_change_label = QLabel()
        self._p1_elo_change_label.setAlignment(Qt.AlignCenter)
        self._p1_elo_change_label.setVisible(False)
        p1_elo_col.addWidget(self._p1_elo_change_label)
        p1_group.addWidget(p1_elo_container, alignment=Qt.AlignVCenter)

        # P1 wrapper: centers p1_group within the left half
        p1_wrapper = QHBoxLayout()
        p1_wrapper.setSpacing(0)
        p1_wrapper.addStretch()
        p1_wrapper.addLayout(p1_group)
        p1_wrapper.addStretch()

        # Center: category + time (always at true center)
        center_col = QVBoxLayout()
        center_col.setSpacing(0)
        self._cat_label = QLabel()
        self._cat_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
        self._cat_label.setAlignment(Qt.AlignCenter)
        center_col.addWidget(self._cat_label)
        self._time_label = QLabel()
        self._time_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        self._time_label.setAlignment(Qt.AlignCenter)
        center_col.addWidget(self._time_label)

        # P2 group: elo, name, icon — tightly spaced
        p2_group = QHBoxLayout()
        p2_group.setSpacing(6)
        p2_group.setContentsMargins(0, 0, 0, 0)

        p2_elo_container = QWidget()
        p2_elo_container.setStyleSheet("background: transparent;")
        p2_elo_col = QVBoxLayout(p2_elo_container)
        p2_elo_col.setSpacing(0)
        p2_elo_col.setContentsMargins(0, 0, 0, 0)
        self._p2_elo_label = QLabel()
        self._p2_elo_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold;")
        self._p2_elo_label.setAlignment(Qt.AlignCenter)
        p2_elo_col.addWidget(self._p2_elo_label)
        self._p2_elo_change_label = QLabel()
        self._p2_elo_change_label.setAlignment(Qt.AlignCenter)
        self._p2_elo_change_label.setVisible(False)
        p2_elo_col.addWidget(self._p2_elo_change_label)
        p2_group.addWidget(p2_elo_container, alignment=Qt.AlignVCenter)

        self._p2_label = QLabel()
        self._p2_label.setStyleSheet("font-size: 24px; font-weight: bold;")
        self._p2_label.setAlignment(Qt.AlignRight)
        self._p2_label.setMaximumWidth(180)
        p2_group.addWidget(self._p2_label, alignment=Qt.AlignVCenter)

        self._p2_icon = QLabel()
        self._p2_icon.setFixedSize(24, 24)
        self._p2_icon.setMinimumSize(24, 24)
        self._p2_icon.setStyleSheet("background: transparent;")
        p2_group.addWidget(self._p2_icon, alignment=Qt.AlignVCenter)

        # P2 wrapper: centers p2_group within the right half
        p2_wrapper = QHBoxLayout()
        p2_wrapper.setSpacing(0)
        p2_wrapper.addStretch()
        p2_wrapper.addLayout(p2_group)
        p2_wrapper.addStretch()

        # Lock center by giving each side equal stretch
        self._summary_layout.addLayout(p1_wrapper, 1)
        self._summary_layout.addLayout(center_col, 0)
        self._summary_layout.addLayout(p2_wrapper, 1)

        layout.addWidget(self._summary_frame)

        # Timeline
        timeline_header = QLabel("Progress Timeline")
        timeline_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
        timeline_header.setAlignment(Qt.AlignCenter)
        layout.addWidget(timeline_header)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.NoFrame)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        layout.addWidget(scroll, stretch=1)

        self._timeline = TimelineWidget()
        scroll.setWidget(self._timeline)

    def load_match(self, match_data: dict):
        p1 = match_data.get("player_1_id", "")
        p2 = match_data.get("player_2_id", "")
        winner = match_data.get("winner_id", "")
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
        else:
            p1_color = "#66ff66" if p1 == winner else "#ff6666"
            p2_color = "#66ff66" if p2 == winner else "#ff6666"
            p1_change_color = p1_color
            p2_change_color = p2_color

        p1_name = match_data.get("player_1_name") or p1
        p2_name = match_data.get("player_2_name") or p2

        _apply_name_style(self._p1_label, p1_name, p1_color)
        self._p1_elo_label.setText(str(p1_elo))
        p1_elo_change = match_data.get("player_1_elo_change")
        if p1_elo_change is not None:
            self._p1_elo_change_label.setText(_elo_change_text(p1_elo_change))
            self._p1_elo_change_label.setStyleSheet(f"color: {p1_change_color}; font-size: 18px; font-weight: bold;")
            self._p1_elo_change_label.setVisible(True)
        else:
            self._p1_elo_change_label.setVisible(False)

        # Update P1 rank icon
        p1_pixmap = QPixmap(get_rank_icon_path(p1_elo))
        if not p1_pixmap.isNull():
            self._p1_icon.setPixmap(
                p1_pixmap.scaled(24, 24, Qt.KeepAspectRatio, Qt.SmoothTransformation)
            )

        _apply_name_style(self._p2_label, p2_name, p2_color)
        self._p2_elo_label.setText(str(p2_elo))
        p2_elo_change = match_data.get("player_2_elo_change")
        if p2_elo_change is not None:
            self._p2_elo_change_label.setText(_elo_change_text(p2_elo_change))
            self._p2_elo_change_label.setStyleSheet(f"color: {p2_change_color}; font-size: 18px; font-weight: bold;")
            self._p2_elo_change_label.setVisible(True)
        else:
            self._p2_elo_change_label.setVisible(False)

        # Update P2 rank icon
        p2_pixmap = QPixmap(get_rank_icon_path(p2_elo))
        if not p2_pixmap.isNull():
            self._p2_icon.setPixmap(
                p2_pixmap.scaled(24, 24, Qt.KeepAspectRatio, Qt.SmoothTransformation)
            )

        self._cat_label.setText(category)
        self._time_label.setText(format_time(comp_time) if comp_time else "—")

        self._played_on_label.setText(full_match_datetime(match_data.get("match_start_time", "")))
        self._timeline.load(match_data)

    def _on_back(self):
        if self._back_callback:
            self._back_callback()
