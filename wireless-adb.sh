#!/data/data/com.termux/files/usr/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[*]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1" >&2; }
fail()  { echo -e "${RED}[✗]${NC} $1" >&2; exit 1; }
step()  { echo -e "${BLUE}[>]${NC} $1"; }

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

command -v termux-adb >/dev/null 2>&1 || fail "termux-adb not installed. Run install.sh first."

validate_addr() {
  echo "$1" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$' || fail "Invalid format: '$1'. Use IP:PORT (e.g. 192.168.1.100:37123)"
}

echo
info "Wireless ADB (Android 11+, no cable/OTG, no root)"
echo

LOCAL_IP="$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[0-9.]+' || true)"
if [ -n "$LOCAL_IP" ]; then
  info "Your local IP: $LOCAL_IP"
fi

echo -e "${BLUE}On the target device:${NC} Settings > Developer options > Wireless debugging"
echo

read -rp "Have you paired this device before? [y/N] " PAIRED

if [ "$PAIRED" != "y" ] && [ "$PAIRED" != "Y" ]; then
  echo
  step "Pairing required"
  read -rp "Pairing IP:port (screen 'Pair with code'): " PAIR_ADDR
  validate_addr "$PAIR_ADDR"
  read -rp "Pairing code (6 digits): " PAIR_CODE
  [ -z "$PAIR_CODE" ] && fail "Code cannot be empty"
  info "Pairing..."
  timeout 15 termux-adb pair "$PAIR_ADDR" "$PAIR_CODE" || fail "Pairing failed (15s timeout or wrong credentials)"
  info "Paired successfully"
fi

echo
read -rp "Connection IP:port (connection port, on the main wireless debugging screen): " CONNECT_ADDR
validate_addr "$CONNECT_ADDR"

step "Connecting..."
timeout 15 termux-adb connect "$CONNECT_ADDR" || fail "Connection failed (15s timeout). Check the IP/port and that wireless debugging is on."

echo
info "Connected. Devices:"
termux-adb devices
echo