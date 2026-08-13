#!/data/data/com.termux/files/usr/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[*]${NC} $1"; }
step()  { echo -e "${BLUE}[>]${NC} $1"; }

echo
info "termux-adb uninstaller v3.1.0"
echo

step "Removing termux-adb package..."
apt-get --assume-yes remove termux-adb 2>/dev/null || true

step "Cleaning up leftover apt artifacts (if any)..."
rm -f "$PREFIX/etc/apt/sources.list.d/termux-adb.list"
rm -f "$PREFIX/etc/apt/trusted.gpg.d/nohajc.gpg"

step "Removing symlinks and extra tools..."
rm -f "$PREFIX/bin/adb"
rm -f "$PREFIX/bin/fastboot"
rm -f "$PREFIX/bin/wireless-adb"
rm -f "$PREFIX/bin/termux-adb-doctor"
rm -f "$PREFIX/bin/termux-adb-update"

step "Cleaning shell RC config..."
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$RC" ] || continue
  sed -i '/ANDROID_USER_HOME=.*\.termux-adb/d' "$RC"
  sed -i '/ANDROID_SDK_HOME=.*\.termux-adb/d' "$RC"
done

step "Removing isolated data..."
rm -rf "$HOME/.termux-adb"

echo
if command -v termux-adb >/dev/null 2>&1; then
  echo -e "${RED}[!]${NC} termux-adb still on PATH — removal may have partially failed"
else
  info "termux-adb fully removed"
fi
echo