#!/data/data/com.termux/files/usr/bin/bash
#
# adbpair — quick wireless pairing (Android 11+)
# Usage: adbpair IP:PAIRING_PORT CODE [IP:CONNECTION_PORT]
# If the connection port is not given, only the pairing is run.

set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

usage() {
  echo "Usage: adbpair IP:PAIRING_PORT CODE [IP:CONNECTION_PORT]" >&2
  exit 1
}

[ $# -lt 2 ] || [ $# -gt 3 ] && usage

PAIR_ADDR="$1"; CODE="$2"; CONNECT_ADDR="${3:-}"

echo -e "${GREEN}[*]${NC} Pairing with $PAIR_ADDR ..."
adb pair "$PAIR_ADDR" "$CODE"
[ $? -eq 0 ] || { echo -e "${RED}[!]${NC} Pairing failed."; exit 1; }

if [ -n "$CONNECT_ADDR" ]; then
  echo -e "${GREEN}[*]${NC} Connecting to $CONNECT_ADDR ..."
  adb connect "$CONNECT_ADDR"
fi

echo -e "${GREEN}[*]${NC} Devices:"
adb devices