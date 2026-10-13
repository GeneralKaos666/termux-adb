#!/data/data/com.termux/files/usr/bin/bash
#
# adbw — interactive wireless connection (Android 11+)
# Includes pairing with a code and the subsequent connection.
# The pairing port ≠ connection port (see the wireless debugging screen).

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[*]${NC} $1"; }
fail() {
	echo -e "${RED}[✗]${NC} $1" >&2
	exit 1
}
step() { echo -e "${BLUE}[>]${NC} $1"; }

command -v adb >/dev/null 2>&1 || fail "adb missing — install: pkg install android-tools"

# -----------------------------------------------------------------------------
# adbw --watch — automatic reconnection loop (item 2 of §12.5)
#
# Backoff 3s→30s (exponential, cap 30s). State in ~/.cache/adbw-state:
#   addr=<ip:port>     last known port (tried first on every cycle)
#   last_seen=<epoch>  last time the transport responded
#
# With a fixed port (adbw-root-porta.sh), addr is always ip:5555 and
# reconnection becomes trivial. Without root, it tries the known port and,
# every 5 consecutive failures, runs an nmap sweep of the dynamic range
# (32768-60999) if nmap is installed (the Termux android-tools binary does
# NOT have mDNS — see research §12.1).
# -----------------------------------------------------------------------------
STATE_FILE="${HOME}/.cache/adbw-state"
WATCH_INTERVAL_MIN=3
WATCH_INTERVAL_MAX=30

watch_load_state() {
	addr=""
	last_seen=0
	[ -f "$STATE_FILE" ] || return 0
	# shellcheck disable=SC1090
	. "$STATE_FILE"
	W_ADDR="${addr:-}"
	W_LAST_SEEN="${last_seen:-0}"
}

watch_save_state() {
	mkdir -p "$(dirname "$STATE_FILE")"
	cat >"$STATE_FILE" <<EOF
addr=$W_ADDR
last_seen=$W_LAST_SEEN
EOF
}

watch_is_connected() {
	adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {found=1} END {exit !(found)}'
}

watch_try_connect() {
	[ -n "${W_ADDR:-}" ] || return 1
	timeout 8 adb connect "$W_ADDR" >/dev/null 2>&1
	watch_is_connected
}

watch_sweep() {
	command -v nmap >/dev/null 2>&1 || {
		info "nmap missing (pkg install nmap) — sweep unavailable"
		return 1
	}
	[ -n "${W_IP:-}" ] || return 1
	info "nmap sweep of $W_IP (dynamic TLS port 32768-60999)..."
	local PORTS
	PORTS="$(nmap -p 32768-60999 --open -T4 "$W_IP" -oG - 2>/dev/null | grep -oE '[0-9]+/open' | cut -d/ -f1)"
	[ -z "$PORTS" ] && {
		info "no open port found in the range"
		return 1
	}
	local P
	for P in $PORTS; do
		W_ADDR="$W_IP:$P"
		info "trying $W_ADDR..."
		if watch_try_connect; then return 0; fi
	done
	return 1
}

