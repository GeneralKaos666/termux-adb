#!/usr/bin/env bash
#
# adbw-binder-daemon — Starts a Binder daemon via app_process + su (root)
#
# STATUS: SKELETON/EXPERIMENTAL — not a finished feature.
#   What IS real and tested: the app_process command + Shizuku's real
#   CLASSPATH (confirmed by source research), the UID 0/2000 gate, and the
#   CLASSPATH→$HOME path working via su on Android 16/root (tested live, see
#   the "Tested live" section in the help).
#   What is NOT ready: the real Java class (DaemonStub is a minimal
#   placeholder that only logs "ready" and sleeps — it doesn't implement the
#   actual Binder protocol nor connect to the bc-poc companion). Termux has
#   no Java/dex toolchain installed in this session — no real .dex was
#   compiled or tested end-to-end. Do not use in production.
#
# What it does:
#   Launches a Java process via app_process (root uid), using the real
#   Shizuku ADB-mode pattern: CLASSPATH=<dex> app_process /system/bin <Class>.
#   The service accepts connections via a Unix socket (ContentProvider doesn't
#   apply to the Termux CLI — see §5). Exposing privileged APIs to the
#   companion daemon of zygisk-bc-poc.
#
# Motivation (Shizuku):
#   Shizuku provides a daemon (app_process + minimal Java) that acts as a
#   "bridge" between non-system apps and system APIs via Binder IPC.
#   We need the same mechanism because the bc-poc companion daemon must make
#   privileged calls that cannot be done via ADB shell alone (e.g.
#   registerService in ServiceManager, system transacts).
#
# Real command (freebuff confirmed):
#   CLASSPATH=<dex> app_process /system/bin <Class>
#
#   - <dex>: path to the compiled .dex (Shizuku uses a standalone .dex, not a
#     .jar — lighter, no need to decompress)
#   - /system/bin: "system dir" of app_process (where it looks for main
#     classes — Shizuku uses /system/bin, not /)
#   - <Class>: fully-qualified name of the Java/Kotlin class with main()
#   - UID gate: 0 / 2000 (freebuff confirmed) — app_process via su runs as
#     root (uid 0), which satisfies the gate.
#
# --- ARCHITECTURE (3 layers, Shizuku-style) ---
#
#   [Termux (shell)]  ──su──>  [app_process (uid 0)]  ──Unix-socket──>  [clients]
#     |                                                      |
#   runs this script                                 companion daemon (bc-poc)
#   (via su, requires root)                          or Termux clients via UDS
#
# 1. Termux: validates prerequisites, assembles CLASSPATH, delegates to su.
# 2. app_process (uid 0 via su): Android JVM launcher. Loads <Class> via
#    CLASSPATH=<dex>. Our stubs don't need the full Android framework.
# 3. Java/Kotlin class: the real Binder service implementation.
#    [REAL IMPLEMENTATION] → Shizuku server classes (github.com/blankj/shizuku,
#    ShizukuService.java + AIDL). freebuff confirmed the command but did not
#    deliver the Java source — use a stub until termux-adb#12 (issue open for freebuff).
#    Estimate: ~150 LOC (Shizuku server ≈). The .dex goes to $DAEMON_DEX_PATH.
#
# --- TRANSPORT CLIENT ↔ DAEMON (freebuff) ---
#
#   ContentProvider: freebuff confirmed that the delivery mechanism via
#   ContentProvider works in real Android apps, but does NOT apply to the
#   Termux CLI (no Android app context). Therefore: client ↔ daemon
#   communicate via a Unix socket ($DAEMON_SOCKET). The bc-poc companion
#   daemon connects to the UDS and sends privileged commands to app_process.
#
#   Honest path: Termux (CLI) → su → app_process (uid 0) → Binder
#   for system APIs; UDS (Unix Domain Socket) for Termux↔daemon.
#
# --- OPERATING MODE ---
#
#   $ adbw-binder-daemon.sh start        # launches app_process via su (foreground)
#   $ adbw-binder-daemon.sh start --bg   # ... in background (setsid)
#   $ adbw-binder-daemon.sh stop         # kills via PID file + su kill
#   $ adbw-binder-daemon.sh status       # checks whether the process is alive
#
# PID file: $ANDROID_USER_HOME/adbw-binder-daemon.pid
# Socket:   $ANDROID_USER_HOME/adbw-binder-daemon.sock
#
# --- PREREQUISITES ---
#   - su (Magisk/KernelSU) — required; app_process runs as uid 0
#   - app_process on PATH or /system/bin/app_process
#   - compiled .dex (Shizuku server or stub) at $DAEMON_DEX_PATH
#
# --- ASSUMPTIONS / DOCUMENTED RISKS (freebuff + device-tested 2026-09-16) ---
#   1. PROVEN on-device (Android 16 / API 36 / Magisk uid=0):
#      `CLASSPATH=/data/data/com.termux/files/home/test.dex app_process /system/bin TestClass`
#      → output "TEST_CLASS_OK". The concern that SELinux would block
#      CLASSPATH pointing at Termux's $HOME on Android 14+ IS FALSE in this
#      setup (Magisk root = SELinux context magisk:s0, permissive).
#      On NON-rooted devices, su does not exist → the ContentProvider fallback
#      needs a real Android app (outside the scope of the Termux CLI).
#   2. ContentProvider delivery: does NOT work in the Termux CLI (freebuff confirmed).
#      UDS is the path for the client. For app-level delivery (non-Termux),
#      a real Android app with a registered <provider> is required — outside CLI scope.
#   3. UID gate 0/2000: satisfied by su (root uid = 0). If su is KernelSU
#      with uid 2000, the gate passes. Shizuku documents this.
#   4. app_process64 (64-bit) is the real binary on Android 16 — the script uses
#      /system/bin/app_process, which resolves to the 64-bit one via symlink.
#
# Source: freebuff (2026-09-16) — Shizuku ADB-mode command pattern;
#   termux-adb-research §14.5 (binder bridge draft).
#

