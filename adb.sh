#!/data/data/com.termux/files/usr/bin/bash
#
# adb — Termux ADB Unified v4.0.0
# ==============================
# Consolidates the Termux ADB implementations into a single command.
#
# Automatic routing (no root, no bootloader):
#   ▪ OTG USB (device→device)      → termux-adb  (nohajc patch via termux-usb)
#   ▪ Wireless / localhost         → native adb  (android-tools, faster)
#
# OTG detection via background watcher → ~1ms decision, no latency.
# The watcher starts on demand and stays alive; never blocks.

set -uo pipefail

PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
NATIVE_ADB="$PREFIX/bin/adb"
TERMUX_ADB="$PREFIX/bin/termux-adb"
TERMUX_USB="$PREFIX/bin/termux-usb"
ADB_DIR="$HOME/.termux-adb"
CACHE="$ADB_DIR/otg.cache"
WATCHER="$HOME/.local/bin/adb-otg-watcher"
WATCHER_PID="$ADB_DIR/otg-watcher.pid"

# Keeps the watcher alive (single instance via flock, cheap).
ensure_watcher() {
  [ -x "$WATCHER" ] || return 0
  if [ -f "$WATCHER_PID" ]; then
    local pid
    pid="$(cat "$WATCHER_PID" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  "$WATCHER" "$CACHE" >/dev/null 2>&1 &
  printf '%s' "$!" > "$WATCHER_PID" 2>/dev/null || true
}

# Reads the OTG cache without blocking (max 1 stat + 1 cat).
has_otg() {
  if [ -x "$TERMUX_USB" ] && [ -f "$CACHE" ]; then
    [ "$(cat "$CACHE" 2>/dev/null || printf '0')" = "1" ] && return 0 || return 1
  fi
  return 1
}

# Purely network/wireless commands → native backend always (faster).
WIRELESS_OPS="pair connect disconnect tcpip mdns reconnect"

case "${1:-}" in
  -h|--help|"")
    echo "adb — Termux ADB Unified v4.0.0"
    echo "  Automatic backend: OTG via termux-usb | wireless via native"
    echo "  No latency: decision via watcher cache"
    echo "Tools: adbpair, adbotg, adbs, adbw, adblocalhost, adbmenu"
    echo
    exit 0
    ;;
  version)
    ensure_watcher
    exec "$NATIVE_ADB" "$@"
    ;;
esac

if [[ " $WIRELESS_OPS " == *" ${1:-} "* ]]; then
  ensure_watcher
  exec "$NATIVE_ADB" "$@"
fi

ensure_watcher

if has_otg; then
  exec "$TERMUX_ADB" "$@"
fi

exec "$NATIVE_ADB" "$@"