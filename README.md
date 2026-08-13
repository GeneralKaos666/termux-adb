# termux-adb

ADB and Fastboot on Termux **without root**. 100% self-contained, isolated config, SHA256 verification, wireless mode, built-in diagnostics, auto-updater, clean uninstall.

## Installation

Install [Termux](https://f-droid.org/packages/com.termux/) and [Termux:API](https://f-droid.org/packages/com.termux.api/) from F-Droid, then:

```
curl -s https://raw.githubusercontent.com/rianprei/termux-adb/main/install.sh | bash
```

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

**100% self-contained** — binaries hosted in our repo (GitHub Releases), no dependency on any external server.

## Usage

### USB (OTG cable)

```
adb devices
```

The first time, Android asks for USB permission — accept it.

### Wireless (Android 11+, no cable)

```
wireless-adb
```

Interactive guide: detects your IP, validates addresses, 15s timeout on each step.

### Diagnostics

```
termux-adb-doctor
```

Checks everything: binaries, termux-api, the Termux:API app, isolated config, extra tools. Green/red output per item.

### Update

```
termux-adb-update
```

Checks for a new version and updates scripts and package automatically.

## Uninstall

```
curl -s https://raw.githubusercontent.com/rianprei/termux-adb/main/uninstall.sh | bash
```

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

## Limitations

Querying the serial via `libusb`/`termux-usb` is slow. It doesn't affect adb (daemon, scans periodically), but is noticeable in fastboot (no background service).

## Credits

Independent project combining the best ideas from the ecosystem:

- **[nohajc/termux-adb](https://github.com/nohajc/termux-adb)** — adb/fastboot patch + `termux-usb` without root, distributed via its own apt repo
- **[MasterDevX/Termux-ADB](https://github.com/MasterDevX/Termux-ADB)** — concept of isolating adb data outside `$HOME`
- **[rendiix/termux-adb-fastboot](https://github.com/rendiix/termux-adb-fastboot)** — validated the distribution pattern via apt repo + GPG key
- **[offici5l/termux-adb-fastboot](https://github.com/offici5l/termux-adb-fastboot)** — `adb`→`termux-adb` symlinks and auto-updater concept

See [NOTICE.md](NOTICE.md) for attribution details.

## License

[MIT](LICENSE)