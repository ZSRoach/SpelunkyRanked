"""Fastest Times page showing global top 3 records per category."""

import threading

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QScrollArea,
    QFrame,
    QComboBox,
)

import api_client
from rank_utils import create_rank_icon, apply_rank_label_style
from config import CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_ACTIVE_BTN, CLR_UNRANKED, format_time


class FastestTimesPage(QWidget):
    """Global fastest completion times per category."""

    _data_loaded = Signal(object)
    _seasons_loaded = Signal(dict)

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._seasons_fetched = False
        self._current_season = "alltime"  # default: all time (excludes S0)
        self._setup_ui()
        self._data_loaded.connect(self._populate_data)
        self._seasons_loaded.connect(self._populate_season_dropdown)

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        # Header — same size as leaderboard
        header = QLabel("Fastest Times")
        header.setStyleSheet(f"color: {CLR_ACTIVE_BTN}; font-size: 36px; font-weight: bold;")
        header.setAlignment(Qt.AlignCenter)
        layout.addWidget(header)

        # Season dropdown (under header, non-scrolling)
        dropdown_row = QHBoxLayout()
        dropdown_row.addStretch()
        self._season_combo = QComboBox()
        self._season_combo.setFixedWidth(190)
        self._season_combo.setFixedHeight(36)
        self._season_combo.setStyleSheet(
            f"QComboBox {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"border: 1px solid #4a4e7a; border-radius: 4px; font-size: 21px; "
            f"padding: 0 8px; text-align: center; }}"
            f"QComboBox::drop-down {{ border: none; width: 0; }}"
            f"QComboBox QAbstractItemView {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"selection-background-color: #3e4278; }}"
        )
        self._season_combo.addItem("All Time", userData="alltime")
        self._season_combo.currentIndexChanged.connect(self._on_season_changed)
        dropdown_row.addWidget(self._season_combo)
        dropdown_row.addStretch()
        layout.addLayout(dropdown_row)

        # Scroll area — hidden scrollbar
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        scroll.setStyleSheet(
            "QScrollArea { border: none; background-color: transparent; }"
        )

        self._list_container = QWidget()
        self._list_layout = QVBoxLayout(self._list_container)
        self._list_layout.setContentsMargins(0, 0, 0, 0)
        self._list_layout.setSpacing(12)
        self._list_layout.addStretch()

        scroll.setWidget(self._list_container)
        self._scroll = scroll
        layout.addWidget(scroll, stretch=1)

        # Loading label
        self._loading_label = QLabel("Loading...")
        self._loading_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
        self._loading_label.setAlignment(Qt.AlignCenter)
        self._loading_label.hide()
        layout.addWidget(self._loading_label)

    def showEvent(self, event):
        super().showEvent(event)
        if not self._seasons_fetched:
            self._fetch_seasons()
        self._fetch_data()

    def _fetch_seasons(self):
        def _do():
            try:
                data = api_client.get_seasons()
                self._seasons_loaded.emit(data)
            except Exception:
                pass
        threading.Thread(target=_do, daemon=True).start()

    def _populate_season_dropdown(self, data: dict):
        self._seasons_fetched = True
        current = data.get("current_season", 0)

        prev_season = self._current_season

        self._season_combo.blockSignals(True)
        self._season_combo.clear()

        self._season_combo.addItem("All Time", userData="alltime")

        # All seasons from current down to 0
        for s in range(current, -1, -1):
            label = f"Season {s} (Current)" if s == current else f"Season {s}"
            self._season_combo.addItem(label, userData=s)

        # Restore previous selection
        for i in range(self._season_combo.count()):
            if self._season_combo.itemData(i) == prev_season:
                self._season_combo.setCurrentIndex(i)
                break

        self._season_combo.blockSignals(False)
        self._current_season = self._season_combo.currentData()

    def _on_season_changed(self, index: int):
        self._current_season = self._season_combo.currentData()
        self._fetch_data()

    def _fetch_data(self):
        self._loading_label.show()
        season = self._current_season

        def _do():
            try:
                data = api_client.get_fastest_times(season=season)
                self._data_loaded.emit(data)
            except Exception:
                self._data_loaded.emit({})

        threading.Thread(target=_do, daemon=True).start()

    def _populate_data(self, data: dict):
        self._loading_label.hide()

        # Save scroll position before clearing
        saved_scroll = self._scroll.verticalScrollBar().value()

        # Clear existing widgets (except trailing stretch)
        while self._list_layout.count() > 1:
            item = self._list_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        for category, records in data.items():
            section = self._create_category_section(category, records)
            self._list_layout.insertWidget(self._list_layout.count() - 1, section)

        # Delay scroll restore to let deleteLater() and layout fully settle
        from PySide6.QtCore import QTimer
        QTimer.singleShot(50, lambda sv=saved_scroll: self._scroll.verticalScrollBar().setValue(sv))

    def _create_category_section(self, category: str, records: list) -> QWidget:
        """Create a category section with header bar + records container."""
        section = QWidget()
        section_layout = QVBoxLayout(section)
        section_layout.setContentsMargins(0, 0, 0, 0)
        section_layout.setSpacing(0)

        # Category header bar (like leaderboard header)
        header_bar = QFrame()
        header_bar.setStyleSheet(
            f"QFrame {{ background-color: {CLR_BUTTON_BG}; "
            f"border-top-left-radius: 4px; border-top-right-radius: 4px; }}"
        )
        header_layout = QHBoxLayout(header_bar)
        header_layout.setContentsMargins(16, 10, 16, 10)

        cat_label = QLabel(category)
        cat_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 28px; font-weight: bold;")
        header_layout.addWidget(cat_label)
        header_layout.addStretch()

        section_layout.addWidget(header_bar)

        # Records container (bordered, linked to header)
        records_frame = QFrame()
        records_frame.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; "
            f"border-bottom-left-radius: 4px; border-bottom-right-radius: 4px; }}"
        )
        records_layout = QVBoxLayout(records_frame)
        records_layout.setContentsMargins(0, 0, 0, 0)
        records_layout.setSpacing(0)

        if not records:
            empty = QLabel("  No records yet")
            empty.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold; padding: 12px 16px;")
            records_layout.addWidget(empty)
        else:
            for i, entry in enumerate(records):
                row = self._create_record_row(entry)
                records_layout.addWidget(row)
                # Add separator between rows (not after last)
                if i < len(records) - 1:
                    sep = QFrame()
                    sep.setFixedHeight(1)
                    sep.setStyleSheet(f"background-color: {CLR_BUTTON_BG};")
                    records_layout.addWidget(sep)

        section_layout.addWidget(records_frame)
        return section

    def _create_record_row(self, entry: dict) -> QWidget:
        row = QWidget()
        row.setStyleSheet("background: transparent;")
        layout = QHBoxLayout(row)
        layout.setContentsMargins(16, 10, 16, 10)

        rank = entry.get("rank", 0)
        rank_label = QLabel(f"{rank}.")
        rank_label.setFixedWidth(30)
        rank_label.setAlignment(Qt.AlignCenter)
        rank_label.setStyleSheet(self._rank_style(rank))
        layout.addWidget(rank_label)

        elo = entry.get("elo", 0)
        name = entry.get("player_name", "Unknown")

        if elo == -1:
            # Unranked player: name in unranked color, no icon, no "[Unranked]" text
            name_label = QLabel(name)
            name_label.setStyleSheet(f"color: {CLR_UNRANKED}; font-size: 24px; font-weight: bold;")
            layout.addWidget(name_label, stretch=1)
        else:
            icon = create_rank_icon(elo, size=24)
            layout.addWidget(icon)
            name_label = QLabel(name)
            apply_rank_label_style(name_label, elo, 24)
            layout.addWidget(name_label, stretch=1)

        time_label = QLabel(format_time(entry.get("completion_time", 0)))
        time_label.setFixedWidth(140)
        time_label.setAlignment(Qt.AlignCenter)
        time_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
        layout.addWidget(time_label)

        return row

    @staticmethod
    def _rank_style(rank: int) -> str:
        if rank == 1:
            return "color: #ffd700; font-size: 24px; font-weight: bold;"
        elif rank == 2:
            return "color: #c0c0c0; font-size: 24px; font-weight: bold;"
        elif rank == 3:
            return "color: #cd7f32; font-size: 24px; font-weight: bold;"
        return f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;"
