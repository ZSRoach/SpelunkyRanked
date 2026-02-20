"""Rank name/icon helpers based on elo thresholds."""

import os

from PySide6.QtCore import Qt
from PySide6.QtGui import (
    QBrush, QFont, QFontMetrics, QLinearGradient, QColor,
    QPainter, QPainterPath, QPixmap,
)
from PySide6.QtWidgets import QApplication, QLabel

from config import RANK_THRESHOLDS, ASSETS_DIR, RANK_COLORS, COSMIC_GRADIENT


def get_rank_name(elo: int) -> str:
    """Return rank name for the given elo."""
    for name, min_elo, max_elo in RANK_THRESHOLDS:
        if max_elo is None:
            if elo >= min_elo:
                return name
        elif min_elo <= elo <= max_elo:
            return name
    return "gold"


def get_rank_icon_path(elo: int) -> str:
    """Return absolute path to the rank icon PNG for the given elo."""
    rank = get_rank_name(elo)
    return os.path.join(ASSETS_DIR, f"{rank}rank.png")


def get_rank_color(elo: int) -> str:
    """Return the hex color string for a player's rank based on elo."""
    rank = get_rank_name(elo)
    return RANK_COLORS.get(rank, "#c9c9c9")


def _make_cosmic_pixmap(text: str, font_size: int) -> QPixmap:
    """Render text bold at font_size with a horizontal cosmic gradient into a QPixmap."""
    font = QApplication.font()
    font.setPixelSize(font_size)
    font.setBold(True)

    fm = QFontMetrics(font)
    w = fm.horizontalAdvance(text) + 2
    h = fm.height()

    pixmap = QPixmap(w, h)
    pixmap.fill(Qt.transparent)

    painter = QPainter(pixmap)
    painter.setRenderHint(QPainter.Antialiasing)
    painter.setRenderHint(QPainter.TextAntialiasing)
    painter.setFont(font)

    gradient = QLinearGradient(0, 0, w, 0)
    gradient.setColorAt(0.0, QColor(f"#{COSMIC_GRADIENT[0]}"))
    gradient.setColorAt(1.0, QColor(f"#{COSMIC_GRADIENT[1]}"))

    # Clip to the text glyph shapes, then flood-fill with gradient
    path = QPainterPath()
    path.addText(0, fm.ascent(), font, text)
    painter.setClipPath(path)
    painter.fillRect(0, 0, w, h, QBrush(gradient))
    painter.end()

    return pixmap


def apply_rank_label_style(label: QLabel, elo: int, font_size: int, extra_style: str = "") -> None:
    """Apply rank color or cosmic gradient to a name label.

    For cosmic rank, renders gradient text as a pixmap (QSS color: doesn't support gradients).
    For all other ranks, applies a solid stylesheet color.
    Must be called after label.setText().
    """
    rank = get_rank_name(elo)
    if rank == "cosmic":
        pixmap = _make_cosmic_pixmap(label.text(), font_size)
        base = "background: transparent;"
        label.setStyleSheet(f"{base} {extra_style}".strip())
        label.setPixmap(pixmap)
    else:
        color = RANK_COLORS.get(rank, "#c9c9c9")
        style = f"color: {color}; font-size: {font_size}px; font-weight: bold;"
        if extra_style:
            style += f" {extra_style}"
        label.setStyleSheet(style)


def create_rank_icon(elo: int, size: int = 16) -> QLabel:
    """Return a QLabel displaying the rank icon for the given elo."""
    label = QLabel()
    label.setFixedSize(size, size)
    path = get_rank_icon_path(elo)
    pixmap = QPixmap(path)
    if not pixmap.isNull():
        label.setPixmap(pixmap.scaled(size, size, Qt.KeepAspectRatio, Qt.SmoothTransformation))
    label.setStyleSheet("background: transparent;")
    return label
