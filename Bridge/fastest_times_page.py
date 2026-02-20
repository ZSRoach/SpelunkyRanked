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
)

import api_client
from rank_utils import create_rank_icon, apply_rank_label_style
from config import CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_ACTIVE_BTN, format_time


class FastestTimesPage(QWidget):
    """Global fastest completion times per category."""

    _data_loaded = Signal(object)

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._setup_ui()
        self._data_loaded.connect(self._populate_data)

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        # Header — same size as leaderboard
        header = QLabel("Fastest Times")
        header.setStyleSheet(f"color: {CLR_ACTIVE_BTN}; font-size: 36px; font-weight: bold;")
        header.setAlignment(Qt.AlignCenter)
        layout.addWidget(header)

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
        self._fetch_data()

    def _fetch_data(self):
        self._loading_label.show()

        def _do():
            try:
                data = api_client.get_fastest_times()
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

        # Rank icon adjacent to player name
        elo = entry.get("elo", 0)
        icon = create_rank_icon(elo, size=24)
        layout.addWidget(icon)

        name = entry.get("player_name", "Unknown")
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
