# Changelog

## [3.2.0] - 2026-08-06

### Fixed
- `README.md`: fixed description — "self-contained" instead of "maintained apt repo"
- `README.md`: comparison table — "Auto-updates" instead of "Updates via apt"
- `termux-adb-doctor.sh`: checks dpkg + GitHub Releases instead of apt repo/GPG key (false positives eliminated)
- `termux-adb-doctor.sh`: adds symlink checks for adb/fastboot and termux-adb-update
- `uninstall.sh`: removes unnecessary `apt-get update` (we no longer use apt)

## [3.1.0] - 2026-08-06

### Added
- `install.sh`: `adb` → `termux-adb` and `fastboot` → `termux-fastboot` symlinks (just type `adb`)
- `termux-adb-update.sh`: NEW — auto-updater that checks and updates scripts + package
- `install.sh`: installs `termux-adb-update` on PATH
- `uninstall.sh`: removes `adb`/`fastboot` symlinks and `termux-adb-update`
- Credit to offici5l for the symlink and auto-updater concept

## [3.0.0] - 2026-08-06

### Added
- `install.sh`: SHA256 verification of the GPG key before trusting it (prevents MITM)
- `install.sh`: fallback with a clear message if the upstream repo is offline
- `install.sh`: arch check now blocks (`exit 1`) instead of just warning
- `install.sh`: post-install health-check (runs `termux-adb version` and confirms)
- `install.sh`: installs `wireless-adb` and `termux-adb-doctor` on PATH automatically
- `install.sh`: colored output (green/red/yellow/blue) for clear UX
- `uninstall.sh`: removes `wireless-adb` and `termux-adb-doctor` from PATH
- `uninstall.sh`: reverse health-check (confirms termux-adb left PATH)
- `wireless-adb.sh`: detects local IP automatically via `ip route`
- `wireless-adb.sh`: validates IP:port format before trying to connect
- `wireless-adb.sh`: 15s timeout on pair and connect
- `termux-adb-doctor.sh`: NEW — full diagnostics (binaries, termux-api, repo, config, extras)
- `CONTRIBUTING.md`: NEW — contribution guide
- `.gitignore`: NEW

### Changed
- `install.sh`: binaries now downloaded from our own repo (GitHub Releases), no longer depends on nohajc's apt repo
- `install.sh`: installation via `dpkg -i` directly from the .deb, not via external apt repo
- `ANDROID_SDK_HOME` → `ANDROID_USER_HOME` (both set for compatibility)
- `uninstall.sh`: cleans both variables from shell RCs
- `README.md`: rewritten with comparison table, doctor/wireless/uninstall sections
- Project is 100% self-contained — any external server can go down and ours keeps working

## [2.0.0] - 2026-08-06

### Added
- `install.sh`: adb data isolation via `ANDROID_SDK_HOME`
- `wireless-adb.sh`: interactive helper for wireless ADB (Android 11+)
- `NOTICE.md`: explicit attribution to the inspiring projects

## [1.0.0] - 2026-08-06

### Tested
- `termux-adb --version` → Android Debug Bridge 1.0.41, 35.0.2-android-tools
- `termux-fastboot --version` → 35.0.2-android-tools
- apt repo validated, adb daemon functional, `termux-usb -l` functional

### Added
- `install.sh`: `set -e`, architecture check, auto-installation of `termux-api`
- `uninstall.sh`: removes package, repo list and GPG key