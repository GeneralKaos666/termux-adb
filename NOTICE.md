# Notice

The `.deb` packages of `termux-adb` and `termux-fastboot` redistributed in this repository (via GitHub Releases) were originally compiled and published by **nohajc** at `https://github.com/nohajc/termux-adb` under the **MIT** license (Copyright 2022 nohajc). All credit for the adb/fastboot patch + `termux-usb` integration goes to him. The binaries are redistributed here under the same terms of the original MIT license, to ensure availability independent of the upstream repo.

Additional ideas incorporated in this project:

- Isolation of adb data via `ANDROID_USER_HOME` — inspired by **MasterDevX**'s approach (`https://github.com/MasterDevX/Termux-ADB`), reimplemented using adb's official environment variable.
- One-command silent installation concept — popularized by **MasterDevX**.
- Reliable distribution pattern — also validated by **rendiix** (`https://github.com/rendiix/termux-adb-fastboot`).
- `adb`→`termux-adb` symlinks and auto-updater concept (`termux-adb-update`) — from **offici5l** (`https://github.com/offici5l/termux-adb-fastboot`), reimplemented from scratch.

The `adb`/`fastboot` front-ends with automatic backend routing, the OTG watcher (`adb-otg-watcher`) and the tools `adbs`, `adbw`, `adbmenu`, `adbpair`, `adbotg` and `adblocalhost` are **original to this project** (MIT license, Copyright 2026 rianprei).

Optional integrations (not redistributed — they depend on separate installation):

- **scrcpy** (`https://github.com/Genymobile/scrcpy`) — screen mirroring.
- **ADBash** (`https://github.com/BuriXon-code/ADBash`) — Bash shell in a local ADB session.