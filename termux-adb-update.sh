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

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
REPO="rianprei/termux-adb"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main"

# Scripts extras instalados em $PREFIX/bin
EXTRA_SCRIPTS="wireless-adb.sh termux-adb-doctor.sh termux-adb-update.sh adbotg.sh adbpair.sh adbw.sh adblocalhost.sh adbs.sh adbmenu.sh"
# Front-ends unificados instalados em $HOME/.local/bin
LOCALBIN_SCRIPTS="adb.sh fastboot.sh adb-otg-watcher.sh"

echo
<<<<<<< HEAD
info "termux-adb-update — checking for updates"
||||||| 9d7198d
info "termux-adb-update — verificando atualizacoes"
=======
info "termux-adb-update v4.0.0 — verificando atualizações"
>>>>>>> main
echo

<<<<<<< HEAD
step "Fetching latest release..."
LATEST="$(wget -qO- --timeout=10 "$API_URL" 2>/dev/null)" || fail "Failed to query GitHub API. Check your connection."
||||||| 9d7198d
step "Consultando ultima release..."
LATEST="$(wget -qO- --timeout=10 "$API_URL" 2>/dev/null)" || fail "Falha ao consultar GitHub API. Verifique conexao."
=======
step "Consultando a última release..."
LATEST="$(wget -qO- --timeout=10 "$API_URL" 2>/dev/null)" || fail "Falha ao consultar GitHub API. Verifique a conexão."
>>>>>>> main

LATEST_TAG="$(echo "$LATEST" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"//;s/".*//')"
<<<<<<< HEAD
[ -z "$LATEST_TAG" ] && fail "Could not get the latest release tag"
||||||| 9d7198d
[ -z "$LATEST_TAG" ] && fail "Nao foi possivel obter tag da ultima release"
=======
[ -z "$LATEST_TAG" ] && fail "Não foi possível obter a tag da última release"
>>>>>>> main

INSTALLED_VER=""
if command -v termux-adb >/dev/null 2>&1; then
  INSTALLED_VER="$(timeout 3 termux-adb version 2>/dev/null | head -1 || echo '?')"
fi

<<<<<<< HEAD
info "Latest release: $LATEST_TAG"
info "Installed version: ${INSTALLED_VER:-not found}"
||||||| 9d7198d
info "Release mais recente: $LATEST_TAG"
info "Versao instalada: ${INSTALLED_VER:-nao encontrada}"
=======
info "Release mais recente: $LATEST_TAG"
info "Versão instalada: ${INSTALLED_VER:-não encontrada}"
>>>>>>> main
echo

<<<<<<< HEAD
step "Updating scripts..."
for SCRIPT in wireless-adb.sh termux-adb-doctor.sh termux-adb-update.sh; do
||||||| 9d7198d
step "Atualizando scripts..."
for SCRIPT in wireless-adb.sh termux-adb-doctor.sh termux-adb-update.sh; do
=======
step "Atualizando scripts no PATH (\$PREFIX/bin)..."
for SCRIPT in $EXTRA_SCRIPTS; do
>>>>>>> main
  TARGET="${SCRIPT%.sh}"
  wget -qO "$PREFIX/bin/$TARGET" --timeout=10 "${RAW_URL}/${SCRIPT}" 2>/dev/null && chmod +x "$PREFIX/bin/$TARGET" && info "$TARGET updated" || warn "Failed to update $TARGET"
done

<<<<<<< HEAD
step "Updating install.sh to the new version..."
||||||| 9d7198d
step "Atualizando install.sh para nova versao..."
=======
step "Atualizando front-ends unificados (\$HOME/.local/bin)..."
mkdir -p "$HOME/.local/bin"
for SCRIPT in $LOCALBIN_SCRIPTS; do
  TARGET="${SCRIPT%.sh}"
  wget -qO "$HOME/.local/bin/$TARGET" --timeout=10 "${RAW_URL}/${SCRIPT}" 2>/dev/null && chmod +x "$HOME/.local/bin/$TARGET" && info "$TARGET atualizado" || warn "Falha ao atualizar $TARGET"
done

step "Atualizando install.sh para a nova versão..."
>>>>>>> main
INSTALL_TMP="$(mktemp)"
if wget -qO "$INSTALL_TMP" --timeout=10 "${RAW_URL}/install.sh" 2>/dev/null; then
  NEW_PKG_VER="$(grep '^PKG_VERSION=' "$INSTALL_TMP" | cut -d'"' -f2)"
  CUR_PKG_VER="$(dpkg -s termux-adb 2>/dev/null | grep '^Version:' | cut -d' ' -f2)"

  if [ -n "$NEW_PKG_VER" ] && [ -n "$CUR_PKG_VER" ] && [ "$NEW_PKG_VER" != "$CUR_PKG_VER" ]; then
<<<<<<< HEAD
    info "New package version available: $CUR_PKG_VER -> $NEW_PKG_VER"
    step "Reinstalling with the new install.sh..."
||||||| 9d7198d
    info "Nova versao do pacote disponivel: $CUR_PKG_VER -> $NEW_PKG_VER"
    step "Reinstalando com novo install.sh..."
=======
    info "Nova versão do pacote disponível: $CUR_PKG_VER -> $NEW_PKG_VER"
    step "Reinstalando com o novo install.sh..."
>>>>>>> main
    bash "$INSTALL_TMP"
  else
<<<<<<< HEAD
    info "termux-adb package is already at the latest version ($CUR_PKG_VER)"
||||||| 9d7198d
    info "Pacote termux-adb ja esta na versao mais recente ($CUR_PKG_VER)"
=======
    info "Pacote termux-adb já está na versão mais recente (${CUR_PKG_VER:-desconhecida})"
>>>>>>> main
  fi
  rm -f "$INSTALL_TMP"
else
  rm -f "$INSTALL_TMP"
<<<<<<< HEAD
  warn "Failed to download install.sh (scripts were already updated)"
||||||| 9d7198d
  warn "Falha ao baixar install.sh (scripts ja foram atualizados)"
=======
  warn "Falha ao baixar install.sh (scripts já foram atualizados)"
>>>>>>> main
fi

<<<<<<< HEAD
# Recreate symlinks
ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb" 2>/dev/null
ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot" 2>/dev/null

echo
info "Update complete!"
||||||| 9d7198d
# Recriar symlinks
ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb" 2>/dev/null
ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot" 2>/dev/null

echo
info "Atualizacao concluida!"
echo
=======
echo
info "Atualização concluída!"
>>>>>>> main
echo