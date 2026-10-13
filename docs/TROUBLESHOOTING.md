# Troubleshooting

Reference guide for the most common errors.

## `ERROR IN RESULTRETURNER` (Termux:API)

**Cause:** the **Termux:API** Android app (`com.termux.api`) does not respond correctly. This usually happens when the app is installed from the **Play Store** (outdated/incompatible version) or when the `termux-api` package version diverges from the app version.

**Check:**
```bash
termux-usb -l          # should return [] or a JSON list
termux-battery-status  # should return JSON data
```

**Fix:**
```bash
pkg reinstall termux-api
```
- **Uninstall** the Termux:API installed from the Play Store;
- **Install** the version from [F-Droid](https://f-droid.org/packages/com.termux.api/).

After reinstalling, restart Termux and test `termux-usb -l` again.

## `no devices/emulators found`

- Check that **USB/wireless debugging** is enabled on the target device;
- Confirm the OTG/cable wiring;
- Run:
  ```bash
  adb kill-server && adb start-server
  adb devices
  ```

## Device appears `offline`

- The target device did not accept the RSA authorization prompt. Replug, accept the prompt and repeat.
- In wireless mode, run `adb kill-server` and reconnect.

## `failed to connect` / `connection refused` (wireless)

- The port used is wrong; check the "Wireless debugging" screen (the connection port differs from the pairing port and changes on every reboot).
- Same Wi-Fi network required (no client isolation).
- Toggle wireless debugging off and on if the port is in use.

## `error: protocol fault (couldn't read status message)`

- Restart wireless debugging on the target device;
- As a fallback, connect via USB and run `adb tcpip 5555`, then `adb connect`.

## Invalid pairing code

Generate a new code in the "Pair device with pairing code" menu on the target device and repeat the pairing.

## Pairing timeout

- Use **split-screen** to keep the pairing dialog visible while typing the code;
- Check the `IP:PORT` format (no `http://` prefix).

## `termux-adb` not found on PATH

Re-run the installer:
```bash
curl -s https://raw.githubusercontent.com/GeneralKaos666/termux-adb/main/install.sh | bash
```
Or run the doctor (see [INSTALLATION.md](INSTALLATION.md)): `termux-adb-doctor`.

## Fastboot very slow

Serial enumeration via `termux-usb`/libusb is slow by design. `adb` reduces the impact by running as a daemon; `fastboot` has no daemon, so every command suffers the delay. Be patient or plan the timeouts.

## Termux:API app permissions

Commands that access SMS, location, contacts, etc. require Android permissions. Grant them under `Settings > Apps > Termux:API > Permissions`.