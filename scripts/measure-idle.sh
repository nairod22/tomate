#!/bin/bash
# Measures Tomate's background cost with the popover closed.
#
# Usage: scripts/measure-idle.sh [label] [seconds]
#   label    free text stored in the CSV (e.g. "before", "after")
#   seconds  sampling window per scenario (default 60)
#
# For each scenario (running, paused, idle) it launches a fresh release build,
# waits for warm-up, then records over the window:
#   - CPU seconds consumed (ps cputime delta) and the average CPU %
#   - idle wakeups per second (top's cumulative IDLEW counter delta)
#   - memory footprint at the start and the end of the window
# Results are appended to scripts/measurements.csv.
set -euo pipefail
cd "$(dirname "$0")/.."

LABEL="${1:-$(git rev-parse --short HEAD)}"
WINDOW="${2:-60}"
WARMUP=10
CSV="scripts/measurements.csv"

./build.sh >/dev/null
BIN="build/Tomate.app/Contents/MacOS/Tomate"

# "m:ss.cc" or "h:mm:ss.cc" → seconds
cpu_seconds() {
  ps -o time= -p "$1" | awk -F: '{ s = 0; for (i = 1; i <= NF; i++) s = s * 60 + $i; print s }'
}
idle_wakeups() {
  top -l 1 -pid "$1" -stats idlew | tail -1 | tr -dc '0-9'
}
footprint_mb() {
  footprint "$1" 2>/dev/null | sed -nE 's/.*Footprint: ([0-9.]+) (KB|MB|GB).*/\1 \2/p' | head -1 |
    awk '{ print ($2 == "KB" ? $1 / 1024 : ($2 == "GB" ? $1 * 1024 : $1)) }'
}

[[ -f "$CSV" ]] || echo "date,label,scenario,window_s,cpu_s,cpu_pct,idle_wakeups_per_s,footprint_start_mb,footprint_end_mb" > "$CSV"

run() {
  local scenario="$1"; shift
  env "$@" "$BIN" &
  local pid=$!
  sleep "$WARMUP"
  local c0 w0 f0 c1 w1 f1
  c0=$(cpu_seconds "$pid"); w0=$(idle_wakeups "$pid"); f0=$(footprint_mb "$pid")
  sleep "$WINDOW"
  c1=$(cpu_seconds "$pid"); w1=$(idle_wakeups "$pid"); f1=$(footprint_mb "$pid")
  kill "$pid"; wait "$pid" 2>/dev/null || true
  local line
  line=$(awk -v c0="$c0" -v c1="$c1" -v w0="$w0" -v w1="$w1" -v t="$WINDOW" -v f0="$f0" -v f1="$f1" \
    'BEGIN { printf "%.3f,%.3f,%.2f,%.1f,%.1f", c1 - c0, 100 * (c1 - c0) / t, (w1 - w0) / t, f0, f1 }')
  echo "$(date +%F),$LABEL,$scenario,$WINDOW,$line" >> "$CSV"
  printf '%-8s cpu_s,cpu%%,wakeups/s,fp0,fp1 = %s\n' "$scenario" "$line"
}

run running TOMATE_AUTOSTART=1
run paused  TOMATE_AUTOSTART=1 TOMATE_AUTOPAUSE=1
run idle    TOMATE_IDLE=1
