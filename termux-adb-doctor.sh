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

<<<<<<< HEAD
# 1. termux-adb
echo "Binaries:"
||||||| 9d7198d
# 1. termux-adb
echo "Binarios:"
=======
# 1. Binários
echo "Binários:"
>>>>>>> main
if command -v termux-adb >/dev/null 2>&1; then
  VER="$(timeout 3 termux-adb version 2>/dev/null | head -1 || echo '?')"
  ok "termux-adb: $VER"
else
<<<<<<< HEAD
  fail "termux-adb not found on PATH"
||||||| 9d7198d
  fail "termux-adb nao encontrado no PATH"
=======
  fail "termux-adb não encontrado no PATH"
>>>>>>> main
fi

if command -v termux-fastboot >/dev/null 2>&1; then
  VER="$(timeout 3 termux-fastboot --version 2>/dev/null | head -1 || echo '?')"
  ok "termux-fastboot: $VER"
else
<<<<<<< HEAD
  fail "termux-fastboot not found on PATH"
||||||| 9d7198d
  fail "termux-fastboot nao encontrado no PATH"
=======
  fail "termux-fastboot não encontrado no PATH"
>>>>>>> main
fi
echo

# 2. Termux:API
echo "Termux:API:"
if command -v termux-usb >/dev/null 2>&1; then
  ok "termux-usb present"
else
<<<<<<< HEAD
  fail "termux-usb not found — install termux-api (pkg install termux-api)"
||||||| 9d7198d
  fail "termux-usb nao encontrado — instale termux-api (pkg install termux-api)"
=======
  fail "termux-usb não encontrado — instale termux-api (pkg install termux-api)"
>>>>>>> main
fi

<<<<<<< HEAD
if termux-usb -l >/dev/null 2>&1; then
  ok "Termux:API app functional"
||||||| 9d7198d
if termux-usb -l >/dev/null 2>&1; then
  ok "app Termux:API funcional"
=======
if timeout 3 termux-usb -l >/dev/null 2>&1; then
  ok "app Termux:API funcional"
>>>>>>> main
else
<<<<<<< HEAD
  warn "termux-usb -l failed — the Termux:API app may not be installed (F-Droid)"
||||||| 9d7198d
  warn "termux-usb -l falhou — app Termux:API pode nao estar instalado (F-Droid)"
=======
  warn "termux-usb -l falhou — o app Termux:API pode não estar instalado (F-Droid)"
>>>>>>> main
fi
echo

# 3. dpkg package
echo "Package:"
if dpkg -s termux-adb >/dev/null 2>&1; then
  PKG_VER="$(dpkg -s termux-adb 2>/dev/null | grep '^Version:' | cut -d' ' -f2)"
  ok "termux-adb installed via dpkg ($PKG_VER)"
else
<<<<<<< HEAD
  fail "termux-adb package not installed"
||||||| 9d7198d
  fail "pacote termux-adb nao instalado"
=======
  fail "pacote termux-adb não instalado"
>>>>>>> main
fi

if wget -q --spider --timeout=5 "https://api.github.com/repos/rianprei/termux-adb/releases/latest" 2>/dev/null; then
<<<<<<< HEAD
  ok "GitHub Releases reachable"
||||||| 9d7198d
  ok "GitHub Releases acessivel"
=======
  ok "GitHub Releases acessível"
>>>>>>> main
else
<<<<<<< HEAD
  warn "GitHub Releases unreachable (no internet or API rate limit)"
||||||| 9d7198d
  warn "GitHub Releases inacessivel (sem internet ou API rate limit)"
=======
  warn "GitHub Releases inacessível (sem internet ou API rate limit)"
>>>>>>> main
fi
echo

<<<<<<< HEAD
# 4. Configuration
echo "Configuration:"
||||||| 9d7198d
# 4. Config
echo "Configuracao:"
=======
# 4. Configuração
echo "Configuração:"
>>>>>>> main
if [ -n "$ANDROID_USER_HOME" ]; then
  ok "ANDROID_USER_HOME=$ANDROID_USER_HOME"
elif [ -n "$ANDROID_SDK_HOME" ]; then
<<<<<<< HEAD
  warn "ANDROID_SDK_HOME set (deprecated) — run install.sh to upgrade to ANDROID_USER_HOME"
||||||| 9d7198d
  warn "ANDROID_SDK_HOME definido (deprecated) — rode install.sh para atualizar para ANDROID_USER_HOME"
