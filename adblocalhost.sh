#!/data/data/com.termux/files/usr/bin/bash
#
# adblocalhost — connects to this device (127.0.0.1) via wireless debugging.
# Procedure based on the localhost pairing guides (local ADB).

set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

info() { echo -e "${GREEN}[*]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1" >&2; exit 1; }

command -v adb >/dev/null 2>&1 || fail "adb missing"

echo
info "ADB on this device (127.0.0.1) — Android 11+"
echo
echo -e "${BLUE}Preparation:${NC} Enable 'Wireless debugging' in Developer options."
echo -e "${BLUE}Recommendation:${NC} use split-screen (the pairing dialog closes when you leave it)."
echo
read -rp "Have you paired 127.0.0.1 before? [y/N] " PAIRED

if [ "$PAIRED" != "y" ] && [ "$PAIRED" != "Y" ]; then
  read -rp "PAIRING port (menu 'Pair device with pairing code'): " PP
  [ -n "$PP" ] && [ "$PP" -eq "$PP" ] 2>/dev/null || fail "Invalid port"
  read -rp "6-digit code: " CODE
  [ -z "$CODE" ] && fail "Code cannot be empty"
  info "Pairing..."
  timeout 15 adb pair "127.0.0.1:$PP" "$CODE" || fail "Pairing failed"
fi

read -rp "CONNECTION port (menu 'IP address & Port' — different from the pairing port): " CP
[ -n "$CP" ] && [ "$CP" -eq "$CP" ] 2>/dev/null || fail "Invalid port"

info "Connecting..."
timeout 15 adb connect "127.0.0.1:$CP" || fail "Connection failed"
adb devices

echo
echo "Available services after connecting:"
echo "  adb shell                  — Android shell"
echo "  ADBash.sh                  — Bash shell in the ADB session"
echo "  scrcpy                     — screen mirroring"
echo "  adb pull/push/install      — files and apps"