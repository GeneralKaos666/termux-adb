#!/data/data/com.termux/files/usr/bin/bash
#
# adbw-root-porta — fixed ADB wireless port via root (item 1 of §12.5)
#
# What it does: writes persist.adb.tcp.port=<port> (default 5555) and restarts
# adbd so it listens on that port PERMANENTLY (survives a reboot, no mDNS, no
# random port). Source of the mechanism: adbd reads service.adb.tcp.port →
# fallback persist.adb.tcp.port (AOSP daemon/main.cpp:275-277).
#
# Strategy (termux-adb-research §12.3 and §10.1):
#   1. setprop persist.adb.tcp.port <port>   — official path (may be denied by SELinux)
#   2. fallback: resetprop <port>            — Magisk resetprop bypasses property_service
#   3. validation: getprop before/after; if the prop doesn't stick, error with diagnostics
#
# WARNING: tcp mode with a fixed port is plaintext+RSA (it isn't the Android 11+
# wireless TLS). Use it only on a trusted network — see docs/SECURITY.md.

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
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

PORT="${1:-5555}"
echo "$PORT" | grep -qE '^[0-9]{1,5}$' || fail "invalid port: '$PORT' (use a number, e.g. 5555)"
[ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || fail "port out of range 1024-65535: $PORT"

# 0. Prerequisites: root
command -v su >/dev/null 2>&1 || fail "'su' command missing — root (Magisk/KernelSU) is required for this script"
su -c 'true' 2>/dev/null || fail "no root permission (grant su access to Termux)"
command -v getprop >/dev/null 2>&1 || fail "getprop missing (run inside Termux on a real Android)"

PROP="persist.adb.tcp.port"

echo
info "Fixed ADB port via root — target: $PORT"
echo

# 1. State before
BEFORE="$(su -c "getprop $PROP" 2>/dev/null || true)"
if [ -n "$BEFORE" ]; then
	info "Current state: $PROP=$BEFORE"
else
	info "Current state: $PROP undefined"
fi

# 2. Attempt 1 — official setprop
step "Trying setprop $PROP $PORT..."
su -c "setprop $PROP $PORT" 2>/dev/null
AFTER="$(su -c "getprop $PROP" 2>/dev/null || true)"

# 3. Fallback — Magisk resetprop (bypasses the property_service/SELinux check)
#    Note: resetprop may not be on the Termux PATH, but it exists in the su
#    (Magisk) environment — hence we try it via su, not via command -v.
if [ "$AFTER" != "$PORT" ]; then
	warn "setprop didn't stick (likely an init AVC denial — expected on newer builds, §10.1)"
	step "Trying resetprop via su (Magisk)..."
	if su -c "resetprop $PROP $PORT" 2>/dev/null; then
		AFTER="$(su -c "getprop $PROP" 2>/dev/null || true)"
	else
		warn "resetprop unavailable or denied (Magisk absent? su doesn't expose resetprop?)"
	fi
fi

[ "$AFTER" = "$PORT" ] || fail "Could not write $PROP (before='$BEFORE' after='$AFTER').
Diagnostics:
  - Confirm that su granted root access to Termux
  - With Magisk: make sure the module/su binary exposes resetprop
  - Without resetprop, the only option is editing /data/property/persistent_properties (NOT recommended)"

info "Prop written: $PROP=$AFTER"

# 4. Apply now — restart adbd (the prop is read when adbd boots)
step "Restarting adbd (setprop ctl.restart adbd)..."
if ! su -c "setprop ctl.restart adbd" 2>/dev/null; then
	warn "ctl.restart failed (SELinux may deny ctl in the su domain) — trying stop/start"
	su -c "stop adbd" 2>/dev/null
	sleep 1
	su -c "start adbd" 2>/dev/null || warn "start adbd failed; the fixed port takes effect from the next reboot"
fi
sleep 2

# 5. Final validation: is adbd listening on the port?
LISTENING="$(netstat -tln 2>/dev/null | grep -c ":$PORT " || true)"
if [ "$LISTENING" -gt 0 ]; then
	info "adbd listening on port $PORT ✓"
	echo
	info "Ready. Connect from any host on the network: adb connect <IP-of-device>:$PORT"
	info "The config persists after a reboot (persist.). To revert: su -c 'resetprop $PROP \"\"; stop adbd; start adbd'"
else
	warn "I couldn't confirm listening on port $PORT right now (netstat), but the prop is written:"
	warn "the fixed port takes effect from the next reboot. Verify with: getprop $PROP"
fi