set -uo pipefail

# --- Config (follows the termux-adb convention) ---
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
ANDROID_USER_HOME="${ANDROID_USER_HOME:-$HOME/.termux-adb}"
PID_FILE="${ANDROID_USER_HOME}/adbw-binder-daemon.pid"
DAEMON_LOG="${ANDROID_USER_HOME}/adbw-binder-daemon.log"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
info() { echo -e "${GREEN}[*]${NC} $1"; }
fail() {
	echo -e "${RED}[✗]${NC} $1" >&2
	exit 1
}
step() { echo -e "${BLUE}[>]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# --- Commands ---

cmd_start() {
	local bg=false
	[ "${1:-}" = "--bg" ] && bg=true

	# --- Prerequisites (root + app_process) — need su ---
	command -v su >/dev/null 2>&1 || fail "'su' command missing — root (Magisk/KernelSU) is required"
	su -c 'true' 2>/dev/null || fail "no root permission — grant root access to Termux via the su prompt"

	# Locate app_process
	APP_PROCESS="$(command -v app_process 2>/dev/null || true)"
	if [ -z "$APP_PROCESS" ]; then
		APP_PROCESS="/system/bin/app_process"
	fi
	su -c "test -x '$APP_PROCESS'" 2>/dev/null || fail "app_process not executable via su: $APP_PROCESS"

	# UID gate: 0/2000 (freebuff) — satisfied by su (root uid = 0)
	UID_CHECK="$(su -c 'id -u' 2>/dev/null | tr -d '[:space:]' || true)"
	if [ "$UID_CHECK" != "0" ] && [ "$UID_CHECK" != "2000" ]; then
		warn "UID via su = $UID_CHECK (expected 0 or 2000 — Shizuku gate). Continue? (y/N)"
		read -r yn
		[ "$yn" = "y" ] || [ "$yn" = "Y" ] || fail "UID gate not satisfied. Aborting."
	fi

	# --- Check if it's already running ---
	if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
		warn "daemon already running (PID $(cat "$PID_FILE"))"
		return 0
	fi

	# --- Validate that the .dex exists ---
	# [REAL IMPLEMENTATION] — freebuff: CLASSPATH points to the .dex. Explicit
	# assumption (§untested): /data/local/tmp is world-readable + SELinux
	# permissive, allowing app_process to read the .dex via CLASSPATH.
	DAEMON_CLASS="${DAEMON_CLASS:-com.github.rianprei.adbwbinder.DaemonStub}"
	DAEMON_DEX="${DAEMON_DEX:-/data/local/tmp/adbw-binder-daemon.dex}"

	su -c "test -f '$DAEMON_DEX'" 2>/dev/null || {
		warn "DEX not found at $DAEMON_DEX"
		warn "While we wait for the real Shizuku server Java, use the stub:"
		warn "  echo 'package com.github.rianprei.adbwbinder; class DaemonStub {'"
		warn "  echo '  public static void main(String[]a) throws Exception {'"
		warn "  echo '    java.lang.System.out.println(\"[stub] ready\");'"
		warn "  echo '    java.lang.Thread.sleep(Long.MAX_VALUE); } }' > /data/local/tmp/DaemonStub.java"
		warn "  su -c 'cd /data/local/tmp && javac -cp /system/framework/boot.jar DaemonStub.java && dex -o DaemonStub.dex DaemonStub.class'"
		warn "  su -c 'mv /data/local/tmp/DaemonStub.dex $DAEMON_DEX'"
		fail "Interrupted — no daemon DEX available. Run the stubs above or provide the real .dex."
	}

	step "Launching app_process via su (uid 0, Shizuku ADB-mode pattern)..."
	info "  class: $DAEMON_CLASS"
	info "  dex:    $DAEMON_DEX"
	info "  app_process: $APP_PROCESS"
	info "  uid gate: 0/2000 (Shizuku)"

	# Real command (freebuff): CLASSPATH=<dex> app_process /system/bin <Class>
	# - CLASSPATH: points to the .dex (Shizuku uses a standalone .dex, not a .jar)
	# - /system/bin: system dir of app_process (where it looks for classes)
	# - <Class>: fully-qualified main class
	# Does NOT use -start-system-server (we only want our service, not the system)
	local cmd="CLASSPATH='$DAEMON_DEX' $APP_PROCESS /system/bin $DAEMON_CLASS"

	if $bg; then
		# Background: via su, setsid-style. PID = of the su shell, child app_process = PID+1
		step "Background mode (setsid via su)"
		su -c "setsid $cmd >> '$DAEMON_LOG' 2>&1 & echo \$!" 2>/dev/null >"$PID_FILE.tmp"
		local child_pid="$(cat "$PID_FILE.tmp" 2>/dev/null || true)"
		if [ -n "$child_pid" ]; then
			echo "$child_pid" >"$PID_FILE"
			rm -f "$PID_FILE.tmp"
			info "daemon launched in background (shell PID: $child_pid)"
			info "log: $DAEMON_LOG"
			# Note: the real app_process PID is child_pid+1 — use ps via su
			# to confirm if you need the exact PID.
		else
			rm -f "$PID_FILE.tmp"
			fail "su failed to launch in background — check su logs / logcat"
		fi
	else
		step "Foreground mode (Ctrl+C to stop)"
		# app_process runs in the foreground — Ctrl+C kills su, which kills app_process
		info "press Ctrl+C to stop"
		exec su -c "$cmd" 2>&1 | tee -a "$DAEMON_LOG"
	fi
}

cmd_stop() {
	if [ ! -f "$PID_FILE" ]; then
		warn "no PID file — daemon isn't running?"
		return 1
	fi
	local pid="$(cat "$PID_FILE" 2>/dev/null || true)"
	if [ -z "$pid" ]; then
		rm -f "$PID_FILE"
		return 1
	fi
	step "Stopping daemon (PID $pid) via su..."
	su -c "kill $pid 2>/dev/null; kill -9 $pid 2>/dev/null" 2>/dev/null || true
	rm -f "$PID_FILE"
	info "daemon stopped"
	return 0
}

cmd_status() {
	if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
		info "daemon running (PID $(cat "$PID_FILE"))"
		# freebuff: service name defined in the real Java class (Shizuku server).
		# Meanwhile we only check that the process is alive — dumpsys of the
		# service needs the real name, which only exists once we implement the Java.
		return 0
	fi
	warn "daemon stopped (no valid PID)"
	return 1
}

cmd_help() {
	cat <<'EOF'
Usage: adbw-binder-daemon.sh <command> [options]

Commands:
  start   [--bg]   Launches app_process via su (CLASSPATH=<dex> app_process /system/bin <Class>)
  stop             Stops the daemon (via PID file + su kill)
  status           Checks whether the process is alive

Prerequisites:
  - su (Magisk/KernelSU) — uid 0/2000 (Shizuku gate, freebuff confirmed)
  - app_process on PATH or /system/bin/app_process
  - .dex compiled at $DAEMON_DEX (default: /data/local/tmp/adbw-binder-daemon.dex)

Environment variables:
  DAEMON_CLASS  — fully-qualified Java class (default: com.github.rianprei.adbwbinder.DaemonStub)
  DAEMON_DEX    — path to the .dex (default: /data/local/tmp/adbw-binder-daemon.dex)

Transport:
  Unix socket (UDS) — ContentProvider does not apply to the Termux CLI (freebuff)

Tested live (kilo, 2026-09-16, Android 16/HyperOS device, Magisk root):
  CLASSPATH pointing to \$HOME of Termux worked via su (uid 0) on that
  device/version. The original concern (rish chmod 400 precedent) was
  specifically about Android 14/15 — not tested on those specific versions,
  only confirmed on Android 16. A fallback is still available
  (inject via su -c directly) if some device/version blocks it.
EOF
}

# --- Main dispatch ---
case "${1:-}" in
start) cmd_start "${2:-}" ;;
stop) cmd_stop ;;
status) cmd_status ;;
help | -h | --help) cmd_help ;;
"")
	cmd_help
	exit 1
	;;
*) fail "unknown command: $1 (use: start|stop|status|help)" ;;
esac
