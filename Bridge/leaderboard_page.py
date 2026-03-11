"""Leaderboard page showing player rankings by elo."""

import threading

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QScrollArea,
    QFrame,
    QComboBox,
)

import api_client
from rank_utils import create_rank_icon, apply_rank_label_style
from config import CLR_WIDGET_BG, CLR_BUTTON_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_ACTIVE_BTN, CLR_UNRANKED


class LeaderboardPage(QWidget):
    """Leaderboard page displaying players ranked by elo."""

    _data_loaded = Signal(list)
    _seasons_loaded = Signal(dict)

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._my_row: QFrame | None = None
        self._seasons_fetched = False
        self._current_season_number: int | None = None  # None = current (live)
        self._current_season_label_text = ""
        self._setup_ui()
        self._data_loaded.connect(self._populate_leaderboard)
        self._seasons_loaded.connect(self._populate_season_dropdown)
        self._seasons_loaded.connect(self._update_season_info_label)

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        # Header row: season dropdown on left, centered title, buttons on right
        header_row = QHBoxLayout()

        # Season dropdown (top left)
        self._season_combo = QComboBox()
        self._season_combo.setFixedWidth(190)
        self._season_combo.setFixedHeight(40)
        self._season_combo.setStyleSheet(
            f"QComboBox {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"border: 1px solid #4a4e7a; border-radius: 4px; font-size: 21px; "
            f"padding: 0 8px; text-align: center; }}"
            f"QComboBox::drop-down {{ border: none; width: 0; }}"
            f"QComboBox QAbstractItemView {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"selection-background-color: #3e4278; }}"
        )
        self._season_combo.currentIndexChanged.connect(self._on_season_changed)
        header_row.addWidget(self._season_combo)

        header_row.addStretch()

        header = QLabel("Leaderboard")
        header.setStyleSheet(f"color: {CLR_ACTIVE_BTN}; font-size: 36px; font-weight: bold;")
        header.setAlignment(Qt.AlignCenter)
        header_row.addWidget(header)

        header_row.addStretch()

        self._my_rank_btn = QPushButton("My Rank")
        self._my_rank_btn.setFixedHeight(40)
        self._my_rank_btn.setFixedWidth(110)
        self._my_rank_btn.setStyleSheet(
            f"QPushButton {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"border-radius: 4px; font-size: 19px; font-weight: bold; }}"
            f"QPushButton:hover {{ background-color: #3e4278; }}"
            f"QPushButton:disabled {{ background-color: #1a1a28; color: #555; }}"
        )
        self._my_rank_btn.setEnabled(False)
        self._my_rank_btn.clicked.connect(self._scroll_to_my_rank)
        header_row.addWidget(self._my_rank_btn)

        refresh_btn = QPushButton("Refresh")
        refresh_btn.setFixedHeight(40)
        refresh_btn.setFixedWidth(100)
        refresh_btn.setStyleSheet(
            f"QPushButton {{ background-color: {CLR_BUTTON_BG}; color: {CLR_TEXT_BRIGHT}; "
            f"border-radius: 4px; font-size: 19px; font-weight: bold; }}"
            f"QPushButton:hover {{ background-color: #3e4278; }}"
        )
        refresh_btn.clicked.connect(self.refresh)
        header_row.addWidget(refresh_btn)

        layout.addLayout(header_row)

        self._season_info_label = QLabel("")
        self._season_info_label.setStyleSheet(
            f"color: {CLR_TEXT_BRIGHT}; font-size: 34px; font-weight: bold;"
        )
        self._season_info_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self._season_info_label)

        # Column headers
        header_row = QFrame()
        header_row.setStyleSheet(f"QFrame {{ background-color: {CLR_BUTTON_BG}; border-radius: 4px; }}")
        header_layout = QHBoxLayout(header_row)
        header_layout.setContentsMargins(16, 8, 16, 8)

        rank_header = QLabel("#")
        rank_header.setFixedWidth(50)
        rank_header.setAlignment(Qt.AlignCenter)
        rank_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 30px; font-weight: bold; qproperty-alignment: AlignCenter;")
        header_layout.addWidget(rank_header)

        name_header = QLabel("Player")
        name_header.setAlignment(Qt.AlignCenter)
        name_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 30px; font-weight: bold;")
        header_layout.addWidget(name_header, stretch=1)

        elo_header = QLabel("Elo")
        elo_header.setFixedWidth(100)
        elo_header.setAlignment(Qt.AlignCenter)
        elo_header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 30px; font-weight: bold;")
        header_layout.addWidget(elo_header)

        layout.addWidget(header_row)

        # Scroll area for player list
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        scroll.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
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
        if not self._seasons_fetched:
            self._fetch_seasons()
        self._fetch_leaderboard()

    def refresh(self):
        self._seasons_fetched = False
        self._fetch_seasons()
        self._fetch_leaderboard()

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

        prev_season = self._current_season_number

        self._season_combo.blockSignals(True)
        self._season_combo.clear()

        # Current season (live)
        self._season_combo.addItem(f"Season {current} (Current)", userData=None)

        # All historical seasons from current-1 down to 0
        for s in range(current - 1, -1, -1):
            self._season_combo.addItem(f"Season {s}", userData=s)

        # Restore previous selection if possible
        if prev_season is not None:
            for i in range(self._season_combo.count()):
                if self._season_combo.itemData(i) == prev_season:
                    self._season_combo.setCurrentIndex(i)
                    break

        self._season_combo.blockSignals(False)
        self._current_season_number = self._season_combo.currentData()

    def _scroll_to_my_rank(self):
        if self._my_row:
            self._scroll.ensureWidgetVisible(self._my_row)

    def _update_season_info_label(self, data: dict) -> None:
        from datetime import date as _date
        current = data.get("current_season", 0)
        season_info_map = {s["id"]: s for s in data.get("seasons_info", [])}
        info = season_info_map.get(current, {})
        start_date = info.get("start_date", "")
        if start_date:
            try:
                days = (_date.today() - _date.fromisoformat(start_date)).days
                days_str = "today" if days == 0 else f"{days} day{'s' if days != 1 else ''} ago"
                text = f"Season {current}  •  started {days_str}"
            except Exception:
                text = f"Season {current}"
        else:
            text = f"Season {current}"
        self._current_season_label_text = text
        if self._current_season_number is None:
            self._season_info_label.setText(text)

    def _on_season_changed(self, index: int):
        self._current_season_number = self._season_combo.currentData()
        if self._current_season_number is None:
            self._season_info_label.setText(self._current_season_label_text)
        else:
            self._season_info_label.setText("")
        self._fetch_leaderboard()

    def _fetch_leaderboard(self):
        """Fetch leaderboard in background thread."""
        self._loading_label.show()
        season = self._current_season_number  # None = current live leaderboard

        def _do():
            try:
                players = api_client.get_leaderboard(season=season)
                self._data_loaded.emit(players)
            except Exception:
                self._data_loaded.emit([])

        threading.Thread(target=_do, daemon=True).start()

    def _populate_leaderboard(self, players: list):
        """Populate the leaderboard with player data."""
        self._loading_label.hide()
        self._my_row = None
        self._my_rank_btn.setEnabled(False)

        # Save scroll position before clearing
        saved_scroll = self._scroll.verticalScrollBar().value()

        # Clear existing rows (except the stretch at the end)
        while self._list_layout.count() > 1:
            item = self._list_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        ranked = [p for p in players if p.get("is_ranked", True)]
        unranked = [p for p in players if not p.get("is_ranked", True)]

        # Add ranked player rows
        for i, player in enumerate(ranked):
            row = self._create_player_row(i + 1, player)
            self._list_layout.insertWidget(self._list_layout.count() - 1, row)
            if player.get("player_name") == self._controller.player_name:
                self._my_row = row
                self._my_rank_btn.setEnabled(True)

        # Divider between ranked and unranked
        if ranked and unranked:
            spacer = QWidget()
            spacer.setFixedHeight(8)
            self._list_layout.insertWidget(self._list_layout.count() - 1, spacer)
            divider = QFrame()
            divider.setFrameShape(QFrame.HLine)
            divider.setStyleSheet(f"background-color: {CLR_UNRANKED}; max-height: 2px;")
            self._list_layout.insertWidget(self._list_layout.count() - 1, divider)
            header_widget = QWidget()
            header_layout = QHBoxLayout(header_widget)
            header_layout.setContentsMargins(16, 4, 16, 4)
            rank_spacer = QWidget()
            rank_spacer.setFixedWidth(50)
            header_layout.addWidget(rank_spacer)
            unranked_header = QLabel("Placement Players")
            unranked_header.setAlignment(Qt.AlignCenter)
            unranked_header.setStyleSheet(f"color: {CLR_UNRANKED}; font-size: 22px; font-weight: bold;")
            header_layout.addWidget(unranked_header, stretch=1)
            elo_spacer = QWidget()
            elo_spacer.setFixedWidth(100)
            header_layout.addWidget(elo_spacer)
            self._list_layout.insertWidget(self._list_layout.count() - 1, header_widget)

        # Add unranked player rows (no rank number)
        for player in unranked:
            row = self._create_player_row(None, player)
            self._list_layout.insertWidget(self._list_layout.count() - 1, row)
            if player.get("player_name") == self._controller.player_name:
                self._my_row = row
                self._my_rank_btn.setEnabled(True)

        # Restore scroll position after layout settles
        from PySide6.QtCore import QTimer
        QTimer.singleShot(0, lambda: self._scroll.verticalScrollBar().setValue(saved_scroll))

    def _create_player_row(self, rank, player: dict) -> QFrame:
        """Create a row widget for a player. rank=None for unranked players."""
        row = QFrame()
        row.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 4px; }}"
        )

        layout = QHBoxLayout(row)
        layout.setContentsMargins(16, 12, 16, 12)

        is_ranked = player.get("is_ranked", True)

        # Rank number on the left
        rank_label = QLabel(f"{rank}." if rank is not None else "")
        rank_label.setFixedWidth(50)
        rank_label.setAlignment(Qt.AlignCenter)
        rank_label.setStyleSheet(self._rank_style(rank) if rank is not None else f"color: {CLR_UNRANKED}; font-size: 26px; font-weight: bold;")
        layout.addWidget(rank_label)

        # Icon + name grouped together (icon adjacent to name)
        elo = player.get("elo", 0)
        name = player.get("player_name", "Unknown")
        name_group = QHBoxLayout()
        name_group.setSpacing(6)
        name_group.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
        if is_ranked:
            icon = create_rank_icon(elo, size=26)
            name_group.addWidget(icon)
        name_label = QLabel(name)
        if is_ranked:
            apply_rank_label_style(name_label, elo, 26)
        else:
            name_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 26px; font-weight: bold;")
        name_group.addWidget(name_label)

        layout.addLayout(name_group, stretch=1)

        if is_ranked:
            elo_label = QLabel(str(elo))
            elo_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 26px; font-weight: bold;")
        else:
            elo_label = QLabel("[Unranked]")
            elo_label.setStyleSheet(f"color: {CLR_UNRANKED}; font-size: 20px; font-weight: bold;")
        elo_label.setFixedWidth(100)
        elo_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(elo_label)

        return row

    def _rank_style(self, rank) -> str:
        """Return style for rank label based on position."""
        if rank == 1:
            return "color: #ffd700; font-size: 26px; font-weight: bold;"
        elif rank == 2:
            return "color: #a8c0d4; font-size: 26px; font-weight: bold;"
        elif rank == 3:
            return "color: #cd7f32; font-size: 26px; font-weight: bold;"
        else:
            return f"color: {CLR_TEXT_BRIGHT}; font-size: 26px; font-weight: bold;"
