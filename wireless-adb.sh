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

<<<<<<< HEAD
command -v termux-adb >/dev/null 2>&1 || fail "termux-adb not installed. Run install.sh first."
||||||| 9d7198d
command -v termux-adb >/dev/null 2>&1 || fail "termux-adb nao instalado. Rode install.sh primeiro."
=======
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

command -v termux-adb >/dev/null 2>&1 || fail "termux-adb não instalado. Execute install.sh primeiro."
>>>>>>> main

validate_addr() {
<<<<<<< HEAD
  echo "$1" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$' || fail "Invalid format: '$1'. Use IP:PORT (e.g. 192.168.1.100:37123)"
||||||| 9d7198d
  echo "$1" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$' || fail "Formato invalido: '$1'. Use IP:PORTA (ex: 192.168.1.100:37123)"
=======
  echo "$1" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}$' || fail "Formato inválido: '$1'. Use IP:PORTA (ex: 192.168.1.100:37123)"
>>>>>>> main
}

echo
<<<<<<< HEAD
info "Wireless ADB (Android 11+, no cable/OTG, no root)"
||||||| 9d7198d
info "Wireless ADB (Android 11+, sem cabo/OTG, sem root)"
=======
info "ADB Wireless (Android 11+, sem cabo/OTG, sem root)"
>>>>>>> main
echo

LOCAL_IP="$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[0-9.]+' || true)"
if [ -n "$LOCAL_IP" ]; then
  info "Your local IP: $LOCAL_IP"
fi

<<<<<<< HEAD
echo -e "${BLUE}On the target phone:${NC} Settings > Developer options > Wireless debugging"
||||||| 9d7198d
echo -e "${BLUE}No celular alvo:${NC} Ajustes > Opcoes do desenvolvedor > Depuracao wireless"
=======
echo -e "${BLUE}No aparelho alvo:${NC} Ajustes > Opções do desenvolvedor > Depuração wireless"
>>>>>>> main
echo

<<<<<<< HEAD
read -rp "Have you paired this device before? [y/N] " PAIRED
||||||| 9d7198d
read -rp "Ja pareou este dispositivo antes? [s/N] " PAIRED
=======
read -rp "Já pareou este aparelho antes? [s/N] " PAIRED
>>>>>>> main

if [ "$PAIRED" != "y" ] && [ "$PAIRED" != "Y" ]; then
  echo
<<<<<<< HEAD
  step "Pairing required"
  read -rp "Pairing IP:port (screen 'Pair with code'): " PAIR_ADDR
||||||| 9d7198d
  step "Pareamento necessario"
  read -rp "IP:porta de pareamento (tela 'Parear com codigo'): " PAIR_ADDR
=======
  step "Pareamento necessário"
  read -rp "IP:porta de pareamento (tela 'Parear com código'): " PAIR_ADDR
>>>>>>> main
  validate_addr "$PAIR_ADDR"
<<<<<<< HEAD
  read -rp "Pairing code (6 digits): " PAIR_CODE
  [ -z "$PAIR_CODE" ] && fail "Code cannot be empty"
  info "Pairing..."
  timeout 15 termux-adb pair "$PAIR_ADDR" "$PAIR_CODE" || fail "Pairing failed (15s timeout or wrong credentials)"
  info "Paired successfully"
||||||| 9d7198d
  read -rp "Codigo de pareamento (6 digitos): " PAIR_CODE
  [ -z "$PAIR_CODE" ] && fail "Codigo nao pode ser vazio"
  info "Pareando..."
  timeout 15 termux-adb pair "$PAIR_ADDR" "$PAIR_CODE" || fail "Pareamento falhou (timeout 15s ou credenciais incorretas)"
  info "Pareado com sucesso"
=======
  read -rp "Código de pareamento (6 dígitos): " PAIR_CODE
  [ -z "$PAIR_CODE" ] && fail "O código não pode ser vazio"
  info "Pareando..."
  timeout 15 termux-adb pair "$PAIR_ADDR" "$PAIR_CODE" || fail "Pareamento falhou (timeout de 15s ou credenciais incorretas)"
  info "Pareamento concluído"
>>>>>>> main
fi

echo
<<<<<<< HEAD
read -rp "Connection IP:port (main wireless debugging screen): " CONNECT_ADDR
||||||| 9d7198d
read -rp "IP:porta de conexao (tela principal de depuracao wireless): " CONNECT_ADDR
=======
read -rp "IP:porta de conexão (porta de conexão, na tela principal de depuração wireless): " CONNECT_ADDR
>>>>>>> main
validate_addr "$CONNECT_ADDR"

<<<<<<< HEAD
step "Connecting..."
timeout 15 termux-adb connect "$CONNECT_ADDR" || fail "Connection failed (15s timeout). Check the IP/port and that wireless debugging is on."
||||||| 9d7198d
step "Conectando..."
timeout 15 termux-adb connect "$CONNECT_ADDR" || fail "Conexao falhou (timeout 15s). Verifique IP/porta e se depuracao wireless esta ativa."
=======
step "Conectando..."
timeout 15 termux-adb connect "$CONNECT_ADDR" || fail "Conexão falhou (timeout de 15s). Verifique IP/porta e se a depuração wireless está ativa."
>>>>>>> main

echo
<<<<<<< HEAD
info "Connected! Devices:"
||||||| 9d7198d
info "Conectado! Dispositivos:"
=======
info "Conectado. Dispositivos:"
>>>>>>> main
termux-adb devices
echo