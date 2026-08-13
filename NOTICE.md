# Notice

The `.deb` packages of `termux-adb` and `termux-fastboot` redistributed in this repository (via GitHub Releases) were originally compiled and published by **nohajc** at `https://github.com/nohajc/termux-adb` under the **MIT** license (Copyright 2022 nohajc). All credit for the adb/fastboot patch + `termux-usb` integration goes to him. The binaries are redistributed here under the same terms of the original MIT license, to ensure availability independent of the upstream repo.

Additional ideas incorporated in this project:

- Isolation of adb data via `ANDROID_USER_HOME` — inspired by **MasterDevX**'s approach (`https://github.com/MasterDevX/Termux-ADB`), reimplemented using adb's official environment variable.
- One-command silent installation concept — popularized by **MasterDevX**.
- Reliable distribution pattern — also validated by **rendiix** (`https://github.com/rendiix/termux-adb-fastboot`).
- `adb`→`termux-adb` symlinks and auto-updater concept (`termux-adb-u`) — from **offici5l** (`https://github.com/offici5l/termux-adb-fastboot`), reimplemented from scratch.

Scripts, documentation, extra tools (wireless-adb, termux-adb-doctor) and all the installation infrastructure are original to this project.