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
<<<<<<< HEAD
RELEASE_URL="https://github.com/GeneralKaos666/termux-adb/releases/download/v${VERSION}"
RAW_URL="https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main"
||||||| 9d7198d
RELEASE_URL="https://github.com/rianprei/termux-adb/releases/download/v${VERSION}"
RAW_URL="https://raw.githubusercontent.com/rianprei/termux-adb/main"
=======
RELEASE_URL="https://github.com/rianprei/termux-adb/releases/download/v${VERSION}"
RAW_URL="https://raw.githubusercontent.com/rianprei/termux-adb/main"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
>>>>>>> main

declare -A DEB_SHA256
DEB_SHA256[aarch64]="3f571ada3ea25671ab8a6d227c5f12f7e0412d8b62bf60e7948ae99a4c38c518"
DEB_SHA256[arm]="faf1ec047fa69dbafc9550574bdf4c91bc7c12c5372684d6c5d9cbe384e861a0"

# Scripts instalados no PATH (prefixo .sh removido)
EXTRA_SCRIPTS="wireless-adb termux-adb-doctor termux-adb-update adbotg adbpair adbw adblocalhost adbs adbmenu"
# Scripts instalados em $HOME/.local/bin (front-ends do adb unificado)
LOCALBIN_SCRIPTS="adb fastboot adb-otg-watcher"

echo
info "Termux ADB Unificado — instalador v${VERSION}"
echo

<<<<<<< HEAD
# 1. Arch check
step "Checking architecture..."
||||||| 9d7198d
# 1. Arch check
step "Verificando arquitetura..."
=======
# 1. Verificação de arquitetura
step "Verificando arquitetura..."
>>>>>>> main
ARCH="$(uname -m)"
case "$ARCH" in
  aarch64) DEB_ARCH="aarch64" ;;
  armv7l|armv8l|arm) DEB_ARCH="arm" ;;
  *)
<<<<<<< HEAD
    fail "Architecture '$ARCH' not supported. Supported: aarch64, arm (armv7l/armv8l)"
||||||| 9d7198d
    fail "Arquitetura '$ARCH' nao suportada. Suportadas: aarch64, arm (armv7l/armv8l)"
=======
    fail "Arquitetura '$ARCH' não suportada. Suportadas: aarch64, arm (armv7l/armv8l)"
>>>>>>> main
    ;;
esac
info "Architecture: $ARCH → package $DEB_ARCH"

<<<<<<< HEAD
# 2. Base dependencies
step "Installing base dependencies..."
||||||| 9d7198d
# 2. Dependencias base
step "Instalando dependencias base..."
=======
# 2. Dependências base
step "Instalando dependências base..."
>>>>>>> main
apt-get update -qq
apt-get --assume-yes install wget > /dev/null

# 3. termux-api
step "Checking termux-api..."
if ! command -v termux-usb >/dev/null 2>&1; then
<<<<<<< HEAD
  warn "termux-usb not found. Installing termux-api..."
||||||| 9d7198d
  warn "termux-usb nao encontrado. Instalando termux-api..."
=======
  warn "termux-usb não encontrado. Instalando termux-api..."
>>>>>>> main
  apt-get --assume-yes install termux-api > /dev/null
<<<<<<< HEAD
  info "termux-api installed. Also install the Termux:API app (F-Droid) if you haven't already."
||||||| 9d7198d
  info "termux-api instalado. Instale tambem o app Termux:API (F-Droid) se ainda nao instalou."
=======
  info "termux-api instalado. Instale também o app Termux:API (F-Droid) se ainda não instalou."
>>>>>>> main
else
  info "termux-api present"
fi

<<<<<<< HEAD
# 4. Download and install the .deb directly from our repo (no external repo dependency)
||||||| 9d7198d
# 4. Baixar e instalar o .deb direto do nosso repo (sem depender de repo externo)
=======
# 4. Baixar e instalar o pacote .deb (distribuição própria, sem repo externo)
>>>>>>> main
DEB_FILE="termux-adb_${PKG_VERSION}_${DEB_ARCH}.deb"
DEB_TMP="$(mktemp)"
EXPECTED_SHA="${DEB_SHA256[$DEB_ARCH]}"

