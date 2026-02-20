"""Frameless overlay window for OBS/streaming use.

Displays opponent rank icon + name, category, and live area progress.
Resizable and movable. Background color is configurable via Settings.
"""

from PySide6.QtCore import Qt, QPoint, QSize
from PySide6.QtGui import QFont, QFontMetrics, QCursor, QPixmap
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel

import settings_store
from rank_utils import get_rank_icon_path
from config import THEME_NAMES

# Resize handle size in pixels
RESIZE_MARGIN = 8


class OverlayWindow(QWidget):
    """Separate frameless window for streaming overlay."""

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self._controller = controller
        self.setWindowFlags(
            Qt.Window
            | Qt.FramelessWindowHint
            | Qt.WindowStaysOnTopHint
        )
        self.setAttribute(Qt.WA_TranslucentBackground, False)
        self.setMinimumSize(200, 80)
        self.resize(400, 140)
        self.setWindowTitle("Match Overlay")

        # Drag/resize state
        self._drag_pos = None
        self._resizing = False
        self._resize_edge = None

        self._setup_ui()

        # Connect signals
        self._controller.opponent_progress.connect(self._on_progress)
        self._controller.match_started.connect(self._on_match_start)
        self._controller.match_result.connect(lambda _: self._reset())
        self._controller.match_scrapped.connect(self._reset)

    def _setup_ui(self):
        self._root = QVBoxLayout(self)
        self._root.setContentsMargins(12, 8, 12, 8)
        self._root.setSpacing(2)

        # Common label style - no selection, no highlight
        label_style = """
            QLabel {
                color: white;
                background: transparent;
                selection-background-color: transparent;
                selection-color: white;
            }
        """

        # Line 1: rank icon + opponent name
        opponent_row = QHBoxLayout()
        opponent_row.setSpacing(4)
        opponent_row.setContentsMargins(0, 0, 0, 0)

        self._opponent_icon = QLabel()
        self._opponent_icon.setFixedSize(20, 20)
        self._opponent_icon.setStyleSheet("background: transparent;")
        self._update_opponent_icon(200)  # preview default
        opponent_row.addWidget(self._opponent_icon)

        self._opponent_label = QLabel("ExamplePlayer")
        self._opponent_label.setStyleSheet(label_style)
        self._opponent_label.setTextInteractionFlags(Qt.NoTextInteraction)
        opponent_row.addWidget(self._opponent_label, stretch=1)

        self._root.addLayout(opponent_row)

        # Line 2: category
        self._category_label = QLabel("Any%")
        self._category_label.setStyleSheet(label_style)
        self._category_label.setTextInteractionFlags(Qt.NoTextInteraction)
        self._root.addWidget(self._category_label)

        # Line 3: area progress
        self._progress_label = QLabel("Started Match")
        self._progress_label.setStyleSheet(label_style)
        self._progress_label.setTextInteractionFlags(Qt.NoTextInteraction)
        self._root.addWidget(self._progress_label)

        self._root.addStretch()

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self._update_font_sizes()

    def _update_font_sizes(self):
        """Scale fonts to fill the window without cutting off text."""
        # Available space
        width = self.width() - 24  # margins
        height = self.height() - 16  # margins

        # Three labels, divide height
        line_height = height // 3

        labels = [self._opponent_label, self._category_label, self._progress_label]

        for label in labels:
            text = label.text()
            if not text:
                continue

            # Binary search for optimal font size
            min_size = 8
            max_size = min(line_height, 72)
            optimal_size = min_size

            while min_size <= max_size:
                mid_size = (min_size + max_size) // 2
                font = QFont()
                font.setPixelSize(mid_size)
                font.setBold(label == self._opponent_label)
                metrics = QFontMetrics(font)

                text_width = metrics.horizontalAdvance(text)
                text_height = metrics.height()

                if text_width <= width and text_height <= line_height:
                    optimal_size = mid_size
                    min_size = mid_size + 1
                else:
                    max_size = mid_size - 1

            font = QFont()
            font.setPixelSize(optimal_size)
            font.setBold(label == self._opponent_label)
            label.setFont(font)

            # Scale opponent icon to match opponent label font size
            if label == self._opponent_label:
                icon_size = max(12, optimal_size)
                self._opponent_icon.setFixedSize(icon_size, icon_size)
                # Re-apply icon at new size
                elo = self._controller.match_opponent_elo if self._controller.in_match else 200
                path = get_rank_icon_path(elo)
                pixmap = QPixmap(path)
                if not pixmap.isNull():
                    self._opponent_icon.setPixmap(
                        pixmap.scaled(icon_size, icon_size, Qt.KeepAspectRatio, Qt.SmoothTransformation)
                    )

    def showEvent(self, event):
        super().showEvent(event)
        self._apply_bg_color()
        # Populate with current match data or show preview placeholders
        if self._controller.in_match:
            opponent = self._controller.match_opponent
            elo = self._controller.match_opponent_elo
            self._opponent_label.setText(opponent)
            self._update_opponent_icon(elo)
            self._category_label.setText(self._controller.match_category)
        else:
            self._show_preview()
        self._update_font_sizes()

    def _update_opponent_icon(self, elo: int):
        """Update the rank icon for the opponent's elo."""
        path = get_rank_icon_path(elo)
        pixmap = QPixmap(path)
        if not pixmap.isNull():
            self._opponent_icon.setPixmap(
                pixmap.scaled(20, 20, Qt.KeepAspectRatio, Qt.SmoothTransformation)
            )

    def _apply_bg_color(self):
        color = settings_store.get_overlay_color()
        self.setStyleSheet(f"OverlayWindow {{ background-color: {color}; }}")

    def _on_match_start(self, data: dict):
        opponent = self._controller.match_opponent
        elo = self._controller.match_opponent_elo
        self._opponent_label.setText(opponent)
        self._update_opponent_icon(elo)
        self._category_label.setText(data.get("category", "—"))
        self._progress_label.setText("Started Match")
        self._apply_bg_color()
        self._update_font_sizes()

    def _on_progress(self, area: int, theme: int):
        # Dwelling (theme 1) is the starting area — keep "Started Match"
        if theme == 1 or theme == 0:
            return
        area_name = THEME_NAMES.get(theme, f"Area {area}")
        self._progress_label.setText(f"Entered {area_name}")
        self._update_font_sizes()

    def _reset(self):
        """Reset to preview mode when match ends."""
        self._show_preview()

    def _show_preview(self):
        """Show placeholder data for streaming software configuration."""
        self._opponent_label.setText("ExamplePlayer")
        self._update_opponent_icon(200)
        self._category_label.setText("Any%")
        self._progress_label.setText("Started Match")
        self._update_font_sizes()

    # ---- Mouse handling for drag and resize ----

    def _get_resize_edge(self, pos):
        """Determine which edge/corner is being hovered for resize."""
        rect = self.rect()
        x, y = pos.x(), pos.y()
        w, h = rect.width(), rect.height()

        edges = []
        if x < RESIZE_MARGIN:
            edges.append("left")
        elif x > w - RESIZE_MARGIN:
            edges.append("right")
        if y < RESIZE_MARGIN:
            edges.append("top")
        elif y > h - RESIZE_MARGIN:
            edges.append("bottom")

        return tuple(edges) if edges else None

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            edge = self._get_resize_edge(event.pos())
            if edge:
                self._resizing = True
                self._resize_edge = edge
                self._drag_pos = event.globalPos()
            else:
                self._drag_pos = event.globalPos() - self.frameGeometry().topLeft()
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event):
        if self._resizing and self._drag_pos:
            delta = event.globalPos() - self._drag_pos
            self._drag_pos = event.globalPos()

            geom = self.geometry()
            min_w, min_h = self.minimumWidth(), self.minimumHeight()

            if "right" in self._resize_edge:
                new_w = max(min_w, geom.width() + delta.x())
                geom.setWidth(new_w)
            if "bottom" in self._resize_edge:
                new_h = max(min_h, geom.height() + delta.y())
                geom.setHeight(new_h)
            if "left" in self._resize_edge:
                new_w = max(min_w, geom.width() - delta.x())
                if new_w != geom.width():
                    geom.setLeft(geom.left() + delta.x())
            if "top" in self._resize_edge:
                new_h = max(min_h, geom.height() - delta.y())
                if new_h != geom.height():
                    geom.setTop(geom.top() + delta.y())

            self.setGeometry(geom)

        elif self._drag_pos and not self._resizing:
            self.move(event.globalPos() - self._drag_pos)

        else:
            # Update cursor based on hover position
            edge = self._get_resize_edge(event.pos())
            if edge:
                if edge in [("left",), ("right",)]:
                    self.setCursor(Qt.SizeHorCursor)
                elif edge in [("top",), ("bottom",)]:
                    self.setCursor(Qt.SizeVerCursor)
                elif edge in [("left", "top"), ("right", "bottom")]:
                    self.setCursor(Qt.SizeFDiagCursor)
                elif edge in [("right", "top"), ("left", "bottom")]:
                    self.setCursor(Qt.SizeBDiagCursor)
                else:
                    self.setCursor(Qt.SizeAllCursor)
            else:
                self.setCursor(Qt.ArrowCursor)

        super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self._drag_pos = None
            self._resizing = False
            self._resize_edge = None
        super().mouseReleaseEvent(event)
