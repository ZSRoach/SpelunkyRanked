"""Profile page displaying all player statistics."""

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QScrollArea,
    QFrame,
    QGridLayout,
)

from PySide6.QtGui import QPixmap
from rank_utils import get_rank_icon_path, apply_rank_label_style
from config import CLR_WIDGET_BG, CLR_TEXT, CLR_TEXT_BRIGHT, format_time


class ProfilePage(QWidget):
    """Shows all stored player data: elo, matches, winrate, per-category stats."""

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self._setup_ui()
        self._controller.login_success.connect(self.update_data)
        self._controller.player_data_refreshed.connect(self.update_data)

    def _setup_ui(self):
        outer = QVBoxLayout(self)
        outer.setContentsMargins(0, 0, 0, 0)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.NoFrame)
        outer.addWidget(scroll)

        container = QWidget()
        self._layout = QVBoxLayout(container)
        self._layout.setSpacing(12)
        self._layout.setContentsMargins(24, 24, 24, 24)
        scroll.setWidget(container)

        # Header section (rank icon + name + elo)
        header_row = QHBoxLayout()
        header_row.setSpacing(8)
        header_row.setAlignment(Qt.AlignLeft)

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
        self._layout.addLayout(header_row)

        # Summary row (no elo column — elo is next to name)
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

    def update_data(self, data: dict) -> None:
        name = data.get("player_name", "\u2014")
        elo = data.get("elo", 0)
        self._name_label.setText(name)
        apply_rank_label_style(self._name_label, elo, 36)

        self._elo_label.setText(str(elo))

        # Update rank icon
        pixmap = QPixmap(get_rank_icon_path(elo))
        if not pixmap.isNull():
            self._rank_icon.setPixmap(
                pixmap.scaled(36, 36, Qt.KeepAspectRatio, Qt.SmoothTransformation)
            )
        total = data.get("total_matches", 0)
        wins = data.get("total_wins", 0)
        losses = data.get("total_losses", 0)
        winrate = f"{wins / total * 100:.1f}%" if total > 0 else "\u2014"

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

        # Collect all categories that have data
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
            wr = f"{w / played * 100:.0f}%" if played > 0 else "\u2014"
            fast = format_time(fastest_cat[cat]) if cat in fastest_cat else "\u2014"
            avg = format_time(avg_cat[cat]) if cat in avg_cat else "\u2014"

            values = [cat, str(played), str(w), str(lo), wr, fast, avg]
            for col, val in enumerate(values):
                lbl = QLabel(val)
                # Category names, fastest, and avg times in bright text
                if col == 0 or col >= 5:
                    lbl.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 20px; font-weight: bold; padding: 2px 6px;")
                else:
                    lbl.setStyleSheet(f"color: {CLR_TEXT_BRIGHT}; font-size: 20px; font-weight: bold; padding: 2px 6px;")
                self._cat_grid.addWidget(lbl, row, col)
