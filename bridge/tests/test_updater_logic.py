"""Tests for updater version-checking logic.

Covers:
  - normalize_version() edge cases
  - _apply_version_info() population
  - _bridge_version_mismatch_detected() conditions
  - _build_version_payload() structure
  - Deferred version mismatch state machine (mid-match deferral + all exit paths)

Run from the repo root:
    python3 bridge/tests/test_updater_logic.py
"""

import os
import sys
import unittest
from unittest.mock import MagicMock, patch, call

# ---------------------------------------------------------------------------
# Minimal stubs so bridge modules import cleanly on non-Windows / no-Qt hosts
# ---------------------------------------------------------------------------

sys.modules["win32crypt"] = MagicMock()

class _QObject:
    def __init__(self, parent=None): pass

class _Signal:
    """Descriptor that gives each instance its own MagicMock signal."""
    def __init__(self, *args): pass
    def __set_name__(self, owner, name): self._attr = f"_sig_{name}"
    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        if not hasattr(obj, self._attr):
            object.__setattr__(obj, self._attr, MagicMock())
        return object.__getattribute__(obj, self._attr)

class _QTimer:
    def __init__(self, parent=None): self.timeout = MagicMock()
    def setInterval(self, v): pass
    def start(self): pass
    def stop(self): pass

_qtcore = MagicMock()
_qtcore.QObject = _QObject
_qtcore.Signal  = _Signal
_qtcore.QTimer  = _QTimer
sys.modules["PySide6"]        = MagicMock()
sys.modules["PySide6.QtCore"] = _qtcore

for _mod in ("ws_client", "udp_relay", "api_client", "match_cache"):
    sys.modules[_mod] = MagicMock()

# Add bridge/src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

import updater_service
import bridge_controller
from bridge_controller import BridgeController
from config import BRIDGE_VERSION, BRIDGE_COMPONENT_VERSION, GAME_COMPONENT_VERSION


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Sentinels for "definitely not the current local version" — used by mismatch tests so
# they stay correct across version bumps instead of hardcoding a version that eventually
# becomes the real local version.
_OLDER_VERSION = BRIDGE_VERSION - 0.01
_OLDER_BRIDGE_COMPONENT = "0.0.1"


def make_controller(**state_overrides) -> BridgeController:
    """Instantiate a BridgeController and apply any state overrides."""
    ctrl = BridgeController()
    for k, v in state_overrides.items():
        setattr(ctrl, k, v)
    return ctrl


def apply_version(ctrl, version=BRIDGE_VERSION, bridge_comp=BRIDGE_COMPONENT_VERSION, game_comp=GAME_COMPONENT_VERSION):
    """Call _apply_version_info with values matching the current local bridge version."""
    ctrl._apply_version_info({
        "version": version,
        "game_mod_download_url": "https://example.com/game",
        "bridge_download_url":   "https://example.com/bridge",
        "component_versions": {
            "bridge": bridge_comp,
            "game":   game_comp,
        },
    })


# ---------------------------------------------------------------------------
# normalize_version
# ---------------------------------------------------------------------------

class TestNormalizeVersion(unittest.TestCase):

    def nv(self, v):
        return updater_service.normalize_version(v)

    def test_none_returns_empty(self):
        self.assertEqual(self.nv(None), "")

    def test_float_strips_trailing_zeros(self):
        self.assertEqual(self.nv(1.0),  "1")
        self.assertEqual(self.nv(1.10), "1.1")   # 1.10 == 1.1 as float
        self.assertEqual(self.nv(1.1),  "1.1")

    def test_float_preserves_significant_decimals(self):
        self.assertEqual(self.nv(1.11), "1.11")
        self.assertEqual(self.nv(1.12), "1.12")

    def test_string_stripped_only(self):
        self.assertEqual(self.nv("1.12.0"),   "1.12.0")
        self.assertEqual(self.nv("  1.12.0 "), "1.12.0")

    def test_same_logical_version_normalizes_equal(self):
        # Server might send 1.1 or 1.10 — both must compare equal to bridge 1.1
        self.assertEqual(self.nv(1.1), self.nv(1.10))

    def test_zero(self):
        self.assertEqual(self.nv(0.0), "0")

    def test_float_rounding_not_applied(self):
        # :.2f caps at two decimals — versions like 1.1 should not become 1.10
        result = self.nv(1.1)
        self.assertNotEqual(result, "1.10")  # trailing zero must be stripped


