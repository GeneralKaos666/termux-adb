# Termux ADB Unificado

<<<<<<< HEAD
ADB and Fastboot on Termux **without root**. 100% self-contained, isolated config, SHA256 verification, wireless mode, built-in diagnostics, auto-updater, clean uninstall.
||||||| 9d7198d
ADB e Fastboot no Termux **sem root**. 100% self-contained, config isolada, verificação SHA256, wireless mode, diagnóstico integrado, auto-updater, uninstall limpo.
=======
ADB e Fastboot no Termux **sem root** e **sem abrir o bootloader**.

[![versão-4.0.0](https://img.shields.io/badge/vers%C3%A3o-4.0.0-blue)](https://github.com/rianprei/termux-adb/releases/tag/v4.0.0)
[![licença-MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-green)](LICENSE)

Este projeto integra as principais implementações do ecossistema ADB do Termux — USB OTG via `termux-usb`, wireless (Android 11+), localhost e espelhamento via scrcpy — em uma **interface de comando única** com roteamento automático de backend.

## Recursos principais

- **USB OTG sem root (dispositivo→dispositivo)** — binário `termux-adb` patchado, acesso via `termux-usb`.
- **Wireless (Android 11+, pareamento por código)** — front-end `adb` + assistente interativo `adbw`.
- **Localhost (depuração do próprio aparelho)** — `adblocalhost` (conexão em `127.0.0.1`).
- **Front-end unificado `adb`** — decide automaticamente entre `termux-adb` (OTG) e o `adb` nativo (wireless), com decisão baseada em cache do watcher (latência de ~1 ms).
- **Fastboot sem root** — front-end `fastboot` encaminha para `termux-fastboot`.
- **Diagnóstico integrado** — `adbs` (status rápido) e `termux-adb-doctor` (verificação completa).
- **Menu interativo** — `adbmenu`, consolidando todas as operações.
- **Espelhamento de tela com scrcpy** — opcional, integrado ao menu e ao diagnóstico.
- **Config isolada** — dados do ADB em `~/.termux-adb`, fora do `$HOME`.
- **Distribuição própria** — binários `.deb` hospedados no GitHub Releases, com verificação de integridade SHA256.

## Requisitos

- **Termux** e **Termux:API** — ambos do [F-Droid](https://f-droid.org/). **Não** utilizar as versões da Play Store (são desatualizadas e incompatíveis).
- **Dispositivo Android com suporte a USB host** — para a modalidade OTG. Alternativamente, **Android 11+** para usar via wireless sem cabo.
- **~100 MB de armazenamento livre** para o conjunto de binários e dependências.
>>>>>>> main

## Installation

<<<<<<< HEAD
Install [Termux](https://f-droid.org/packages/com.termux/) and [Termux:API](https://f-droid.org/packages/com.termux.api/) from F-Droid, then:
||||||| 9d7198d
Instale [Termux](https://f-droid.org/packages/com.termux/) e [Termux:API](https://f-droid.org/packages/com.termux.api/) pelo F-Droid, depois:
=======
Instale Termux e Termux:API pelo F-Droid e execute:
>>>>>>> main

```
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/install.sh | bash
```

<<<<<<< HEAD
The installer:
- Blocks unsupported architectures
- Installs `termux-api` automatically if missing
- Verifies the .deb integrity (SHA256) before installing
- Installs `termux-adb` and `termux-fastboot` via dpkg directly from our repo
- Creates `adb` → `termux-adb` and `fastboot` → `termux-fastboot` symlinks (just type `adb`)
- Isolates adb data in `~/.termux-adb` (doesn't clutter your `$HOME`)
- Installs `wireless-adb`, `termux-adb-doctor` and `termux-adb-update` on PATH
- Runs a health-check at the end and confirms everything works
- Stops on the first error (`set -e`)
||||||| 9d7198d
O installer:
- Bloqueia arquiteturas não suportadas
- Instala `termux-api` automaticamente se faltar
- Verifica integridade do .deb (SHA256) antes de instalar
- Instala `termux-adb` e `termux-fastboot` via dpkg direto do nosso repo
- Cria symlinks `adb` → `termux-adb` e `fastboot` → `termux-fastboot` (digita só `adb`)
- Isola dados do adb em `~/.termux-adb` (não suja seu `$HOME`)
- Instala `wireless-adb`, `termux-adb-doctor` e `termux-adb-update` no PATH
- Roda health-check no final e confirma que tudo funciona
- Para no primeiro erro (`set -e`)
=======
O instalador executa as seguintes etapas, nesta ordem:
>>>>>>> main

<<<<<<< HEAD
**100% self-contained** — binaries hosted in our repo (GitHub Releases), no dependency on any external server.
||||||| 9d7198d
**100% self-contained** — binários hospedados no nosso repo (GitHub Releases), não depende de nenhum servidor externo.
=======
1. **Verificação de arquitetura** — bloqueia arquiteturas não suportadas (suportadas: `aarch64`, `arm`/`armv7l`/`armv8l`).
2. **Dependências base** — instala `wget`.
3. **termux-api** — instala automaticamente se `termux-usb` não estiver presente.
4. **Download e instalação do pacote `.deb`** (GitHub Releases) com **verificação SHA256** antes da instalação via `dpkg`; o processo para no primeiro erro (`set -e`).
5. **Isolamento de dados** — define `ANDROID_USER_HOME` e `ANDROID_SDK_HOME` apontando para `~/.termux-adb` nos shell RCs (`.bashrc`/`.zshrc`).
6. **Ferramentas extras** — instaladas no PATH (`$PREFIX/bin`).
7. **Front-ends unificados** — `adb`, `fastboot` e `adb-otg-watcher` em `~/.local/bin`, com garantia de precedência no PATH.
8. **Health-check** — executa `termux-adb version` e `termux-fastboot --version` para confirmar a instalação.

O projeto é 100% self-contained: os binários são hospedados no próprio repositório, sem dependência de servidores externos.
>>>>>>> main

## Usage

<<<<<<< HEAD
### USB (OTG cable)
||||||| 9d7198d
### USB (cabo OTG)
=======
### USB OTG (cabo)
>>>>>>> main

```
adb devices
```

<<<<<<< HEAD
The first time, Android asks for USB permission — accept it.
||||||| 9d7198d
Na primeira vez o Android pede permissão USB — aceite.
=======
Na primeira vez, o dispositivo Android solicita permissão USB — aceite. Para listar e conceder permissão aos dispositivos OTG conectados, use `adbotg`.
>>>>>>> main

### Wireless (Android 11+, no cable)

```
adbw
```

<<<<<<< HEAD
Interactive guide: detects your IP, validates addresses, 15s timeout on each step.
||||||| 9d7198d
Guia interativo: detecta seu IP, valida endereços, timeout de 15s em cada passo.
=======
O `adbw` é um guia interativo: detecta o IP local, valida os endereços `IP:PORTA`, executa o pareamento por código e a conexão, com timeout de 15 s por etapa. Alternativamente, faça manualmente:

```
adb pair IP:PORTA_PAREAMENTO CODIGO
adb connect IP:PORTA
```

### Pareamento rápido

```
adbpair IP:PORTA_PAREAMENTO CODIGO [IP:PORTA_CONEXAO]
```

Se a porta de conexão não for informada, apenas o pareamento é executado.

### Localhost (próprio aparelho)

```
adblocalhost
```

Conecta em `127.0.0.1` via depuração wireless, permitindo depurar o próprio dispositivo.
>>>>>>> main

### Diagnostics

```
adbs
termux-adb-doctor
```

<<<<<<< HEAD
Checks everything: binaries, termux-api, the Termux:API app, isolated config, extra tools. Green/red output per item.
||||||| 9d7198d
Verifica tudo: binários, termux-api, app Termux:API, config isolada, ferramentas extras. Output verde/vermelho por item.
=======
`adbs` consolida o status geral do ambiente: backends, modos de acesso e aplicação de configuração. `termux-adb-doctor` realiza a verificação completa (binários, termux-api, pacote dpkg, configuração isolada, front-ends e ferramentas extras) com saída verde/vermelha por item.
>>>>>>> main

<<<<<<< HEAD
### Update
||||||| 9d7198d
### Atualizar
=======
### Menu interativo

```
adbmenu
```

Reúne as operações mais comuns: conexão wireless e localhost, listagem OTG, `adb shell`, espelhamento via scrcpy, shell Bash na sessão ADB (`ADBash.sh`), instalação de APK, `pull`/`push`, diagnóstico e pareamento.

### Status do ambiente

```
adbs
```

Exibe versões de backend, estado do `termux-usb`, variáveis de ambiente e a lista de dispositivos (`adb devices`).

## Ferramentas instaladas

| Comando               | Destino           | Função |
|-----------------------|-------------------|--------|
| `termux-adb`          | `$PREFIX/bin`     | Binário ADB patchado (OTG via `termux-usb`), instalado via `dpkg`. |
| `termux-fastboot`     | `$PREFIX/bin`     | Binário Fastboot patchado, instalado via `dpkg`. |
| `adb`                 | `~/.local/bin`    | Front-end unificado com roteamento automático de backend. |
| `fastboot`            | `~/.local/bin`    | Front-end que encaminha para `termux-fastboot`. |
| `adb-otg-watcher`     | `~/.local/bin`    | Watcher de background que mantém o cache OTG atualizado. |
| `wireless-adb`        | `$PREFIX/bin`     | Assistente interativo de conexão wireless (usa `termux-adb`). |
| `adbotg`              | `$PREFIX/bin`     | Lista dispositivos USB OTG via `termux-usb -l`. |
| `adbpair`             | `$PREFIX/bin`     | Pareamento rápido por código. |
| `adbw`                | `$PREFIX/bin`     | Conexão wireless interativa. |
| `adblocalhost`        | `$PREFIX/bin`     | Depuração do próprio aparelho (`127.0.0.1`). |
| `adbs`                | `$PREFIX/bin`     | Status geral do sistema ADB (diagnóstico rápido). |
| `adbmenu`             | `$PREFIX/bin`     | Menu interativo das ferramentas ADB. |
| `termux-adb-doctor`   | `$PREFIX/bin`     | Diagnóstico completo do ambiente. |
| `termux-adb-update`   | `$PREFIX/bin`     | Auto-updater de scripts e pacote. |

## Como funciona

O `termux-adb` utiliza a API `termux-usb` do Termux:API para obter file descriptors de dispositivos USB sem exigir root. Os binários são patchados em `lib` para remapear `/dev/bus/usb` para um diretório virtual, e um **Unix Domain Socket (UDS)** transfere os descriptors entre processos — o que permite múltiplos dispositivos conectados, inclusive via hub USB no OTG.

O front-end `adb` une as duas famílias de acesso:

- **OTG** → `termux-adb` (patch nohajc via `termux-usb`);
- **Wireless/localhost** → `adb` nativo (android-tools, mais rápido).

O `adb-otg-watcher` consulta `termux-usb -l` em background (instância única garantida por `flock`, atualização a cada 4 s) e grava o resultado em `~/.termux-adb/otg.cache`. O front-end decide a rota com apenas um `stat` + um `cat` (~1 ms), sem bloquear. O comando `pair`/`connect`/`disconnect` e demais operações de rede são direcionados sempre ao backend nativo. O pacote `dpkg` fornece os binários `termux-adb` e `termux-fastboot`; o roteamento para os front-ends `adb`/`fastboot` em `~/.local/bin` garante a interface unificada.

## Comparação

| Feature | nohajc | MasterDevX | rendiix | **Este (v4.0.0)** |
|---------|:------:|:----------:|:-------:|:------------------:|
| Sem root | ✅ | ❌ | ❌ | ✅ |
| OTG via termux-usb | ✅ | ❌ | ❌ | ✅ |
| Wireless ADB | ❌ | ❌ | ❌ | ✅ |
| Localhost ADB | ❌ | ❌ | ❌ | ✅ |
| Diagnóstico | ❌ | ❌ | ❌ | ✅ |
| Uninstall limpo | ❌ | ✅ | ❌ | ✅ |
| Config isolada | ❌ | ✅ | ❌ | ✅ |
| Auto-updater | ❌ | ❌ | ❌ | ✅ |
| Verificação SHA256 | ❌ | ❌ | ❌ | ✅ |
| Arquitetura check | ❌ | ❌ | ❌ | ✅ |
| Front-end com roteamento automático | ❌ | ❌ | ❌ | ✅ |
| Watcher / baixa latência | ❌ | ❌ | ❌ | ✅ |
| scrcpy integrado | ❌ | ❌ | ❌ | ✅ |
| Menu interativo | ❌ | ❌ | ❌ | ✅ |
| Distribuição própria | ❌ | ❌ | ❌ | ✅ |

## Atualização
>>>>>>> main

```
termux-adb-update
```

<<<<<<< HEAD
Checks for a new version and updates scripts and package automatically.
||||||| 9d7198d
Verifica se há nova versão, atualiza scripts e pacote automaticamente.
=======
Consulta a release mais recente no GitHub, atualiza os scripts instalados e, se houver nova versão do pacote no `install.sh`, reinstala-o automaticamente. Os front-ends `adb`/`fastboot` e o watcher são atualizados ao final.
>>>>>>> main

<<<<<<< HEAD
## Uninstall
||||||| 9d7198d
## Desinstalar
=======
## Desinstalação
>>>>>>> main

```
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/uninstall.sh | bash
```

<<<<<<< HEAD
Removes everything: package, symlinks, extra tools, isolated config, shell RC environment variables.

## How it works

`termux-adb` uses the `termux-usb` API from Termux:API to obtain file descriptors of USB devices without needing root. The adb/fastboot binaries are patched to scan devices via `termux-usb` instead of accessing `/dev/bus/usb` directly. A Unix Domain Socket transfers the descriptors between processes — works with multiple devices (e.g. USB hub on OTG).

## Comparison

| Feature | nohajc | MasterDevX | rendiix | **This** |
|---------|--------|-----------|---------|----------|
| No root | ✅ | ❌ | ❌ | ✅ |
| Auto-updates | ✅ | ❌ | ✅ | ✅ |
| Clean uninstall | ❌ | ✅ | ❌ | ✅ |
| Isolated config | ❌ | ✅ | ❌ | ✅ |
| Wireless ADB | ❌ | ❌ | ❌ | ✅ |
| Diagnostics (doctor) | ❌ | ❌ | ❌ | ✅ |
| Auto-install termux-api | ❌ | ❌ | ❌ | ✅ |
| Architecture check | ❌ | ❌ | ❌ | ✅ |
| Post-install health-check | ❌ | ❌ | ❌ | ✅ |
| SHA256 verify | ❌ | ❌ | ❌ | ✅ |
| Fail-fast (set -e) | ❌ | ❌ | ❌ | ✅ |
| Self-contained (no external deps) | ❌ | ✅ | ❌ | ✅ |
| Symlinks adb/fastboot | ❌ | ❌ | ❌ | ✅ |
| Auto-updater | ❌ | ❌ | ❌ | ✅ |
||||||| 9d7198d
Remove tudo: pacote, symlinks, ferramentas extras, config isolada, variáveis de ambiente dos shell RCs.

## Como funciona

O `termux-adb` usa a API `termux-usb` do Termux:API para obter file descriptors de dispositivos USB sem precisar de root. Os binários adb/fastboot são patchados para varrer dispositivos via `termux-usb` em vez de acessar `/dev/bus/usb` diretamente. Um Unix Domain Socket transfere os descriptors entre processos — funciona com múltiplos dispositivos (ex: hub USB no OTG).

## Comparação

| Feature | nohajc | MasterDevX | rendiix | **Este** |
|---------|--------|-----------|---------|----------|
| Sem root | ✅ | ❌ | ❌ | ✅ |
| Auto-updates | ✅ | ❌ | ✅ | ✅ |
| Uninstall limpo | ❌ | ✅ | ❌ | ✅ |
| Config isolada | ❌ | ✅ | ❌ | ✅ |
| Wireless ADB | ❌ | ❌ | ❌ | ✅ |
| Diagnóstico (doctor) | ❌ | ❌ | ❌ | ✅ |
| Auto-install termux-api | ❌ | ❌ | ❌ | ✅ |
| Verificação de arquitetura | ❌ | ❌ | ❌ | ✅ |
| Health-check pós-install | ❌ | ❌ | ❌ | ✅ |
| SHA256 verify | ❌ | ❌ | ❌ | ✅ |
| Fail-fast (set -e) | ❌ | ❌ | ❌ | ✅ |
| Self-contained (sem deps externas) | ❌ | ✅ | ❌ | ✅ |
| Symlinks adb/fastboot | ❌ | ❌ | ❌ | ✅ |
| Auto-updater | ❌ | ❌ | ❌ | ✅ |
=======
Remove o pacote, ferramentas extras, front-ends e watcher, as linhas de configuração dos shell RCs e o diretório isolado `~/.termux-adb`.
>>>>>>> main

## Limitations

<<<<<<< HEAD
Querying the serial via `libusb`/`termux-usb` is slow. It doesn't affect adb (daemon, scans periodically), but is noticeable in fastboot (no background service).
||||||| 9d7198d
Consultar serial via `libusb`/`termux-usb` é lento. Não afeta adb (daemon, varre periodicamente), mas é perceptível no fastboot (sem serviço em background).
=======
A **enumeração do serial** via `libusb`/`termux-usb` é lenta. No `adb`, o impacto é mitigado pelo daemon, que varre periodicamente os dispositivos; já o `fastboot`, por não possuir daemon em background, torna a operação perceptivelmente lenta. Leve os timeouts em consideração ao operar no modo fastboot.
>>>>>>> main

## Credits

<<<<<<< HEAD
Independent project combining the best ideas from the ecosystem:
||||||| 9d7198d
Projeto independente que reúne as melhores ideias do ecossistema:
=======
Projeto que reúne e consolida as ideias do ecossistema ADB do Termux:
>>>>>>> main

<<<<<<< HEAD
- **[nohajc/termux-adb](https://github.com/nohajc/termux-adb)** — adb/fastboot patch + `termux-usb` without root, distributed via its own apt repo
- **[MasterDevX/Termux-ADB](https://github.com/MasterDevX/Termux-ADB)** — concept of isolating adb data outside `$HOME`
- **[rendiix/termux-adb-fastboot](https://github.com/rendiix/termux-adb-fastboot)** — validated the distribution pattern via apt repo + GPG key
- **[offici5l/termux-adb-fastboot](https://github.com/offici5l/termux-adb-fastboot)** — `adb`→`termux-adb` symlinks and auto-updater concept
||||||| 9d7198d
- **[nohajc/termux-adb](https://github.com/nohajc/termux-adb)** — patch adb/fastboot + `termux-usb` sem root, distribuído via apt repo próprio
- **[MasterDevX/Termux-ADB](https://github.com/MasterDevX/Termux-ADB)** — conceito de isolamento de dados do adb fora do `$HOME`
- **[rendiix/termux-adb-fastboot](https://github.com/rendiix/termux-adb-fastboot)** — validou padrão de distribuição via apt repo + GPG key
- **[offici5l/termux-adb-fastboot](https://github.com/offici5l/termux-adb-fastboot)** — symlinks `adb`→`termux-adb` e conceito de auto-updater
=======
- **[nohajc/termux-adb](https://github.com/nohajc/termux-adb)** — patch do adb/fastboot + integração `termux-usb` (sem root).
- **[MasterDevX/Termux-ADB](https://github.com/MasterDevX/Termux-ADB)** — conceito de isolamento dos dados do adb fora do `$HOME`.
- **[rendiix/termux-adb-fastboot](https://github.com/rendiix/termux-adb-fastboot)** — validação do padrão de distribuição.
- **[offici5l/termux-adb-fastboot](https://github.com/offici5l/termux-adb-fastboot)** — conceito dos symlinks `adb → termux-adb` e do auto-updater.
>>>>>>> main

<<<<<<< HEAD
See [NOTICE.md](NOTICE.md) for attribution details.
||||||| 9d7198d
Ver [NOTICE.md](NOTICE.md) para detalhes de atribuição.
=======
Scripts, documentação e a infraestrutura de instalação são originais deste projeto. Consulte [NOTICE.md](NOTICE.md) para a atribuição detalhada dos binários redistribuídos.
>>>>>>> main

## License

Distribuído sob a licença [MIT](LICENSE).