step "Downloading $DEB_FILE..."
if ! wget -qO "$DEB_TMP" --timeout=30 "${RELEASE_URL}/${DEB_FILE}" 2>/dev/null; then
  rm -f "$DEB_TMP"
<<<<<<< HEAD
  fail "Failed to download $DEB_FILE. Check your connection or open an issue at github.com/GeneralKaos666/termux-adb"
||||||| 9d7198d
  fail "Falha ao baixar $DEB_FILE. Verifique conexao ou abra issue em github.com/rianprei/termux-adb"
=======
  fail "Falha ao baixar $DEB_FILE. Verifique a conexão ou abra uma issue em github.com/rianprei/termux-adb"
>>>>>>> main
fi

step "Verifying integrity (SHA256)..."
ACTUAL_SHA="$(sha256sum "$DEB_TMP" | cut -d' ' -f1)"
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  rm -f "$DEB_TMP"
<<<<<<< HEAD
  fail "SHA256 mismatch! Expected: $EXPECTED_SHA / Got: $ACTUAL_SHA. Possible corruption. Open an issue at github.com/GeneralKaos666/termux-adb"
||||||| 9d7198d
  fail "SHA256 nao confere! Esperado: $EXPECTED_SHA / Recebido: $ACTUAL_SHA. Possivel corrupcao. Abra issue em github.com/rianprei/termux-adb"
=======
  fail "SHA256 não confere! Esperado: $EXPECTED_SHA / Recebido: $ACTUAL_SHA. Possível corrupção. Abra uma issue em github.com/rianprei/termux-adb"
>>>>>>> main
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

<<<<<<< HEAD
# 6. Extra tools
step "Installing extra tools..."
wget -qO "$PREFIX/bin/wireless-adb" --timeout=10 "${RAW_URL}/wireless-adb.sh" 2>/dev/null && chmod +x "$PREFIX/bin/wireless-adb" && info "wireless-adb installed" || warn "Failed to download wireless-adb (non-critical)"
wget -qO "$PREFIX/bin/termux-adb-doctor" --timeout=10 "${RAW_URL}/termux-adb-doctor.sh" 2>/dev/null && chmod +x "$PREFIX/bin/termux-adb-doctor" && info "termux-adb-doctor installed" || warn "Failed to download termux-adb-doctor (non-critical)"
wget -qO "$PREFIX/bin/termux-adb-update" --timeout=10 "${RAW_URL}/termux-adb-update.sh" 2>/dev/null && chmod +x "$PREFIX/bin/termux-adb-update" && info "termux-adb-update installed" || warn "Failed to download termux-adb-update (non-critical)"
||||||| 9d7198d
# 6. Ferramentas extras
step "Instalando ferramentas extras..."
wget -qO "$PREFIX/bin/wireless-adb" --timeout=10 "${RAW_URL}/wireless-adb.sh" 2>/dev/null && chmod +x "$PREFIX/bin/wireless-adb" && info "wireless-adb instalado" || warn "Falha ao baixar wireless-adb (nao-critico)"
wget -qO "$PREFIX/bin/termux-adb-doctor" --timeout=10 "${RAW_URL}/termux-adb-doctor.sh" 2>/dev/null && chmod +x "$PREFIX/bin/termux-adb-doctor" && info "termux-adb-doctor instalado" || warn "Falha ao baixar termux-adb-doctor (nao-critico)"
wget -qO "$PREFIX/bin/termux-adb-update" --timeout=10 "${RAW_URL}/termux-adb-update.sh" 2>/dev/null && chmod +x "$PREFIX/bin/termux-adb-update" && info "termux-adb-update instalado" || warn "Falha ao baixar termux-adb-update (nao-critico)"
=======
# 6. Ferramentas extras no PATH ($PREFIX/bin)
step "Instalando ferramentas extras..."
for SCRIPT in $EXTRA_SCRIPTS; do
  if wget -qO "$PREFIX/bin/$SCRIPT" --timeout=10 "${RAW_URL}/${SCRIPT}.sh" 2>/dev/null; then
    chmod +x "$PREFIX/bin/$SCRIPT"
    info "$SCRIPT instalado"
  else
    warn "Falha ao baixar $SCRIPT (não crítico)"
  fi
