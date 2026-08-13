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

VERSION="3.0.0"
PKG_VERSION="0.2.3"
RELEASE_URL="https://github.com/rianprei/termux-adb/releases/download/v${VERSION}"
RAW_URL="https://raw.githubusercontent.com/rianprei/termux-adb/main"

declare -A DEB_SHA256
DEB_SHA256[aarch64]="3f571ada3ea25671ab8a6d227c5f12f7e0412d8b62bf60e7948ae99a4c38c518"
DEB_SHA256[arm]="faf1ec047fa69dbafc9550574bdf4c91bc7c12c5372684d6c5d9cbe384e861a0"

echo
info "termux-adb installer v${VERSION} (self-contained)"
echo

# 1. Arch check
step "Checking architecture..."
ARCH="$(uname -m)"
case "$ARCH" in
  aarch64) DEB_ARCH="aarch64" ;;
  armv7l|armv8l|arm) DEB_ARCH="arm" ;;
  *)
    fail "Architecture '$ARCH' not supported. Supported: aarch64, arm (armv7l/armv8l)"
    ;;
esac
info "Architecture: $ARCH → package $DEB_ARCH"

# 2. Base dependencies
step "Installing base dependencies..."
apt-get update -qq
apt-get --assume-yes install wget > /dev/null

# 3. termux-api
step "Checking termux-api..."
if ! command -v termux-usb >/dev/null 2>&1; then
  warn "termux-usb not found. Installing termux-api..."
  apt-get --assume-yes install termux-api > /dev/null
  info "termux-api installed. Also install the Termux:API app (F-Droid) if you haven't already."
else
  info "termux-api present"
fi

# 4. Download and install the .deb directly from our repo (no external repo dependency)
DEB_FILE="termux-adb_${PKG_VERSION}_${DEB_ARCH}.deb"
DEB_TMP="$(mktemp)"
EXPECTED_SHA="${DEB_SHA256[$DEB_ARCH]}"

step "Downloading $DEB_FILE..."
if ! wget -qO "$DEB_TMP" --timeout=30 "${RELEASE_URL}/${DEB_FILE}" 2>/dev/null; then
  rm -f "$DEB_TMP"
  fail "Failed to download $DEB_FILE. Check your connection or open an issue at github.com/rianprei/termux-adb"
fi

step "Verifying integrity (SHA256)..."
ACTUAL_SHA="$(sha256sum "$DEB_TMP" | cut -d' ' -f1)"
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  rm -f "$DEB_TMP"
  fail "SHA256 mismatch! Expected: $EXPECTED_SHA / Got: $ACTUAL_SHA. Possible corruption. Open an issue at github.com/rianprei/termux-adb"
fi
info "Integrity verified"

step "Installing termux-adb..."
dpkg -i "$DEB_TMP" 2>/dev/null || apt-get --assume-yes -f install > /dev/null
rm -f "$DEB_TMP"

# 5. Isolate adb data
step "Isolating adb data..."
mkdir -p "$HOME/.termux-adb"
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$RC" ] || continue
  grep -q 'ANDROID_USER_HOME=.*\.termux-adb' "$RC" 2>/dev/null && continue
  sed -i '/ANDROID_SDK_HOME=.*\.termux-adb/d' "$RC"
  echo 'export ANDROID_USER_HOME="$HOME/.termux-adb"' >> "$RC"
  echo 'export ANDROID_SDK_HOME="$HOME/.termux-adb"' >> "$RC"
done
export ANDROID_USER_HOME="$HOME/.termux-adb"
export ANDROID_SDK_HOME="$HOME/.termux-adb"
info "adb data isolated in ~/.termux-adb"

# 6. Extra tools
step "Installing extra tools..."
wget -qO "$PREFIX/bin/wireless-adb" --timeout=10 "${RAW_URL}/wireless-adb.sh" 2>/dev/null && chmod +x "$PREFIX/bin/wireless-adb" && info "wireless-adb installed" || warn "Failed to download wireless-adb (non-critical)"
wget -qO "$PREFIX/bin/termux-adb-doctor" --timeout=10 "${RAW_URL}/termux-adb-doctor.sh" 2>/dev/null && chmod +x "$PREFIX/bin/termux-adb-doctor" && info "termux-adb-doctor installed" || warn "Failed to download termux-adb-doctor (non-critical)"
wget -qO "$PREFIX/bin/termux-adb-update" --timeout=10 "${RAW_URL}/termux-adb-update.sh" 2>/dev/null && chmod +x "$PREFIX/bin/termux-adb-update" && info "termux-adb-update installed" || warn "Failed to download termux-adb-update (non-critical)"

# 7. Symlinks adb -> termux-adb, fastboot -> termux-fastboot
step "Creating symlinks..."
ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb"
ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot"
info "adb -> termux-adb, fastboot -> termux-fastboot"

# 8. Health-check
step "Verifying installation..."
echo
if ADB_VER="$(termux-adb version 2>/dev/null | head -1)"; then
  info "termux-adb OK: $ADB_VER"
else
  warn "termux-adb installed but 'termux-adb version' failed. Run 'termux-adb-doctor' to diagnose."
fi

if FB_VER="$(termux-fastboot --version 2>/dev/null | head -1)"; then
  info "termux-fastboot OK: $FB_VER"
else
  warn "termux-fastboot did not respond (may not be available in this version)"
fi

echo
info "Installation complete!"
info "Commands: adb, fastboot, wireless-adb, termux-adb-doctor, termux-adb-update"
info "No external dependencies — binaries hosted in our repo."
echo