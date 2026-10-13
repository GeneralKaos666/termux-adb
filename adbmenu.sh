#!/data/data/com.termux/files/usr/bin/bash
#
# adbmenu — interactive menu of the ADB tools.
# Usage: adbmenu   (no arguments)

set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'

PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
NATIVE_ADB="$PREFIX/bin/adb"

banner() {
  echo -e "${BLUE}"
  echo
  echo "   █████╗ ██████╗ ██████╗     ███╗   ███╗██╗   ██╗██╗  ████████╗██╗   ██╗███████╗██████╗ ███████╗ ███████╗"
  echo "  ██╔══██╗██╔══██╗██╔══██╗    ████╗ ████║██║   ██║██║  ╚══██╔══╝██║   ██║██╔════╝██╔══██╗██╔════╝ ██╔════╝"
  echo "  ███████║██║  ██║██████╔╝    ██╔████╔██║██║   ██║██║     ██║   ██║   ██║█████╗  ██████╔╝███████╗ █████╗  "
  echo "  ██╔══██║██║  ██║██╔═══╝     ██║╚██╔╝██║██║   ██║██║     ██║   ██║   ██║██╔══╝  ██╔══██╗╚════██║ ██╔══╝  "
  echo "  ██║  ██║██████╔╝██║         ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ╚██████╔╝███████╗██║  ██║███████║ ███████╗"
  echo "  ╚═╝  ╚═╝╚═════╝ ╚═╝         ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝    ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝ ╚══════╝"
  echo
  echo -e "${NC}${GREEN}Termux ADB — no root, no bootloader${NC}"
  echo
}

menu() {
  echo "Select an option:"
  echo "  1) Connect wireless (another device, Android 11+)   [adbw]"
  echo "  2) Connect to this device (localhost)               [adblocalhost]"
  echo "  3) List USB OTG devices                             [adbotg]"
  echo "  4) Device status                                    [adb devices -l]"
  echo "  5) Android shell                                    [adb shell]"
  echo "  6) Mirror screen via scrcpy"
  echo "  7) Bash shell in the ADB session                    [ADBash.sh]"
  echo "  8) Install APK                                      [adb install]"
  echo "  9) Download file                                    [adb pull]"
  echo " 10) Upload file                                      [adb push]"
  echo " 11) Full diagnostics                                 [adbs]"
  echo " 12) Pair a new device                                [adbpair]"
  echo "  q) Quit"
  echo
}

assure_device() {
  if ! "$NATIVE_ADB" devices 2>/dev/null | grep -qE "^([0-9]|.*device)"; then
    echo -e "${YELLOW}[!]${NC} No device connected."
    read -rp "Connect first? (1=wireless, 2=localhost, Enter=continue) " A
    case "$A" in
      1) adbw ;;
      2) adblocalhost ;;
      *) echo "Continuing..." ;;
    esac
  fi
}

loop() {
  while :; do
    menu
    read -rp "Option: " OP
    case "$OP" in
      1) adbw ;;
      2) adblocalhost ;;
      3) adbotg ;;
      4) adb devices -l ;;
      5) assure_device; adb shell ;;
      6) assure_device; scrcpy ;;
      7) assure_device; ADBash.sh ;;
      8) read -rp 'APK path: ' apk; adb install "$apk" ;;
      9) read -rp 'File on device: ' remote; adb pull "$remote" ;;
     10) read -rp 'Local file: ' local; adb push "$local" /sdcard/ ;;
     11) adbs ;;
     12) adbpair ;;
     q|Q) echo -e "${GREEN}Finished.${NC}"; exit 0 ;;
      *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
  done
}

banner
loop