watch_loop() {
	W_IP="${1:-}"
	W_PORT="${2:-}"
	watch_load_state

	# Magisk module termuxadb_rootport detected? → fixed port 5555 always first
	# (the module writes persist.adb.tcp.port=5555 at boot — see README 'Root mode')
	ROOT_PORT="$(getprop persist.adb.tcp.port 2>/dev/null || true)"
	if [ -n "$ROOT_PORT" ] && [ "$ROOT_PORT" != "" ]; then
		if [ -n "$W_IP" ]; then
			W_ADDR="$W_IP:$ROOT_PORT"
			info "Magisk module detected (persist.adb.tcp.port=$ROOT_PORT) — using fixed port"
		elif [ -n "${W_ADDR:-}" ] && [ "${W_ADDR##*:}" != "$ROOT_PORT" ]; then
			W_ADDR="${W_ADDR%%:*}:$ROOT_PORT"
			info "Magisk module detected — rewriting addr to the fixed port: $W_ADDR"
		fi
	fi

	if [ -n "$W_IP" ] && [ -n "$W_PORT" ]; then
		W_ADDR="$W_IP:$W_PORT"
	elif [ -z "${W_ADDR:-}" ]; then
		echo -e "${YELLOW}[!]${NC} no previous state. Use: adbw --watch <IP> [PORT] (once)"
		echo -e "${YELLOW}[!]${NC} with a Magisk module/fixed port: adbw --watch <IP> (the port comes from the prop)"
		echo -e "${YELLOW}[!]${NC} without root: the dynamic PORT is required the first time (it gets saved for the next cycle)"
		exit 1
	fi

	if [ -z "$W_IP" ]; then
		W_IP="${W_ADDR%%:*}"
	fi

	info "watch started: addr=$W_ADDR (state in $STATE_FILE)"
	info "Ctrl+C stops it. Backoff ${WATCH_INTERVAL_MIN}s→${WATCH_INTERVAL_MAX}s"

	local INTERVAL=$WATCH_INTERVAL_MIN
	local FAILS=0
	while true; do
		if watch_is_connected; then
			W_LAST_SEEN="$(date +%s)"
			watch_save_state
			INTERVAL=$WATCH_INTERVAL_MIN
			FAILS=0
			sleep "$INTERVAL"
			continue
		fi

		FAILS=$((FAILS + 1))
		info "no device transport (failure #$FAILS) — trying to reconnect to $W_ADDR..."

		if watch_try_connect; then
			W_LAST_SEEN="$(date +%s)"
			watch_save_state
			info "reconnected to $W_ADDR ✓"
			INTERVAL=$WATCH_INTERVAL_MIN
			FAILS=0
		elif watch_sweep; then
			W_LAST_SEEN="$(date +%s)"
			watch_save_state
			info "reconnected via sweep to $W_ADDR ✓"
			INTERVAL=$WATCH_INTERVAL_MIN
			FAILS=0
		else
			INTERVAL=$((INTERVAL * 2))
			[ "$INTERVAL" -gt "$WATCH_INTERVAL_MAX" ] && INTERVAL=$WATCH_INTERVAL_MAX
			info "failed; next cycle in ${INTERVAL}s"
		fi

		sleep "$INTERVAL"
	done
}

# routing: adbw --watch [IP] [PORT]
if [ "${1:-}" = "--watch" ]; then
	shift
	watch_loop "$@"
fi

validate_addr() {
	echo "$1" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$' || fail "Invalid format: '$1'. Use IP:PORT (e.g. 192.168.1.100:37123)"
}

echo
info "ADB Wireless (Android 11+, no cable/OTG, no root)"
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
	[ -z "$PAIR_CODE" ] && fail "The code cannot be empty"
	info "Pairing..."
	timeout 15 adb pair "$PAIR_ADDR" "$PAIR_CODE" || fail "Pairing failed (15s timeout or wrong credentials)"
	info "Pairing complete"
fi

echo
read -rp "Connection IP:port (connection port, on the main wireless debugging screen): " CONNECT_ADDR
validate_addr "$CONNECT_ADDR"

step "Connecting..."
timeout 15 adb connect "$CONNECT_ADDR" || fail "Connection failed (15s timeout). Check the IP/port and that wireless debugging is on."

# saves state for --watch (item 2): known addr + last_seen
mkdir -p "$HOME/.cache"
printf 'addr=%s\nlast_seen=%s\n' "$CONNECT_ADDR" "$(date +%s)" >"$HOME/.cache/adbw-state"

echo
info "Connected. Devices:"
adb devices
echo
echo "Note: if the device goes offline, run 'adb kill-server' and reconnect."
echo "      The connection port changes on every reboot; the pairing is one-time."
