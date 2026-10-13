#!/data/data/com.termux/files/usr/bin/bash
#
# adbw-sweep — wireless ADB dynamic port discovery without root (item 5 of §12.5)
#
# Replaces `adb mdns services`, which does NOT exist in the Termux android-tools
# binary (the nmeum build compiles with ANDROID_TOOLS_ADB_ENABLE_MDNS=OFF —
# research §12.1). It scans the ephemeral TLS range 32768-60999 with nmap and
# tries adb connect on every open port until one becomes a "device" transport.
#
# Usage: adbw-sweep <IP>          # scans and connects
#        adbw-sweep <IP> --dry    # only lists open ports, does not connect
#
# The port found is written to ~/.cache/adbw-state (same file as --watch), so
# the watch starts trying it first.

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
info() { echo -e "${GREEN}[*]${NC} $1"; }
fail() {
	echo -e "${RED}[✗]${NC} $1" >&2
	exit 1
}
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

command -v adb >/dev/null 2>&1 || fail "adb missing — install: pkg install android-tools"
command -v nmap >/dev/null 2>&1 || fail "nmap missing — install: pkg install nmap"

IP="${1:-}"
DRY="${2:-}"
[ -n "$IP" ] || {
	sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
	exit 1
}
echo "$IP" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || fail "invalid IP: '$IP'"

info "Scanning $IP (32768-60999, the dynamic TLS port of Android 11+ wireless debugging)..."
PORTS="$(nmap -p 32768-60999 --open -T4 "$IP" -oG - 2>/dev/null | grep -oE '[0-9]+/open' | cut -d/ -f1 | sort -n)"

if [ -z "$PORTS" ]; then
	fail "no open port in the range. Check: is wireless debugging on? correct IP? same network?"
fi

N=$(echo "$PORTS" | wc -l)
info "open port(s): $(echo $PORTS | tr '\n' ' ') ($N)"

if [ "$DRY" = "--dry" ]; then
	info "--dry: no connection. Try: adbw-sweep $IP (without --dry)"
	exit 0
fi

STATE="${HOME}/.cache/adbw-state"
for P in $PORTS; do
	info "trying adb connect $IP:$P..."
	timeout 8 adb connect "$IP:$P" >/dev/null 2>&1
	if adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {found=1} END {exit !(found)}'; then
		info "connected to $IP:$P ✓"
		mkdir -p "$(dirname "$STATE")"
		printf 'addr=%s:%s\nlast_seen=%s\n' "$IP" "$P" "$(date +%s)" >"$STATE"
		info "saved to $STATE — adbw --watch will try this port first"
		adb devices
		exit 0
	fi
done

fail "open ports found ($PORTS) but none became an adb device transport —
it may be another service listening; confirm that Wireless debugging is on"
