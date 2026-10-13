#!/data/data/com.termux/files/usr/bin/bash
#
# adbotg — lists and checks USB OTG devices via termux-usb (no root)
# Usage: adbotg

set -uo pipefail

PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
USB="$PREFIX/bin/termux-usb"

if ! [ -x "$USB" ]; then
  echo "[ERROR] termux-usb missing. Install with: pkg install termux-api" >&2
  exit 1
fi

echo "[*] Detected USB devices (termux-usb -l):"
"$USB" -l 2>&1

echo
echo "[*] To grant permission to a device:"
echo "    termux-usb -r /dev/bus/usb/001/002"
echo "[*] To use it with adb:"
echo "    adb devices"