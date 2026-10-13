# Changelog

## [4.0.0] - 2026-08-29

### Added
- Unified `adb` front-end with automatic backend routing (termux-adb for OTG via termux-usb; native adb for wireless)
- OTG watcher (`adb-otg-watcher`) keeps a detection cache in the background (routing decision in ~1 ms)
- `fastboot` front-end forwarding to `termux-fastboot`
- Tools: `adbs` (diagnostics), `adbw` (guided wireless), `adbmenu` (menu interface), `adbpair`, `adbotg`, `adblocalhost`
- Integration with scrcpy (mirroring) and ADBash (Bash shell in the ADB session)
- Structured documentation in `docs/` (installation, OTG, wireless, localhost, troubleshooting, security)
- README rewritten with an expanded comparison table and badges

### Changed
- Replaced the `adb`→`termux-adb` symlinks with front-ends in `$HOME/.local/bin` with automatic routing
- `termux-adb-update` now updates all scripts and front-ends
- `termux-adb-doctor` now checks the front-ends and the watcher

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

## v4.1.0 (2026-09-15) — wireless without friction (termux-adb-research §12.5)

- **Magisk fixed-port module** — published in a dedicated repo [rianprei/termux-adb-magisk-rootport](https://github.com/rianprei/termux-adb-magisk-rootport) (v1.0, tested live over 2 real reboots): port 5555 fixed at boot (post-fs-data), setprop → resetprop fallback.
- **`adbw --watch [IP] [PORT]`**: automatic reconnection with 3s→30s backoff, state in `~/.cache/adbw-state`; detects the Magisk module via getprop and uses the fixed port 5555 automatically.
- **`adbw-root-porta [port]`** (root, no module): same on-demand technique via su.
- **`adbw-sweep <IP> [--dry]`** (no root): dynamic port discovery via nmap 32768-60999 — replaces `adb mdns`, absent in Termux's android-tools (nmeum build: MDNS=OFF).
- **`adb-keys-backup`**: tar.gz backup/restore of the host RSA keys (~/.termux-adb), perms 600/644.
- **doctor**: new checks — Magisk module (installed? prop active?), phantom process killer, mDNS absent (expected), host keys.
- test/test-watch.sh: host-side suite for `--watch` with stubs (6 checks).