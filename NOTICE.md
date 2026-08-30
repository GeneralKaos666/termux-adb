# Notice

<<<<<<< HEAD
The `.deb` packages of `termux-adb` and `termux-fastboot` redistributed in this repository (via GitHub Releases) were originally compiled and published by **nohajc** at `https://github.com/nohajc/termux-adb` under the **MIT** license (Copyright 2022 nohajc). All credit for the adb/fastboot patch + `termux-usb` integration goes to him. The binaries are redistributed here under the same terms of the original MIT license, to ensure availability independent of the upstream repo.
||||||| 9d7198d
Os pacotes `.deb` de `termux-adb` e `termux-fastboot` redistribuídos neste repositório (via GitHub Releases) foram originalmente compilados e publicados por **nohajc** em `https://github.com/nohajc/termux-adb` sob licença **MIT** (Copyright 2022 nohajc). Todo o crédito pelo patch adb/fastboot + integração `termux-usb` é dele. Os binários são redistribuídos aqui sob os mesmos termos da licença MIT original, para garantir disponibilidade independente do repo upstream.
=======
Os pacotes `.deb` de `termux-adb` e `termux-fastboot` redistribuídos neste repositório
(via GitHub Releases) foram originalmente compilados e publicados por **nohajc** em
`https://github.com/nohajc/termux-adb` sob licença **MIT** (Copyright 2022 nohajc).
Todo o crédito pelo patch adb/fastboot + integração `termux-usb` é dele. Os binários
são redistribuídos aqui sob os mesmos termos da licença MIT original, para garantir
disponibilidade independente do repositório upstream.
>>>>>>> main

Additional ideas incorporated in this project:

<<<<<<< HEAD
- Isolation of adb data via `ANDROID_USER_HOME` — inspired by **MasterDevX**'s approach (`https://github.com/MasterDevX/Termux-ADB`), reimplemented using adb's official environment variable.
- One-command silent installation concept — popularized by **MasterDevX**.
- Reliable distribution pattern — also validated by **rendiix** (`https://github.com/rendiix/termux-adb-fastboot`).
- `adb`→`termux-adb` symlinks and auto-updater concept (`termux-adb-u`) — from **offici5l** (`https://github.com/offici5l/termux-adb-fastboot`), reimplemented from scratch.
||||||| 9d7198d
- Isolamento de dados do adb via `ANDROID_USER_HOME` — inspirado na abordagem de **MasterDevX** (`https://github.com/MasterDevX/Termux-ADB`), reimplementada usando a variável de ambiente oficial do adb.
- Conceito de instalação silenciosa em 1 comando — popularizado por **MasterDevX**.
- Padrão de distribuição confiável — também validado por **rendiix** (`https://github.com/rendiix/termux-adb-fastboot`).
- Symlinks `adb`→`termux-adb` e conceito de auto-updater (`termux-adb-u`) — de **offici5l** (`https://github.com/offici5l/termux-adb-fastboot`), reimplementado do zero.
=======
- Isolamento de dados do adb via `ANDROID_USER_HOME` — inspirado na abordagem de
  **MasterDevX** (`https://github.com/MasterDevX/Termux-ADB`), reimplementada usando a
  variável de ambiente oficial do adb.
- Conceito de instalação em um comando — popularizado por **MasterDevX**.
- Padrão de distribuição confiável — também validado por **rendiix**
  (`https://github.com/rendiix/termux-adb-fastboot`).
- Conceito de auto-updater (`termux-adb-update`) — de **offici5l**
  (`https://github.com/offici5l/termux-adb-fastboot`), reimplementado do zero.
>>>>>>> main

<<<<<<< HEAD
Scripts, documentation, extra tools (wireless-adb, termux-adb-doctor) and all the installation infrastructure are original to this project.
||||||| 9d7198d
Scripts, documentação, ferramentas extras (wireless-adb, termux-adb-doctor) e toda a infraestrutura de instalação são originais deste projeto.
=======
Os front-ends `adb`/`fastboot` com roteamento automático de backend, o watcher OTG
(`adb-otg-watcher`) e as ferramentas `adbs`, `adbw`, `adbmenu`, `adbpair`, `adbotg` e
`adblocalhost` são **originais deste projeto** (licença MIT, Copyright 2026 rianprei).

Integrações opcionais (não redistribuídas — dependem de instalação separada):

- **scrcpy** (`https://github.com/Genymobile/scrcpy`) — espelhamento de tela.
- **ADBash** (`https://github.com/BuriXon-code/ADBash`) — shell Bash na sessão ADB local.
>>>>>>> main
