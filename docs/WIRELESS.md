# Using Wireless (Android 11+)

Wireless mode requires **Android 11 (API 30) or higher**. It lets you connect Termux to another device (or this one) on the same network **without a cable and without root**.

## Prerequisites on the target device

1. Enable **Developer options**: `Settings > About phone`, tap 7 times on "Build number".
2. Under `Developer options`, enable **USB debugging** and then **Wireless debugging**.
3. In "Wireless debugging" you will see two distinct pieces of information:
   - **IP address & Port** — connection port (listed under *Connected devices*);
   - **Pair device with pairing code** — pairing port (different) + 6-digit code.

> **Important:** the pairing port and the connection port are different. Also, the connection port **changes on every reboot** of the device, while pairing is done only once.

## Assisted connection (recommended)

```bash
adbw
```

`adbw` guides the process: it detects the local IP, validates `IP:PORT`, runs the pairing (if needed) and the connection, with a 15 s timeout per step.

## Manual connection

```bash
adb pair 192.168.1.100:37123       # PAIRING port + requested code
adb connect 192.168.1.100:5555     # CONNECTION port (different from the pairing one)
adb devices                        # confirms the device
```

For quick re-pairing, if the connection port is known:

```bash
adbpair 192.168.1.100:37123 123456 192.168.1.100:5555
```

## After rebooting the target device

The connection port changes. Rerun only:

```bash
adb connect 192.168.1.100:NEW_PORT
```

## Tips

- Connect only on the **same Wi-Fi network**; wireless ADB generally does not work on networks with client isolation or on mobile data.
- Keep the pairing dialog in **split-screen** next to Termux, since the dialog closes when it loses focus.
- If the device appears as `offline`, run `adb kill-server` and connect again.
- For Android < 11, use the classic cable method: connect via USB, run `adb tcpip 5555` and, after disconnecting, `adb connect IP:5555`.

## Troubleshooting

| Error | Solution |
|------|---------|
| `failed to connect` / connection refused | Wrong port or wireless debugging off; toggle "Wireless debugging" off/on and retry. |
| `error: protocol fault` | Restart wireless debugging on the target device; confirm both are on the same network. |
| Invalid code | Generate a new code in the pairing menu and repeat. |
| Device `offline` | `adb kill-server` and connect again. |