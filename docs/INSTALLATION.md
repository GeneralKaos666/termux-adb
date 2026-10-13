# Installation

Detailed installation guide for Termux ADB Unified.

## Requirements

- **Termux** — install from [F-Droid](https://f-droid.org/packages/com.termux/). **Do not** use the Play Store version (outdated and incompatible with this project).
- **Termux:API** — install from [F-Droid](https://f-droid.org/packages/com.termux.api/). Provides the `termux-usb` utility, essential for rootless USB OTG access.
- **Disk space** — about 100 MB free for binaries and dependencies.

> For OTG mode, a device with USB host support is required. To use only wireless, a device with Android 11+ is enough.

## One-command installation

```bash
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/install.sh | bash
```

The installer runs the following steps, in order:

1. **Architecture check** — accepts `aarch64` and `arm` (armv7l/armv8l); blocks the others.
2. **Base dependencies** — installs `wget`.
3. **termux-api** — installs the package automatically if `termux-usb` is not present.
4. **Download and install the `.deb` package** — fetched from the project's GitHub Releases, with **SHA256 verification** before installing via `dpkg`. The process stops at the first error (`set -e`).
5. **Data isolation** — sets `ANDROID_USER_HOME` and `ANDROID_SDK_HOME` pointing to `~/.termux-adb` in the `.bashrc` and `.zshrc` files.
6. **Extra tools** — `wireless-adb`, `termux-adb-doctor`, `termux-adb-update`, `adbotg`, `adbpair`, `adbw`, `adblocalhost`, `adbs` and `adbmenu` installed in `$PREFIX/bin`.
7. **Unified front-ends** — `adb`, `fastboot` and `adb-otg-watcher` installed in `~/.local/bin`, which precedes `$PREFIX/bin` in `PATH`.
8. **Health-check** — runs `termux-adb version` and `termux-fastboot --version` to confirm everything is functional.

## Verifying the installation

```bash
adb version
adb devices
adbs
```

`adbs` consolidates the diagnostics: backend versions, the `termux-usb` state, environment variables and the device list.

## Update

```bash
termux-adb-update
```

Queries the latest release on GitHub, updates scripts and front-ends and, if there is a new package version in `install.sh`, reinstalls automatically.

## Uninstall

```bash
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/uninstall.sh | bash
```

Removes the package, extra tools, front-ends, watcher, the configuration lines from the shell RCs and the isolated `~/.termux-adb` directory.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for the most common errors, including the `ERROR IN RESULTRETURNER` error from Termux:API.