done
>>>>>>> main

<<<<<<< HEAD
# 7. Symlinks adb -> termux-adb, fastboot -> termux-fastboot
step "Creating symlinks..."
ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb"
ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot"
info "adb -> termux-adb, fastboot -> termux-fastboot"
||||||| 9d7198d
# 7. Symlinks adb -> termux-adb, fastboot -> termux-fastboot
step "Criando symlinks..."
ln -sf "$PREFIX/bin/termux-adb" "$PREFIX/bin/adb"
ln -sf "$PREFIX/bin/termux-fastboot" "$PREFIX/bin/fastboot"
info "adb -> termux-adb, fastboot -> termux-fastboot"
=======
# 7. Front-ends do adb unificado em $HOME/.local/bin
#    (ficam antes de $PREFIX/bin no PATH e roteiam OTG/wireless)
step "Instalando front-ends unificados..."
mkdir -p "$HOME/.local/bin"
for SCRIPT in $LOCALBIN_SCRIPTS; do
  if wget -qO "$HOME/.local/bin/$SCRIPT" --timeout=10 "${RAW_URL}/${SCRIPT}.sh" 2>/dev/null; then
    chmod +x "$HOME/.local/bin/$SCRIPT"
    info "$SCRIPT instalado"
  else
    warn "Falha ao baixar $SCRIPT (não crítico)"
  fi
done

# Garante $HOME/.local/bin no PATH
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
>>>>>>> main

# 8. Health-check
<<<<<<< HEAD
step "Verifying installation..."
||||||| 9d7198d
step "Verificando instalacao..."
=======
step "Verificando instalação..."
>>>>>>> main
echo
if ADB_VER="$(termux-adb version 2>/dev/null | head -1)"; then
  info "termux-adb OK: $ADB_VER"
else
<<<<<<< HEAD
  warn "termux-adb installed but 'termux-adb version' failed. Run 'termux-adb-doctor' to diagnose."
||||||| 9d7198d
  warn "termux-adb instalado mas 'termux-adb version' falhou. Rode 'termux-adb-doctor' para diagnosticar."
=======
  warn "termux-adb instalado, mas 'termux-adb version' falhou. Execute 'termux-adb-doctor' para diagnosticar."
>>>>>>> main
fi

if FB_VER="$(termux-fastboot --version 2>/dev/null | head -1)"; then
  info "termux-fastboot OK: $FB_VER"
else
<<<<<<< HEAD
  warn "termux-fastboot did not respond (may not be available in this version)"
||||||| 9d7198d
  warn "termux-fastboot nao respondeu (pode nao estar disponivel nesta versao)"
=======
  warn "termux-fastboot não respondeu (pode não estar disponível nesta versão)"
>>>>>>> main
fi

echo
<<<<<<< HEAD
info "Installation complete!"
info "Commands: adb, fastboot, wireless-adb, termux-adb-doctor, termux-adb-update"
info "No external dependencies — binaries hosted in our repo."
echo
||||||| 9d7198d
info "Instalacao completa!"
info "Comandos: adb, fastboot, wireless-adb, termux-adb-doctor, termux-adb-update"
info "Nenhuma dependencia externa — binarios hospedados no nosso repo."
echo
=======
info "Instalação concluída!"
info "Comandos: adb, fastboot, adbw, adbmenu, adbs, adbpair, adbotg, adblocalhost, wireless-adb, termux-adb-doctor, termux-adb-update"
info "Distribuição própria — binários hospedados no nosso repositório."
echo
>>>>>>> main