=======
  warn "ANDROID_SDK_HOME definido (descontinuado) — rode install.sh para migrar para ANDROID_USER_HOME"
>>>>>>> main
else
<<<<<<< HEAD
  warn "ANDROID_USER_HOME not set — adb data will go to \$HOME (run install.sh to isolate)"
||||||| 9d7198d
  warn "ANDROID_USER_HOME nao definido — dados do adb vao para \$HOME (rode install.sh para isolar)"
=======
  warn "ANDROID_USER_HOME não definido — os dados do adb vão para \$HOME (rode install.sh para isolar)"
>>>>>>> main
fi

if [ -d "$HOME/.termux-adb" ]; then
<<<<<<< HEAD
  ok "~/.termux-adb directory exists"
||||||| 9d7198d
  ok "diretorio ~/.termux-adb existe"
=======
  ok "diretório ~/.termux-adb existe"
>>>>>>> main
else
<<<<<<< HEAD
  warn "~/.termux-adb does not exist (it will be created on first adb use)"
||||||| 9d7198d
  warn "~/.termux-adb nao existe (sera criado no primeiro uso do adb)"
=======
  warn "~/.termux-adb não existe (será criado no primeiro uso do adb)"
>>>>>>> main
fi
echo

<<<<<<< HEAD
# 5. Extra tools and symlinks
echo "Extras:"
for TOOL in wireless-adb termux-adb-update; do
||||||| 9d7198d
# 5. Ferramentas extras e symlinks
echo "Extras:"
for TOOL in wireless-adb termux-adb-update; do
=======
# 5. Front-ends unificados
echo "Front-ends (adb unificado):"
if [ -x "$HOME/.local/bin/adb" ]; then
  ok "front-end adb ok"
else
  warn "front-end adb ausente (rode install.sh)"
fi

if [ -x "$HOME/.local/bin/fastboot" ]; then
  ok "front-end fastboot ok"
else
  warn "front-end fastboot ausente (rode install.sh)"
fi

if [ -e "$HOME/.local/bin/adb-otg-watcher" ]; then
  ok "front-end adb-otg-watcher ok"
else
  warn "adb-otg-watcher ausente (rode install.sh)"
fi
echo

# 6. Ferramentas extras
echo "Ferramentas extras:"
for TOOL in wireless-adb termux-adb-update adbs adbmenu adbpair adbotg adbw adblocalhost; do
>>>>>>> main
  if command -v "$TOOL" >/dev/null 2>&1; then
    ok "$TOOL installed"
  else
<<<<<<< HEAD
    warn "$TOOL not installed (run install.sh to add it)"
||||||| 9d7198d
    warn "$TOOL nao instalado (rode install.sh para adicionar)"
=======
    warn "$TOOL não instalado (rode install.sh para adicionar)"
>>>>>>> main
  fi
done
<<<<<<< HEAD

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
||||||| 9d7198d

echo
echo "Symlinks:"
if [ -L "$PREFIX/bin/adb" ] && [ "$(readlink "$PREFIX/bin/adb")" = "$PREFIX/bin/termux-adb" ]; then
  ok "adb -> termux-adb"
else
  warn "symlink adb nao encontrado (rode install.sh para criar)"
fi

if [ -L "$PREFIX/bin/fastboot" ] && [ "$(readlink "$PREFIX/bin/fastboot")" = "$PREFIX/bin/termux-fastboot" ]; then
  ok "fastboot -> termux-fastboot"
else
  warn "symlink fastboot nao encontrado (rode install.sh para criar)"
fi
=======
>>>>>>> main
echo

# Result
echo "========================"
if [ "$ISSUES" -eq 0 ]; then
<<<<<<< HEAD
  echo -e "${GREEN}All OK — no problems found.${NC}"
||||||| 9d7198d
  echo -e "${GREEN}Tudo OK — nenhum problema encontrado.${NC}"
=======
  echo -e "${GREEN}Tudo OK — nenhum problema encontrado; o ambiente está pronto para uso.${NC}"
>>>>>>> main
else
<<<<<<< HEAD
  echo -e "${RED}$ISSUES problem(s) found.${NC}"
||||||| 9d7198d
  echo -e "${RED}$ISSUES problema(s) encontrado(s).${NC}"
=======
  echo -e "${RED}$ISSUES problema(s) encontrado(s) — rode install.sh para corrigir.${NC}"
>>>>>>> main
fi
echo