# ---------------------------------------------------------------------------
# _apply_version_info
# ---------------------------------------------------------------------------

class TestApplyVersionInfo(unittest.TestCase):

    def test_full_payload(self):
        ctrl = make_controller()
        ctrl._apply_version_info({
            "version": 1.12,
            "game_mod_download_url": "https://example.com/game",
            "component_versions": {"bridge": "1.12.0", "game": "1.12.0"},
        })
        self.assertEqual(ctrl._server_version, 1.12)
        self.assertEqual(ctrl._server_bridge_component_version, "1.12.0")
        self.assertEqual(ctrl._server_game_component_version,   "1.12.0")
        self.assertEqual(ctrl.last_version_info["version_text"], "1.12")

    def test_missing_component_versions_key(self):
        ctrl = make_controller()
        ctrl._apply_version_info({"version": 1.12})
        self.assertEqual(ctrl._server_bridge_component_version, "")
        self.assertEqual(ctrl._server_game_component_version,   "")

    def test_null_component_versions(self):
        ctrl = make_controller()
        ctrl._apply_version_info({"version": 1.12, "component_versions": None})
        self.assertEqual(ctrl._server_bridge_component_version, "")
        self.assertEqual(ctrl._server_game_component_version,   "")

    def test_partial_component_versions(self):
        ctrl = make_controller()
        ctrl._apply_version_info({
            "version": 1.12,
            "component_versions": {"bridge": "1.12.0"},  # game missing
        })
        self.assertEqual(ctrl._server_bridge_component_version, "1.12.0")
        self.assertEqual(ctrl._server_game_component_version,   "")

    def test_version_text_in_last_version_info(self):
        ctrl = make_controller()
        ctrl._apply_version_info({"version": 1.1, "component_versions": {}})
        self.assertEqual(ctrl.last_version_info["version_text"], "1.1")


# ---------------------------------------------------------------------------
# _bridge_version_mismatch_detected
# ---------------------------------------------------------------------------

class TestBridgeMismatchDetected(unittest.TestCase):

    def test_no_mismatch_when_server_version_zero(self):
        # server_version=0.0 means we haven't fetched it yet — skip the check
        ctrl = make_controller()
        ctrl._server_version = 0.0
        self.assertFalse(ctrl._bridge_version_mismatch_detected())

    def test_no_mismatch_when_versions_match(self):
        ctrl = make_controller()
        apply_version(ctrl)
        self.assertFalse(ctrl._bridge_version_mismatch_detected())

    def test_standard_version_mismatch(self):
        ctrl = make_controller()
        apply_version(ctrl, version=_OLDER_VERSION)  # server standard version is stale
        self.assertTrue(ctrl._bridge_version_mismatch_detected())

    def test_component_mismatch_while_standard_matches(self):
        ctrl = make_controller()
        apply_version(ctrl, bridge_comp=_OLDER_BRIDGE_COMPONENT)  # server component is stale
        self.assertTrue(ctrl._bridge_version_mismatch_detected())

    def test_no_mismatch_when_server_has_no_component_version(self):
        # Old server that doesn't send component_versions — no false positive
        ctrl = make_controller()
        ctrl._apply_version_info({"version": BRIDGE_VERSION})
        self.assertFalse(ctrl._bridge_version_mismatch_detected())

    def test_both_mismatch(self):
        ctrl = make_controller()
        apply_version(ctrl, version=_OLDER_VERSION, bridge_comp=_OLDER_BRIDGE_COMPONENT)
        self.assertTrue(ctrl._bridge_version_mismatch_detected())


# ---------------------------------------------------------------------------
# Game component mismatch detection
# ---------------------------------------------------------------------------

