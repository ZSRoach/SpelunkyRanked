"""Profile page displaying all player statistics."""

import threading

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QScrollArea,
    QFrame,
    QGridLayout,
    QComboBox,
)

from PySide6.QtGui import QPixmap
from rank_utils import get_rank_icon_path, apply_rank_label_style, is_placement
from config import CLR_WIDGET_BG, CLR_TEXT, CLR_TEXT_BRIGHT, CLR_UNRANKED, CLR_BUTTON_BG, format_time
import api_client


class ProfilePage(QWidget):
    """Shows all stored player data: elo, matches, winrate, per-category stats."""

    _season_data_loaded = Signal(dict)
    _seasons_loaded = Signal(dict)

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._all_time_data: dict = {}
        self._seasons_fetched = False
        self._current_season = "alltime"  # "alltime" or int season number
        self._user_has_selected_season = False
        self._setup_ui()
        self._controller.login_success.connect(self._on_login_data)
        self._controller.player_data_refreshed.connect(self._on_login_data)
        self._season_data_loaded.connect(self._show_season_data)
        self._seasons_loaded.connect(self._populate_season_dropdown)

    def _setup_ui(self):
        outer = QVBoxLayout(self)
        outer.setSpacing(8)
        outer.setContentsMargins(24, 24, 24, 8)

        # Fixed header row (not scrollable): rank icon + name + elo + season dropdown
        header_row = QHBoxLayout()
        header_row.setSpacing(8)

        self._rank_icon = QLabel()
        self._rank_icon.setFixedSize(36, 36)
        self._rank_icon.setStyleSheet("background: transparent;")
        header_row.addWidget(self._rank_icon)

        self._name_label = QLabel("\u2014")
        self._name_label.setStyleSheet(f"font-size: 36px; font-weight: bold; color: {CLR_TEXT_BRIGHT};")
        header_row.addWidget(self._name_label)

        self._elo_label = QLabel("200")
        self._elo_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 36px; font-weight: bold;")
        header_row.addWidget(self._elo_label)

        header_row.addStretch()

        # Season dropdown (top right, opposite player name)
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
        self._season_combo.addItem("All Time", userData="alltime")
        self._season_combo.currentIndexChanged.connect(self._on_season_changed)
        header_row.addWidget(self._season_combo)

        outer.addLayout(header_row)

        # Placements label (fixed, below header)
        self._placements_label = QLabel()
        self._placements_label.setStyleSheet(f"color: {CLR_UNRANKED}; font-size: 20px; font-weight: bold;")
        self._placements_label.setVisible(False)
        outer.addWidget(self._placements_label)

        # Scroll area for stats content
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.NoFrame)
        outer.addWidget(scroll, stretch=1)

        container = QWidget()
        self._layout = QVBoxLayout(container)
        self._layout.setSpacing(12)
        self._layout.setContentsMargins(0, 8, 0, 24)
        scroll.setWidget(container)

        # Summary row
        self._summary_frame = QFrame()
        self._summary_frame.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 8px; padding: 12px; }}"
        )
        summary_grid = QGridLayout(self._summary_frame)
        summary_grid.setSpacing(16)

        self._matches_label = self._stat_value("0")
        self._wins_label = self._stat_value("0")
        self._losses_label = self._stat_value("0")
        self._winrate_label = self._stat_value("\u2014")

        for col, (name, widget) in enumerate([
            ("Matches", self._matches_label),
            ("Wins", self._wins_label),
            ("Losses", self._losses_label),
            ("Winrate", self._winrate_label),
        ]):
            header = QLabel(name)
            header.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold;")
            header.setAlignment(Qt.AlignCenter)
            summary_grid.addWidget(header, 0, col)
            summary_grid.addWidget(widget, 1, col)

        self._layout.addWidget(self._summary_frame)

        # Per-category section
        cat_header = QLabel("Category Stats")
        cat_header.setStyleSheet(f"font-size: 26px; font-weight: bold; color: {CLR_TEXT_BRIGHT}; margin-top: 12px;")
        self._layout.addWidget(cat_header)

        self._cat_frame = QFrame()
        self._cat_frame.setStyleSheet(
            f"QFrame {{ background-color: {CLR_WIDGET_BG}; border-radius: 8px; padding: 8px; }}"
        )
        self._cat_grid = QGridLayout(self._cat_frame)
        self._cat_grid.setSpacing(4)
        self._layout.addWidget(self._cat_frame)

        self._layout.addStretch()

    def _stat_value(self, text: str) -> QLabel:
        label = QLabel(text)
        label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 36px; font-weight: bold;")
        label.setAlignment(Qt.AlignCenter)
        return label

    def showEvent(self, event):
        super().showEvent(event)
        if not self._seasons_fetched and self._all_time_data:
            self._fetch_seasons()

    def _on_login_data(self, data: dict) -> None:
        """Called when login or player refresh occurs. Stores all-time data and shows it."""
        self._all_time_data = data
        if not self._seasons_fetched:
            self._fetch_seasons()
        # Always refresh the header (elo/rank/placements) from live data
        self._update_header(data)
        # Refresh stats for whichever view is active
        if self._current_season == "alltime":
            self._update_stats(data)
        elif self._seasons_fetched:
            self._fetch_season_stats(self._current_season)

    def _fetch_seasons(self):
        def _do():
            try:
                result = api_client.get_seasons()
                self._seasons_loaded.emit(result)
            except Exception:
                pass
        threading.Thread(target=_do, daemon=True).start()

    def _populate_season_dropdown(self, data: dict):
        self._seasons_fetched = True
        current = data.get("current_season", 0)
        prev = self._current_season

        self._season_combo.blockSignals(True)
        self._season_combo.clear()

        # "All Time" = cumulative stats from player table
        self._season_combo.addItem("All Time", userData="alltime")

        # All seasons from current down to 0
        for s in range(current, -1, -1):
            label = f"Season {s} (Current)" if s == current else f"Season {s}"
            self._season_combo.addItem(label, userData=s)

        if self._user_has_selected_season:
            # Restore previous explicit selection
            for i in range(self._season_combo.count()):
                if self._season_combo.itemData(i) == prev:
                    self._season_combo.setCurrentIndex(i)
                    break
        else:
            # Default to current season (index 1, right after "All Time")
            if self._season_combo.count() > 1:
                self._season_combo.setCurrentIndex(1)

        self._season_combo.blockSignals(False)
        new_season = self._season_combo.currentData()
        self._current_season = new_season
        # Fetch stats for the newly selected season if needed
        if new_season == "alltime":
            self._update_stats(self._all_time_data)
        else:
            self._fetch_season_stats(new_season)

    def _on_season_changed(self, index: int):
        self._user_has_selected_season = True
        season = self._season_combo.currentData()
        self._current_season = season
        if season == "alltime":
            self._update_stats(self._all_time_data)
        else:
            self._fetch_season_stats(season)

    def _fetch_season_stats(self, season: int):
        steam_id = getattr(self._controller, "steam_id", None)
        if not steam_id:
            return

        def _do():
            try:
                data = api_client.get_player_season_stats(steam_id, season)
                self._season_data_loaded.emit(data)
            except Exception:
                pass
        threading.Thread(target=_do, daemon=True).start()

    def _show_season_data(self, data: dict):
        # Only apply if this season is still selected
        if self._current_season != "alltime":
            self._update_stats(data)

    def update_data(self, data: dict) -> None:
        """Update full profile (header + stats). Used for all-time view."""
        self._update_header(data)
        self._update_stats(data)

    def _update_header(self, data: dict) -> None:
        """Update name, elo/rank icon, and placement status. Always uses live player data."""
        name = data.get("player_name", "\u2014")
        elo = data.get("elo", 0)
        unranked = is_placement(data)

        self._name_label.setText(name)
        self._name_label.setStyleSheet(f"font-size: 36px; font-weight: bold; color: {CLR_TEXT_BRIGHT};")

        if unranked:
            self._rank_icon.clear()
            self._rank_icon.setVisible(False)
            self._elo_label.setText("[Unranked]")
            self._elo_label.setStyleSheet(f"color: {CLR_UNRANKED}; font-size: 36px; font-weight: bold;")
            placements_remaining = data.get("placements_remaining", 0)
            remaining_text = "1 placement match remaining" if placements_remaining == 1 else f"{placements_remaining} placement matches remaining"
            self._placements_label.setText(remaining_text)
            self._placements_label.setVisible(True)
        else:
            self._rank_icon.setVisible(True)
            apply_rank_label_style(self._name_label, elo, 36)
            self._elo_label.setText(str(elo))
            self._elo_label.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 36px; font-weight: bold;")
            self._placements_label.setVisible(False)
            pixmap = QPixmap(get_rank_icon_path(elo))
            if not pixmap.isNull():
                self._rank_icon.setPixmap(
                    pixmap.scaled(36, 36, Qt.KeepAspectRatio, Qt.SmoothTransformation)
                )

    def _update_stats(self, data: dict) -> None:
        """Update match counts and per-category stats from data."""
        total = data.get("total_matches", 0)
        wins = data.get("total_wins", 0)
        losses = data.get("total_losses", 0)
        winrate = f"{wins / (wins + losses) * 100:.1f}%" if (wins + losses) > 0 else "\u2014"

        self._matches_label.setText(str(total))
        self._wins_label.setText(str(wins))
        self._losses_label.setText(str(losses))
        self._winrate_label.setText(winrate)

        # Clear existing category rows
        while self._cat_grid.count():
            item = self._cat_grid.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        # Column headers
        headers = ["Category", "Played", "W", "L", "WR%", "Fastest", "Avg"]
        for col, h in enumerate(headers):
            lbl = QLabel(h)
            lbl.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 24px; font-weight: bold; padding: 2px 6px;")
            self._cat_grid.addWidget(lbl, 0, col)

        matches_cat = data.get("matches_per_category", {})
        wins_cat = data.get("wins_per_category", {})
        losses_cat = data.get("losses_per_category", {})
        fastest_cat = data.get("fastest_time_per_category", {})
        avg_cat = data.get("avg_time_per_category", {})

        all_cats = sorted(set(matches_cat.keys()))
        if not all_cats:
            lbl = QLabel("No matches played yet.")
            lbl.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 22px; font-weight: bold; padding: 8px;")
            self._cat_grid.addWidget(lbl, 1, 0, 1, 7)
            return

        for row, cat in enumerate(all_cats, start=1):
            played = matches_cat.get(cat, 0)
            w = wins_cat.get(cat, 0)
            lo = losses_cat.get(cat, 0)
            wr = f"{w / (w + lo) * 100:.0f}%" if (w + lo) > 0 else "\u2014"
            fast = format_time(fastest_cat[cat]) if cat in fastest_cat else "\u2014"
            avg = format_time(avg_cat[cat]) if cat in avg_cat else "\u2014"

            values = [cat, str(played), str(w), str(lo), wr, fast, avg]
            for col, val in enumerate(values):
                lbl = QLabel(val)
                lbl.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 20px; font-weight: bold; padding: 2px 6px;")
                self._cat_grid.addWidget(lbl, row, col)
