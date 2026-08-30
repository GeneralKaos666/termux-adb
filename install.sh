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

VERSION="4.0.0"
PKG_VERSION="0.2.3"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
RELEASE_URL="https://github.com/GeneralKaos666/termux-adb/releases/download/v${VERSION}"
RAW_URL="https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main"

declare -A DEB_SHA256
DEB_SHA256[aarch64]="d1f2e59ea3a118114d55b5439931c93114831a0eabfcf3b2799e4c6c4ad5b847"

# Scripts installed on PATH (the .sh prefix is removed)
EXTRA_SCRIPTS="wireless-adb termux-adb-doctor termux-adb-update adbotg adbpair adbw adblocalhost adbs adbmenu"
# Scripts installed in $HOME/.local/bin (front-ends of the unified adb)
LOCALBIN_SCRIPTS="adb fastboot adb-otg-watcher"

echo
info "Termux ADB Unified — installer v${VERSION}"
echo

# 1. Architecture check
step "Checking architecture..."
ARCH="$(uname -m)"
case "$ARCH" in
  aarch64) DEB_ARCH="aarch64" ;;
  armv7l|armv8l|arm)
    fail "Architecture '$ARCH' is not supported yet: only aarch64 (64-bit ARM) builds are provided. 32-bit ARM (arm/armv7l) packages are not currently published."
    ;;
  *)
    fail "Architecture '$ARCH' is not supported. Supported: aarch64"
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
  fail "Failed to download $DEB_FILE. Check your connection or open an issue at github.com/GeneralKaos666/termux-adb"
fi

step "Verifying integrity (SHA256)..."
ACTUAL_SHA="$(sha256sum "$DEB_TMP" | cut -d' ' -f1)"
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  rm -f "$DEB_TMP"
  fail "SHA256 mismatch! Expected: $EXPECTED_SHA / Got: $ACTUAL_SHA. Possible corruption. Open an issue at github.com/GeneralKaos666/termux-adb"
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

# 6. Extra tools on PATH ($PREFIX/bin)
step "Installing extra tools..."
for SCRIPT in $EXTRA_SCRIPTS; do
  if wget -qO "$PREFIX/bin/$SCRIPT" --timeout=10 "${RAW_URL}/${SCRIPT}.sh" 2>/dev/null; then
    chmod +x "$PREFIX/bin/$SCRIPT"
    info "$SCRIPT installed"
  else
    warn "Failed to download $SCRIPT (non-critical)"
  fi
done

# 7. Unified front-ends in $HOME/.local/bin
#    (take precedence over $PREFIX/bin in PATH and route OTG/wireless)
step "Installing unified front-ends..."
mkdir -p "$HOME/.local/bin"
for SCRIPT in $LOCALBIN_SCRIPTS; do
  if wget -qO "$HOME/.local/bin/$SCRIPT" --timeout=10 "${RAW_URL}/${SCRIPT}.sh" 2>/dev/null; then
    chmod +x "$HOME/.local/bin/$SCRIPT"
    info "$SCRIPT installed"
  else
    warn "Failed to download $SCRIPT (non-critical)"
  fi
done

# Ensure $HOME/.local/bin is on PATH
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH"
     for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
       [ -f "$RC" ] || continue
       grep -q '\.local/bin' "$RC" 2>/dev/null && continue
       echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
     done
     ;;
esac

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
info "Commands: adb, fastboot, adbw, adbmenu, adbs, adbpair, adbotg, adblocalhost, wireless-adb, termux-adb-doctor, termux-adb-update"
info "Self-contained distribution — binaries hosted in our repo."
echo