class TestGameComponentMismatch(unittest.TestCase):

    def _mismatch(self, server_game_comp, local_game_comp, server_version=1.12):
        """Set up state and call the mismatch check inline."""
        ctrl = make_controller()
        apply_version(ctrl, game_comp=server_game_comp)
        ctrl.last_game_component_version = local_game_comp
        standard_mismatch = (
            updater_service.normalize_version(server_version)
            != updater_service.normalize_version(1.12)
        )
        component_mismatch = bool(
            ctrl._server_game_component_version
            and ctrl.last_game_component_version
            and ctrl.last_game_component_version != ctrl._server_game_component_version
        )
        return standard_mismatch or component_mismatch

    def test_matching_game_component(self):
        self.assertFalse(self._mismatch("1.12.0", "1.12.0"))

    def test_mismatching_game_component(self):
        self.assertTrue(self._mismatch("1.12.0", "1.11.0"))

    def test_empty_local_game_component_no_mismatch(self):
        # Old game build that doesn't send component_version
        self.assertFalse(self._mismatch("1.12.0", ""))

    def test_empty_server_game_component_no_mismatch(self):
        # Old server that doesn't send game component versions
        self.assertFalse(self._mismatch("", "1.12.0"))

    def test_both_empty_no_mismatch(self):
        self.assertFalse(self._mismatch("", ""))


# ---------------------------------------------------------------------------
# Deferred version mismatch — state machine
# ---------------------------------------------------------------------------

