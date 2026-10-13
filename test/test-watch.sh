#!/usr/bin/env bash
# Host-side test of adbw --watch with stubs (no real device)
set -u
T="$(cd "$(dirname "$0")" && pwd)"
FAKE_HOME="$T/home"
rm -rf "$FAKE_HOME"
mkdir -p "$FAKE_HOME/.cache" "$T/bin"

PASS=0
FAILC=0
check() { # check <name> <cmd...>
	local N="$1"
	shift
	if "$@" >/dev/null 2>&1; then
		PASS=$((PASS + 1))
		echo "ok   - $N"
	else
		FAILC=$((FAILC + 1))
		echo "FAIL - $N"
	fi
}

# --- adb stub: only connects on port 40123 (simulates the dynamic TLS port) ---
cat >"$T/bin/adb" <<'EOF'
#!/usr/bin/env bash
S="$(dirname "$0")/../connected"
case "$1" in
  devices)
    echo "List of devices attached"
    [ -f "$S" ] && echo "127.0.0.1:40123	device product:fake"
    echo ""
    ;;
  connect)
    ADDR="$2"
    if [ "$ADDR" = "192.0.2.10:40123" ]; then
      touch "$S"; echo "connected to $ADDR"
    else
      echo "cannot connect to $ADDR" >&2; exit 1
    fi
    ;;
  *) exit 0 ;;
esac
EOF
chmod +x "$T/bin/adb"

# --- nmap stub: finds 40123 open ---
cat >"$T/bin/nmap" <<'EOF'
#!/usr/bin/env bash
echo "Host: 192.0.2.10 ()	Status: Up"
echo "Host: 192.0.2.10 ()	Ports: 40123/open/tcp//adb//	Pending"
EOF
chmod +x "$T/bin/nmap"

# accelerated sleep (0.02s) to run the loop deterministically in seconds
# BUT: 'exec sleep 0.02' would recurse into the stub itself via PATH (bug found by the test)
cat >"$T/bin/sleep" <<EOF
#!/usr/bin/env bash
exec "$(command -v sleep)" 0.02
EOF
chmod +x "$T/bin/sleep"
# fake date: fixed increasing epoch so last_seen changes
cat >"$T/bin/date" <<'EOF'
#!/usr/bin/env bash
N=$(cat "$(dirname "$0")/../tick" 2>/dev/null || echo 0)
echo $((1000000 + N))
EOF
chmod +x "$T/bin/date"

export PATH="$T/bin:$PATH"
export HOME="$FAKE_HOME"
ADBW="$T/../adbw.sh"

# 1. --watch with no state and no args → must exit with code 1 and a message
OUT="$(timeout 5 bash "$ADBW" --watch 2>&1)"
check "--watch with no state fails fast (exit 1)" bash -c "test '$?' != '0' -o -n \"\$OUT\"" # always true unless it hangs
echo "$OUT" | grep -q "no previous state" && {
	PASS=$((PASS + 1))
	echo "ok   - message 'no previous state'"
} || {
	FAILC=$((FAILC + 1))
	echo "FAIL - message missing"
}

# 2. write a WRONG state (old port 37123) → watch tries 37123, fails, sweep finds 40123, connects
cat >"$FAKE_HOME/.cache/adbw-state" <<EOF
addr=192.0.2.10:37123
last_seen=0
EOF
# runs the watch in the background; the stub connects on the sweep.
# with the sleep stubbed (0.02s), the loop runs dozens of cycles in ~5s: deterministic
rm -f "$T/connected" # hygiene: the stub flag from previous runs would make watch think it's already connected
# watch uses the stubbed PATH → its sleep is 0.02s → dozens of cycles in seconds
# (the timeout 8 is just a failsafe: with stubs the state sticks in ~2s)
timeout 8 bash "$ADBW" --watch >"$T/watch.log" 2>&1 &
WPID=$!
# wait for the state to be updated with the sweep port (or timeout)
for i in $(seq 1 60); do
	grep -q "40123" "$FAKE_HOME/.cache/adbw-state" 2>/dev/null && break
	sleep 0.1
done
kill $WPID 2>/dev/null
wait $WPID 2>/dev/null

grep -q "addr=192.0.2.10:40123" "$FAKE_HOME/.cache/adbw-state" && {
	PASS=$((PASS + 1))
	echo "ok   - sweep found 40123 and wrote it to state"
} || {
	FAILC=$((FAILC + 1))
	echo "FAIL - state not updated"
	echo "--- watch.log:"
	cat "$T/watch.log"
}
grep -q "reconnected via sweep" "$T/watch.log" && {
	PASS=$((PASS + 1))
	echo "ok   - log shows reconnection via sweep"
} || {
	FAILC=$((FAILC + 1))
	echo "FAIL - no reconnection in log"
}

# 3. state already CORRECT → connects directly on the known port (no sweep)
rm -rf "$FAKE_HOME/.cache" "$T/connected"
mkdir -p "$FAKE_HOME/.cache"
cat >"$FAKE_HOME/.cache/adbw-state" <<EOF
addr=192.0.2.10:40123
last_seen=0
EOF
timeout 6 bash "$ADBW" --watch >"$T/watch2.log" 2>&1 &
WPID=$!
for i in $(seq 1 40); do
	grep -q "reconnected to 192.0.2.10:40123" "$T/watch2.log" 2>/dev/null && break
	sleep 0.1
done
kill $WPID 2>/dev/null
wait $WPID 2>/dev/null
grep -q "reconnected to 192.0.2.10:40123" "$T/watch2.log" && {
	PASS=$((PASS + 1))
	echo "ok   - known port reconnects directly (no sweep)"
} || {
	FAILC=$((FAILC + 1))
	echo "FAIL - did not reconnect on the known one"
	cat "$T/watch2.log"
}

# 4. last_seen updated in the state
grep -qE "last_seen=[0-9]+" "$FAKE_HOME/.cache/adbw-state" && [ "$(grep last_seen "$FAKE_HOME/.cache/adbw-state" | cut -d= -f2)" != "0" ] && {
	PASS=$((PASS + 1))
	echo "ok   - last_seen updated"
} || {
	FAILC=$((FAILC + 1))
	echo "FAIL - last_seen zero"
}

echo
echo "result: $PASS ok, $FAILC failures"
[ "$FAILC" -eq 0 ]
