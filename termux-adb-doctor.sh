#!/data/data/com.termux/files/usr/bin/bash
set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ISSUES=$((ISSUES + 1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

ISSUES=0

echo
echo "termux-adb doctor v4.0.0"
echo "========================"
echo

# 1. Binaries
echo "Binaries:"
if command -v termux-adb >/dev/null 2>&1; then
  VER="$(timeout 3 termux-adb version 2>/dev/null | head -1 || echo '?')"
  ok "termux-adb: $VER"
else
  fail "termux-adb not found on PATH"
fi

if command -v termux-fastboot >/dev/null 2>&1; then
  VER="$(timeout 3 termux-fastboot --version 2>/dev/null | head -1 || echo '?')"
  ok "termux-fastboot: $VER"
else
  fail "termux-fastboot not found on PATH"
fi
echo

# 2. Termux:API
echo "Termux:API:"
if command -v termux-usb >/dev/null 2>&1; then
  ok "termux-usb present"
else
  fail "termux-usb not found — install termux-api (pkg install termux-api)"
fi

if timeout 3 termux-usb -l >/dev/null 2>&1; then
  ok "Termux:API app functional"
else
  warn "termux-usb -l failed — the Termux:API app may not be installed (F-Droid)"
fi
echo

# 3. dpkg package
echo "Package:"
if dpkg -s termux-adb >/dev/null 2>&1; then
  PKG_VER="$(dpkg -s termux-adb 2>/dev/null | grep '^Version:' | cut -d' ' -f2)"
  ok "termux-adb installed via dpkg ($PKG_VER)"
else
  fail "termux-adb package not installed"
fi

if wget -q --spider --timeout=5 "https://api.github.com/repos/GeneralKaos666/termux-adb/releases/latest" 2>/dev/null; then
  ok "GitHub Releases reachable"
else
  warn "GitHub Releases unreachable (no internet or API rate limit)"
fi
echo

# 4. Configuration
echo "Configuration:"
if [ -n "$ANDROID_USER_HOME" ]; then
  ok "ANDROID_USER_HOME=$ANDROID_USER_HOME"
elif [ -n "$ANDROID_SDK_HOME" ]; then
  warn "ANDROID_SDK_HOME set (deprecated) — run install.sh to upgrade to ANDROID_USER_HOME"
else
  warn "ANDROID_USER_HOME not set — adb data will go to \$HOME (run install.sh to isolate)"
fi

if [ -d "$HOME/.termux-adb" ]; then
  ok "~/.termux-adb directory exists"
else
  warn "~/.termux-adb does not exist (it will be created on first adb use)"
fi
echo

# 5. Unified front-ends
echo "Front-ends (unified adb):"
if [ -x "$HOME/.local/bin/adb" ]; then
  ok "adb front-end OK"
else
  warn "adb front-end missing (run install.sh)"
fi

if [ -x "$HOME/.local/bin/fastboot" ]; then
  ok "fastboot front-end OK"
else
  warn "fastboot front-end missing (run install.sh)"
fi

if [ -e "$HOME/.local/bin/adb-otg-watcher" ]; then
  ok "adb-otg-watcher front-end OK"
else
  warn "adb-otg-watcher missing (run install.sh)"
fi
echo

# 6. Extra tools
echo "Extra tools:"
for TOOL in wireless-adb termux-adb-update adbs adbmenu adbpair adbotg adbw adblocalhost; do
  if command -v "$TOOL" >/dev/null 2>&1; then
    ok "$TOOL installed"
  else
    warn "$TOOL not installed (run install.sh to add it)"
  fi
done
echo

# Result
echo "========================"
if [ "$ISSUES" -eq 0 ]; then
  echo -e "${GREEN}All OK — no problems found; the environment is ready to use.${NC}"
else
  echo -e "${RED}$ISSUES problem(s) found — run install.sh to fix them.${NC}"
fi
echo