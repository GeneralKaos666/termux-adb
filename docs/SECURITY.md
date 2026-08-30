# Security

Good practices when operating ADB on Termux.

## Access granted

- **Wireless ADB** exposes an ADB service on your local network. Any device on the same network with the matching RSA key can try to connect. Use it only on private, trusted networks.
- **termux-usb** grants access to connected USB devices; the permission popup is your control. Revoke unused access through the app permissions.

## Recommendations

1. **Disable wireless debugging** when not in use on the target device.
2. **Remove unused pairs** under `Wireless debugging > Pair device`.
3. **`adb kill-server`** before leaving a shared network.
4. Do not run pairings on public networks.
5. The `.deb` binaries are published with **SHA256 verification** in `install.sh`. Check the hash before any manual installation of new packages.
6. Keep ADB data isolated in the `~/.termux-adb` directory (this project's default configuration), away from shared scripts.

## Summary threat model

| Threat | Mitigation |
|--------|-----------|
| Unauthorized ADB connection on the LAN | Use only private networks; turn off wireless ADB when not in use. |
| Improper USB access | Grant permission (`termux-usb`) only to known devices. |
| Tampered package | SHA256 verification + exclusive download from the official GitHub Releases. |
| ADB data (RSA keys) leaking | Isolation in `~/.termux-adb` with restricted permissions. |

In doubt, disable the service and use `adb kill-server`.