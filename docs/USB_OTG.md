# Using USB OTG

Termux ADB Unified lets you debug an Android device from Termux itself, connecting two devices by cable, **without root**.

## How it works

The `termux-adb` package provides patched `adb`/`fastboot` binaries that do not access `/dev/bus/usb` directly (which would require root). Instead, they use the `termux-usb` utility from the [Termux:API](https://f-droid.org/packages/com.termux.api/) app, which:

1. Enumerates the available USB devices (`termux-usb -l`);
2. Gets user permission to access the device (`termux-usb -r` or automatically on first use);
3. Provides a file descriptor of the device, transferred between processes via a **Unix Domain Socket (UDS)**.

A `lib` hook remaps `/dev/bus/usb` to a virtual directory, letting `adb` list devices without any special permission.

## Required hardware

- **USB-C male-to-male cable** (two USB-C devices), or
- **OTG adapter** + regular cable (for micro-USB).

For multiple simultaneous devices, a **USB hub** can be used in OTG mode.

## First use

```bash
adbotg        # lists USB devices via termux-usb -l
adb devices   # the device requests USB permission — accept it
```

On the first connection Android shows the USB authorization dialog. The permission can expire on every reconnection or Termux restart — it is expected that the dialog reappears.

## Common operations

```bash
adb shell                             # remote shell
adb push local-file /sdcard/          # upload file
adb pull /sdcard/file .               # download file
adb install app.apk                   # install app
termux-fastboot flash recovery twrp.img
termux-fastboot reboot                # in bootloader mode
```

To use a specific device (with a hub):

```bash
adb -s <serial> shell
```

## Tips

- The unified `adb` front-end automatically detects OTG mode and routes to `termux-adb`; with a wireless transport it uses the native backend.
- `adb devices` may take a while to show the device the first time because `termux-usb` aggregates discovery in the background.

## Common problems

| Problem | Solution |
|----------|---------|
| Device does not appear in `adb devices` | Confirm USB debugging is enabled on the target device; change the cable/port; check `termux-usb -l`. |
| Permission popup does not appear | Replug the cable; check that the Termux:API app is installed and updated. |
| `no devices/emulators found` | Run `adb kill-server && adb start-server` and try again. |
| Slow fastboot | Enumeration via `termux-usb` is slow; fastboot has no background daemon. Wait or increase the timeout. |