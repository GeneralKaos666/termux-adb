# Termux ADB Unified

ADB and Fastboot on Termux **without root** and **without unlocking the bootloader**.

[![version-4.0.0](https://img.shields.io/badge/version-4.0.0-blue)](https://github.com/GeneralKaos666/termux-adb/releases/tag/v4.0.0)
[![license-MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

This project integrates the main implementations of the Termux ADB ecosystem — USB OTG via `termux-usb`, wireless (Android 11+), localhost and screen mirroring via scrcpy — into a **single unified command interface** with automatic backend routing.

## Key features

- **USB OTG without root (device→device)** — patched `termux-adb` binary, accessed via `termux-usb`.
- **Wireless (Android 11+, pairing by code)** — `adb` front-end + interactive assistant `adbw`.
- **Localhost (debugging this device)** — `adblocalhost` (connection on `127.0.0.1`).
- **Unified `adb` front-end** — automatically decides between `termux-adb` (OTG) and native `adb` (wireless), with a decision based on a watcher cache (latency ~1 ms).
- **Fastboot without root** — `fastboot` front-end forwards to `termux-fastboot`.
- **Integrated diagnostics** — `adbs` (quick status) and `termux-adb-doctor` (full check).
- **Interactive menu** — `adbmenu`, consolidating all operations.
- **Screen mirroring with scrcpy** — optional, integrated into the menu and diagnostics.
- **Isolated config** — adb data in `~/.termux-adb`, outside `$HOME`.
- **Self-contained distribution** — `.deb` binaries hosted on GitHub Releases, with SHA256 integrity verification.

## Requirements

- **Termux** and **Termux:API** — both from [F-Droid](https://f-droid.org/). **Do not** use the Play Store versions (they are outdated and incompatible).
- **Android device with USB host support** — for the OTG mode. Alternatively, **Android 11+** to use wireless without a cable.
- **~100 MB of free storage** for the binaries and dependencies.

## Installation

Install [Termux](https://f-droid.org/packages/com.termux/) and [Termux:API](https://f-droid.org/packages/com.termux.api/) from F-Droid, then:

```
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/install.sh | bash
```

The installer runs the following steps, in order:

1. **Architecture check** — blocks unsupported architectures (supported: `aarch64`, `arm`/`armv7l`/`armv8l`).
2. **Base dependencies** — installs `wget`.
3. **termux-api** — installs automatically if `termux-usb` is not present.
4. **Download and install the `.deb` package** (GitHub Releases) with **SHA256 verification** before installing via `dpkg`; the process stops at the first error (`set -e`).
5. **Data isolation** — sets `ANDROID_USER_HOME` and `ANDROID_SDK_HOME` pointing to `~/.termux-adb` in the shell RCs (`.bashrc`/`.zshrc`).
6. **Extra tools** — installed on PATH (`$PREFIX/bin`).
7. **Unified front-ends** — `adb`, `fastboot` and `adb-otg-watcher` in `~/.local/bin`, ensuring PATH precedence.
8. **Health-check** — runs `termux-adb version` and `termux-fastboot --version` to confirm the installation.

The project is 100% self-contained: the binaries are hosted in this repository, with no dependency on external servers.

## Usage

### USB OTG (cable)

```
adb devices
```

The first time, the Android device requests USB permission — accept it. To list and grant permission to the connected OTG devices, use `adbotg`.

### Wireless (Android 11+, no cable)

```
adbw
```

`adbw` is an interactive guide: it detects the local IP, validates the `IP:PORT` addresses, runs code pairing and connection, with a 15 s timeout per step. Alternatively, do it manually:

```
adb pair IP:PAIRING_PORT CODE
adb connect IP:PORT
```

### Quick pairing

```
adbpair IP:PAIRING_PORT CODE [IP:CONNECTION_PORT]
```

If the connection port is not given, only the pairing is run.

### Localhost (this device)

```
adblocalhost
```

Connects to `127.0.0.1` via wireless debugging, allowing you to debug this device.

### Interactive menu

```
adbmenu
```

Brings together the most common operations: wireless and localhost connection, OTG listing, `adb shell`, scrcpy mirroring, Bash shell in the ADB session (`ADBash.sh`), APK installation, `pull`/`push`, diagnostics and pairing.

### Environment status

```
adbs
```

Shows backend versions, the `termux-usb` state, environment variables and the device list (`adb devices`).

### Diagnostics

```
termux-adb-doctor
```

Full check (binaries, termux-api, the Termux:API app, dpkg package, isolated config, front-ends and extra tools) with green/red output per item.

## Installed tools

| Command               | Destination       | Function |
|-----------------------|-------------------|----------|
| `termux-adb`          | `$PREFIX/bin`     | Patched ADB binary (OTG via `termux-usb`), installed via `dpkg`. |
| `termux-fastboot`     | `$PREFIX/bin`     | Patched Fastboot binary, installed via `dpkg`. |
| `adb`                 | `~/.local/bin`    | Unified front-end with automatic backend routing. |
| `fastboot`            | `~/.local/bin`    | Front-end that forwards to `termux-fastboot`. |
| `adb-otg-watcher`     | `~/.local/bin`    | Background watcher that keeps the OTG cache up to date. |
| `wireless-adb`        | `$PREFIX/bin`     | Interactive wireless connection assistant (uses `termux-adb`). |
| `adbotg`              | `$PREFIX/bin`     | Lists USB OTG devices via `termux-usb -l`. |
| `adbpair`             | `$PREFIX/bin`     | Quick pairing by code. |
| `adbw`                | `$PREFIX/bin`     | Interactive wireless connection. |
| `adblocalhost`        | `$PREFIX/bin`     | Debugging this device (`127.0.0.1`). |
| `adbs`                | `$PREFIX/bin`     | Overall status of the ADB system (quick diagnostics). |
| `adbmenu`             | `$PREFIX/bin`     | Interactive menu of the ADB tools. |
| `termux-adb-doctor`   | `$PREFIX/bin`     | Full environment diagnostics. |
| `termux-adb-update`   | `$PREFIX/bin`     | Auto-updater for scripts and package. |

## How it works

`termux-adb` uses the `termux-usb` API from Termux:API to obtain file descriptors of USB devices without requiring root. The binaries are patched in `lib` to remap `/dev/bus/usb` to a virtual directory, and a **Unix Domain Socket (UDS)** transfers the descriptors between processes — allowing multiple connected devices, including via a USB hub over OTG.

The `adb` front-end unifies the two access families:

- **OTG** → `termux-adb` (nohajc patch via `termux-usb`);
- **Wireless/localhost** → native `adb` (android-tools, faster).

The `adb-otg-watcher` queries `termux-usb -l` in the background (single instance guaranteed by `flock`, updates every 4 s) and writes the result to `~/.termux-adb/otg.cache`. The front-end decides the route with just one `stat` + one `cat` (~1 ms), without blocking. The `pair`/`connect`/`disconnect` commands and other network operations are always directed to the native backend. The `dpkg` package provides the `termux-adb` and `termux-fastboot` binaries; the routing to the `adb`/`fastboot` front-ends in `~/.local/bin` guarantees the unified interface.

## Comparison

| Feature | nohajc | MasterDevX | rendiix | **This (v4.0.0)** |
|---------|:------:|:----------:|:-------:|:------------------:|
| No root | ✅ | ❌ | ❌ | ✅ |
| OTG via termux-usb | ✅ | ❌ | ❌ | ✅ |
| Wireless ADB | ❌ | ❌ | ❌ | ✅ |
| Localhost ADB | ❌ | ❌ | ❌ | ✅ |
| Diagnostics | ❌ | ❌ | ❌ | ✅ |
| Clean uninstall | ❌ | ✅ | ❌ | ✅ |
| Isolated config | ❌ | ✅ | ❌ | ✅ |
| Auto-updater | ❌ | ❌ | ❌ | ✅ |
| SHA256 verification | ❌ | ❌ | ❌ | ✅ |
| Architecture check | ❌ | ❌ | ❌ | ✅ |
| Front-end with automatic routing | ❌ | ❌ | ❌ | ✅ |
| Watcher / low latency | ❌ | ❌ | ❌ | ✅ |
| scrcpy integrated | ❌ | ❌ | ❌ | ✅ |
| Interactive menu | ❌ | ❌ | ❌ | ✅ |
| Self-contained distribution | ❌ | ❌ | ❌ | ✅ |

## Update

```
termux-adb-update
```

Queries the latest release on GitHub, updates the installed scripts and, if there is a new package version in `install.sh`, reinstalls it automatically. The `adb`/`fastboot` front-ends and the watcher are updated at the end.

## Uninstall

```
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/uninstall.sh | bash
```

Removes the package, extra tools, front-ends and watcher, the configuration lines from the shell RCs and the isolated `~/.termux-adb` directory.

## Limitations

Querying the serial via `libusb`/`termux-usb` is slow. It doesn't affect adb (daemon, scans periodically), but is noticeable in fastboot (no background service). Keep the timeouts in mind when operating in fastboot mode.

## Credits

Project that brings together and consolidates the ideas of the Termux ADB ecosystem:

- **[nohajc/termux-adb](https://github.com/nohajc/termux-adb)** — adb/fastboot patch + `termux-usb` integration (no root), distributed via its own apt repo.
- **[MasterDevX/Termux-ADB](https://github.com/MasterDevX/Termux-ADB)** — concept of isolating adb data outside `$HOME`.
- **[rendiix/termux-adb-fastboot](https://github.com/rendiix/termux-adb-fastboot)** — validated the distribution pattern via apt repo + GPG key.
- **[offici5l/termux-adb-fastboot](https://github.com/offici5l/termux-adb-fastboot)** — `adb`→`termux-adb` symlinks and auto-updater concept.

The scripts, documentation and installation infrastructure are original to this project. See [NOTICE.md](NOTICE.md) for the detailed attribution of the redistributed binaries.

## License

Distributed under the [MIT](LICENSE) license.