#!/data/data/com.termux/files/usr/bin/bash
#
# adb-keys-backup — backup/restore of the adb host RSA keys (item 4 of §12.5)
#
# The keys in ~/.termux-adb (ANDROID_USER_HOME from install.sh) are the adb
# host identity: losing them = re-accepting the RSA prompt on every device.
# Backup = tar czf with the keys; restore puts them back in place with the
# correct permissions.
#
# Usage:
#   adb-keys-backup              # creates a backup in ~/storage/downloads (or $HOME)
#   adb-keys-backup <file>       # restores from the file
#
# Note: adb keygen (key rotation) exists in platform-tools; the Termux binary
# (nmeum) does not include keygen in every version — backup is the safe path
# that does not depend on it.

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

KEYS_DIR="${ANDROID_USER_HOME:-${ANDROID_SDK_HOME:-$HOME/.termux-adb}}"

mode_restore() {
	[ -f "$1" ] || fail "backup file not found: $1"
	tar tzf "$1" >/dev/null 2>&1 || fail "invalid file (not a readable tar.gz): $1"
	mkdir -p "$KEYS_DIR"
	tar xzf "$1" -C "$KEYS_DIR"
	chmod 700 "$KEYS_DIR"
	[ -f "$KEYS_DIR/adbkey" ] && chmod 600 "$KEYS_DIR/adbkey"
	[ -f "$KEYS_DIR/adbkey.pub" ] && chmod 644 "$KEYS_DIR/adbkey.pub"
	info "keys restored in $KEYS_DIR"
	info "restart the server to use them: adb kill-server && adb devices"
}

mode_backup() {
	[ -f "$KEYS_DIR/adbkey" ] || fail "no keys to back up in $KEYS_DIR (run 'adb devices' once to generate them)"

	OUT_DIR="$HOME/storage/downloads"
	[ -d "$OUT_DIR" ] || OUT_DIR="$HOME"
	OUT="$OUT_DIR/adbw-keys-$(date +%Y%m%d-%H%M%S).tar.gz"

	tar czf "$OUT" -C "$KEYS_DIR" adbkey adbkey.pub 2>/dev/null ||
		fail "failed to create $OUT (adbkey/adbkey.pub missing?)"

	chmod 600 "$OUT"
	info "backup created: $OUT (perm 600 — it contains the private key)"
	warn "store it somewhere safe; the adbkey is your adb host identity — anyone who has it can connect without a prompt on authorized devices"
	info "restore: adb-keys-backup '$(basename "$OUT")'"
}

case "${1:-}" in
"") mode_backup ;;
-h | --help)
	sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
	;;
*) mode_restore "$1" ;;
esac
