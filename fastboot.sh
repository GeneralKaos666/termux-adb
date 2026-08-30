#!/data/data/com.termux/files/usr/bin/bash
#
# fastboot — unified front-end for termux-fastboot
# ================================================
# No root, no bootloader. Forwards to termux-fastboot,
# the OTG-compatible (termux-usb) implementation on Termux.

set -uo pipefail

PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
TERMUX_FASTBOOT="$PREFIX/bin/termux-fastboot"

case "${1:-}" in
  -h|--help|version) exec "$TERMUX_FASTBOOT" "$@" ;;
esac

exec "$TERMUX_FASTBOOT" "$@"