# Debugging this device (localhost)

It is possible to connect ADB to **this device** (`127.0.0.1`), without any cable. This procedure is useful for:

- Granting permissions to apps such as Brevent, Ice Box and Shizuku;
- Opening a local ADB shell (`adb shell`);
- Using scrcpy to mirror to a remote device.

## Prerequisites

- Android 11 or higher;
- Wireless debugging enabled (see [WIRELESS.md](WIRELESS.md)).

## Assisted procedure

```bash
adblocalhost
```

The script asks for the **pairing port** (`Pair device with pairing code`) and the **6-digit code**; then the **connection port** (`IP address & Port`, different from the pairing one).

## Manual procedure

```bash
adb pair 127.0.0.1:PAIRING_PORT   # enter the 6-digit code
adb connect 127.0.0.1:CONNECTION_PORT
adb devices
```

The pairing is one-time; on the following connections just run `adb connect`.

## Notes

- **Split-screen** is recommended to keep the pairing dialog visible while typing the code in Termux.
- The ADB session depends on the daemon being active: if wireless debugging is turned off, the connection drops.