class TestDeferredVersionMismatch(unittest.TestCase):

    def _ctrl_with_mismatch_state(self, **active_flags):
        """Controller with a server-side bridge component mismatch and active match state."""
        ctrl = make_controller(**active_flags)
        apply_version(ctrl, bridge_comp=_OLDER_BRIDGE_COMPONENT)  # server component is stale
        return ctrl

    # ---- bridge mismatch is deferred while match is active ----

    def _assert_deferred(self, ctrl):
        self.assertIsNotNone(ctrl._pending_version_mismatch)
        kind, _ = ctrl._pending_version_mismatch
        self.assertEqual(kind, "bridge")
        ctrl.bridge_version_mismatch.emit.assert_not_called()

    def test_deferred_during_match(self):
        ctrl = self._ctrl_with_mismatch_state(in_match=True)
        mismatch_detected = ctrl._bridge_version_mismatch_detected()
        self.assertTrue(mismatch_detected)
        if mismatch_detected:
            payload = ctrl._build_version_payload("bridge")
            if ctrl.in_match or ctrl.in_ban_phase or ctrl.in_postmatch:
                ctrl._pending_version_mismatch = ("bridge", payload)
        self._assert_deferred(ctrl)

    def test_deferred_during_ban_phase(self):
        ctrl = self._ctrl_with_mismatch_state(in_ban_phase=True)
        payload = ctrl._build_version_payload("bridge")
        ctrl._pending_version_mismatch = ("bridge", payload)
        self._assert_deferred(ctrl)

    def test_deferred_during_postmatch(self):
        ctrl = self._ctrl_with_mismatch_state(in_postmatch=True)
        payload = ctrl._build_version_payload("bridge")
        ctrl._pending_version_mismatch = ("bridge", payload)
        self._assert_deferred(ctrl)

    # ---- emitted on each exit path ----

    def _ctrl_with_pending(self, kind="bridge"):
        ctrl = make_controller()
        apply_version(ctrl)
        payload = ctrl._build_version_payload(kind)
        ctrl._pending_version_mismatch = (kind, payload)
        return ctrl

    def test_emitted_on_game_close_postmatch(self):
        ctrl = self._ctrl_with_pending("bridge")
        ctrl.in_postmatch = True
        ctrl._on_game_close_postmatch()
        self.assertFalse(ctrl.in_postmatch)
        self.assertIsNone(ctrl._pending_version_mismatch)
        ctrl.bridge_version_mismatch.emit.assert_called_once()

    def test_emitted_on_ws_postmatch_closed(self):
        ctrl = self._ctrl_with_pending("bridge")
        ctrl.in_postmatch = True
        ctrl._on_ws_postmatch_closed()
        self.assertFalse(ctrl.in_postmatch)
        self.assertIsNone(ctrl._pending_version_mismatch)
        ctrl.bridge_version_mismatch.emit.assert_called_once()

    def test_emitted_on_match_scrapped(self):
        ctrl = self._ctrl_with_pending("bridge")
        ctrl.in_match = True
        ctrl._on_ws_match_scrapped()
        self.assertFalse(ctrl.in_match)
        self.assertIsNone(ctrl._pending_version_mismatch)
        ctrl.bridge_version_mismatch.emit.assert_called_once()

    def test_emitted_on_stale_match_state_exit(self):
        ctrl = self._ctrl_with_pending("bridge")
        ctrl.in_match = True
        # Simulate _query_active_match finding no active match
        ctrl.in_match = False
        ctrl.in_ban_phase = False
        ctrl.udp.send_to_game({"event": "match_not_found"})
        ctrl._emit_pending_version_mismatch()
        self.assertIsNone(ctrl._pending_version_mismatch)
        ctrl.bridge_version_mismatch.emit.assert_called_once()

    def test_game_mismatch_emitted_on_postmatch_close(self):
        ctrl = self._ctrl_with_pending("game")
        ctrl.in_postmatch = True
        ctrl._on_game_close_postmatch()
        self.assertIsNone(ctrl._pending_version_mismatch)
        ctrl.game_version_mismatch.emit.assert_called_once()

    # ---- stop_networking called on deferred bridge emit ----

    def test_stop_networking_called_on_deferred_bridge_emit(self):
        ctrl = self._ctrl_with_pending("bridge")
        ctrl._emit_pending_version_mismatch()
        ctrl.ws.disconnect_from_server.assert_called()

    def test_stop_networking_called_on_deferred_game_emit(self):
        ctrl = self._ctrl_with_pending("game")
        ctrl._emit_pending_version_mismatch()
        ctrl.ws.disconnect_from_server.assert_called()

    # ---- cleared on logout ----

    def test_pending_cleared_on_logout(self):
        ctrl = self._ctrl_with_pending("bridge")
        ctrl.logout()
        self.assertIsNone(ctrl._pending_version_mismatch)

    # ---- no-op when nothing pending ----

    def test_emit_is_noop_when_nothing_pending(self):
        ctrl = make_controller()
        apply_version(ctrl)
        ctrl._emit_pending_version_mismatch()  # must not raise
        ctrl.bridge_version_mismatch.emit.assert_not_called()
        ctrl.game_version_mismatch.emit.assert_not_called()

    # ---- second mismatch overwrites first ----

    def test_second_pending_overwrites_first(self):
        ctrl = make_controller()
        apply_version(ctrl)
        ctrl._pending_version_mismatch = ("bridge", {"scope": "bridge"})
        ctrl._pending_version_mismatch = ("game",   {"scope": "game"})
        kind, payload = ctrl._pending_version_mismatch
        self.assertEqual(kind, "game")


# ---------------------------------------------------------------------------
# _build_version_payload structure
# ---------------------------------------------------------------------------

class TestBuildVersionPayload(unittest.TestCase):

    def test_payload_keys_present(self):
        ctrl = make_controller()
        apply_version(ctrl)
        p = ctrl._build_version_payload("bridge", "https://example.com/dl")
        for key in ("scope", "standard_version", "local_bridge_standard",
                    "local_bridge_component", "local_game_component",
                    "server_bridge_component", "server_game_component",
                    "bridge_download_url", "game_download_url"):
            self.assertIn(key, p, f"missing key: {key}")

    def test_scope_set_correctly(self):
        ctrl = make_controller()
        apply_version(ctrl)
        self.assertEqual(ctrl._build_version_payload("bridge")["scope"], "bridge")
        self.assertEqual(ctrl._build_version_payload("game")["scope"],   "game")

    def test_bridge_download_url_passed_through(self):
        ctrl = make_controller()
        apply_version(ctrl)
        url = "https://example.com/bridge.zip"
        p = ctrl._build_version_payload("bridge", url)
        self.assertEqual(p["bridge_download_url"], url)


if __name__ == "__main__":
    unittest.main(verbosity=2)
