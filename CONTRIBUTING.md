# Contributing

Issues and pull requests are welcome.

## Reporting a problem

Open an issue with:

- Output of `termux-adb-doctor` (full diagnostics);
- Architecture (`uname -m`);
- Termux version (`apt list --installed 2>/dev/null | grep termux-tools`);
- Steps to reproduce, if applicable.

## Submitting a pull request

- Test on real Termux before opening the PR;
- Keep `set -e` in all scripts;
- Update the `CHANGELOG.md`;
- Update the documentation in `docs/` if the public behavior changes;
- Keep compatibility with `aarch64` and `arm`.

## License

By contributing, you agree that your contributions will be licensed under MIT.