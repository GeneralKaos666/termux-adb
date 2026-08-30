#!/data/data/com.termux/files/usr/bin/bash
#
# adbs — overall status of the ADB system (quick diagnostics).
# Consolidates wireless-adb-doctor + termux-adb-doctor into a single view.

set -uo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

PREFIX=${PREFIX:-/data/data/com.termux/files/usr}

cat_tool() { timeout 3 "$1" version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[^ ]*' | head -1; }

echo
echo -e "${BLUE}Termux ADB — Diagnostics${NC}"
echo "================================="
echo

echo "Backends:"
for b in adb termux-adb; do
  if command -v "$b" >/dev/null 2>&1; then
    V="$(cat_tool "$b")"
    ok "$b: ${V:-(version OK)}"
  else
    fail "$b: missing"
  fi
done

# termux-fastboot is slow on USB enumeration — only check presence.
for b in fastboot termux-fastboot; do
  if command -v "$b" >/dev/null 2>&1; then
    ok "$b: present"
  else
    fail "$b: missing"
  fi
done
echo

echo "Termux:API / USB:"
if command -v termux-usb >/dev/null 2>&1; then
  CACHE="$HOME/.termux-adb/otg.cache"
  if [ -f "$CACHE" ]; then
    if [ "$(cat "$CACHE" 2>/dev/null)" = "1" ]; then
      ok "termux-usb: OTG devices connected"
    else
      warn "termux-usb available — no OTG device connected"
    fi
  else
    OUT="$(timeout 4 termux-usb -l 2>&1)"
    RC=$?
    if [ $RC -ne 0 ]; then
      fail "termux-usb failed (code $RC) — install the Termux:API app via F-Droid"
    elif [ "$OUT" = "[]" ]; then
      warn "termux-usb available — no OTG device connected"
    else
      ok "termux-usb: $(echo "$OUT" | tr -d '[]" ' | sed 's/,/, /g')"
    fi
  fi
else
  fail "termux-usb missing (pkg install termux-api)"
fi
echo

echo "Environment:"
if [ -n "${ANDROID_USER_HOME:-}" ]; then
  ok "ANDROID_USER_HOME=$ANDROID_USER_HOME"
else
  warn "ANDROID_USER_HOME not set"
fi
if command -v scrcpy >/dev/null 2>&1; then
  ok "scrcpy: $(timeout 3 scrcpy --version 2>/dev/null | head -1)"
else
  warn "scrcpy not installed (pkg install scrcpy)"
fi
if [ -x "$HOME/.local/bin/ADBash.sh" ]; then
  ok "ADBash: present"
else
  warn "ADBash missing"
fi
echo

echo "Devices (adb devices):"
timeout 5 adb devices 2>&1 || warn "adb devices took too long — run 'adb kill-server' and try again"
echo