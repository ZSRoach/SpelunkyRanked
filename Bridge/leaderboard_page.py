"""Leaderboard page showing player rankings by elo."""

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
from config import CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_ACTIVE_BTN


class LeaderboardPage(QWidget):
    """Leaderboard page displaying players ranked by elo."""

    _data_loaded = Signal(list)

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._setup_ui()
        self._data_loaded.connect(self._populate_leaderboard)

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        # Header
        header = QLabel("Leaderboard")
        header.setStyleSheet(f"color: {CLR_ACTIVE_BTN}; font-size: 36px; font-weight: bold;")
        header.setAlignment(Qt.AlignCenter)
        layout.addWidget(header)

        # Column headers
        header_row = QFrame()
        header_row.setStyleSheet(f"QFrame {{ background-color: {CLR_BUTTON_BG}; border-radius: 4px; }}")
        header_layout = QHBoxLayout(header_row)
        header_layout.setContentsMargins(16, 8, 16, 8)

        rank_header = QLabel("#")
        rank_header.setFixedWidth(50)
        rank_header.setAlignment(Qt.AlignCenter)
        rank_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 30px; font-weight: bold;")
        header_layout.addWidget(rank_header)

        name_header = QLabel("Player")
        name_header.setAlignment(Qt.AlignCenter)
        name_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 30px; font-weight: bold;")
        header_layout.addWidget(name_header, stretch=1)

        elo_header = QLabel("Elo")
        elo_header.setFixedWidth(80)
        elo_header.setAlignment(Qt.AlignCenter)
        elo_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 30px; font-weight: bold;")
        header_layout.addWidget(elo_header)

        layout.addWidget(header_row)

        # Scroll area for player list
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        scroll.setStyleSheet(
            "QScrollArea { border: none; background-color: transparent; }"
        )

        self._list_container = QWidget()
        self._list_layout = QVBoxLayout(self._list_container)
        self._list_layout.setContentsMargins(0, 0, 0, 0)
        self._list_layout.setSpacing(4)
        self._list_layout.addStretch()

        scroll.setWidget(self._list_container)
        self._scroll = scroll
        layout.addWidget(scroll, stretch=1)

        # Loading label (shown when fetching)
        self._loading_label = QLabel("Loading...")
        self._loading_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 26px; font-weight: bold;")
        self._loading_label.setAlignment(Qt.AlignCenter)
        self._loading_label.hide()
        layout.addWidget(self._loading_label)

    def showEvent(self, event):
        """Fetch leaderboard data when page becomes visible."""
        super().showEvent(event)
        self._fetch_leaderboard()

    def _fetch_leaderboard(self):
        """Fetch leaderboard in background thread."""
        self._loading_label.show()

        def _do():
            try:
                players = api_client.get_leaderboard()
                self._data_loaded.emit(players)
            except Exception:
                self._data_loaded.emit([])

        threading.Thread(target=_do, daemon=True).start()

    def _populate_leaderboard(self, players: list):
        """Populate the leaderboard with player data."""
        self._loading_label.hide()

        # Save scroll position before clearing
        saved_scroll = self._scroll.verticalScrollBar().value()

        # Clear existing rows (except the stretch at the end)
        while self._list_layout.count() > 1:
            item = self._list_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        # Add player rows
        for i, player in enumerate(players):
            row = self._create_player_row(i + 1, player)
            self._list_layout.insertWidget(self._list_layout.count() - 1, row)

        # Restore scroll position after layout settles
        from PySide6.QtCore import QTimer
        QTimer.singleShot(0, lambda: self._scroll.verticalScrollBar().setValue(saved_scroll))

    def _create_player_row(self, rank: int, player: dict) -> QFrame:
        """Create a row widget for a player."""
        row = QFrame()
        row.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 4px; }}"
        )

        layout = QHBoxLayout(row)
        layout.setContentsMargins(16, 12, 16, 12)

        # Rank number on the left
        rank_label = QLabel(f"{rank}.")
        rank_label.setFixedWidth(50)
        rank_label.setAlignment(Qt.AlignCenter)
        rank_label.setStyleSheet(self._rank_style(rank))
        layout.addWidget(rank_label)

        # Icon + name grouped together (icon adjacent to name)
        elo = player.get("elo", 0)
        name = player.get("player_name", "Unknown")
        name_group = QHBoxLayout()
        name_group.setSpacing(6)
        name_group.addStretch()
        icon = create_rank_icon(elo, size=26)
        name_group.addWidget(icon)
        name_label = QLabel(name)
        apply_rank_label_style(name_label, elo, 26)
        name_group.addWidget(name_label)
        name_group.addStretch()

        layout.addLayout(name_group, stretch=1)

        elo_label = QLabel(str(elo))
        elo_label.setFixedWidth(80)
        elo_label.setAlignment(Qt.AlignCenter)
        elo_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 26px; font-weight: bold;")
        layout.addWidget(elo_label)

        return row

    def _rank_style(self, rank: int) -> str:
        """Return style for rank label based on position."""
        if rank == 1:
            return "color: #ffd700; font-size: 26px; font-weight: bold;"
        elif rank == 2:
            return "color: #a8c0d4; font-size: 26px; font-weight: bold;"
        elif rank == 3:
            return "color: #cd7f32; font-size: 26px; font-weight: bold;"
        else:
            return f"color: {CLR_TEXT_BRIGHT}; font-size: 26px; font-weight: bold;"
