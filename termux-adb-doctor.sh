#!/data/data/com.termux/files/usr/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ISSUES=$((ISSUES + 1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

ISSUES=0

echo
echo "termux-adb doctor v3.1.0"
echo "========================"
echo

# 1. termux-adb
echo "Binaries:"
if command -v termux-adb >/dev/null 2>&1; then
  VER="$(termux-adb version 2>/dev/null | head -1 || echo '?')"
  ok "termux-adb: $VER"
else
  fail "termux-adb not found on PATH"
fi

if command -v termux-fastboot >/dev/null 2>&1; then
  VER="$(termux-fastboot --version 2>/dev/null | head -1 || echo '?')"
  ok "termux-fastboot: $VER"
else
  fail "termux-fastboot not found on PATH"
fi
echo

# 2. termux-api
echo "Termux:API:"
if command -v termux-usb >/dev/null 2>&1; then
  ok "termux-usb present"
else
  fail "termux-usb not found — install termux-api (pkg install termux-api)"
fi

if termux-usb -l >/dev/null 2>&1; then
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

if wget -q --spider --timeout=5 "https://api.github.com/repos/rianprei/termux-adb/releases/latest" 2>/dev/null; then
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

# 5. Extra tools and symlinks
echo "Extras:"
for TOOL in wireless-adb termux-adb-update; do
  if command -v "$TOOL" >/dev/null 2>&1; then
    ok "$TOOL installed"
  else
    warn "$TOOL not installed (run install.sh to add it)"
  fi
done

echo
echo "Symlinks:"
if [ -L "$PREFIX/bin/adb" ] && [ "$(readlink "$PREFIX/bin/adb")" = "$PREFIX/bin/termux-adb" ]; then
  ok "adb -> termux-adb"
else
  warn "adb symlink not found (run install.sh to create it)"
fi

if [ -L "$PREFIX/bin/fastboot" ] && [ "$(readlink "$PREFIX/bin/fastboot")" = "$PREFIX/bin/termux-fastboot" ]; then
  ok "fastboot -> termux-fastboot"
else
  warn "fastboot symlink not found (run install.sh to create it)"
fi
echo

# Result
echo "========================"
if [ "$ISSUES" -eq 0 ]; then
  echo -e "${GREEN}All OK — no problems found.${NC}"
else
  echo -e "${RED}$ISSUES problem(s) found.${NC}"
fi
echo