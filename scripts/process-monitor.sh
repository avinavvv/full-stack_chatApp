#!/usr/bin/env bash
# process-monitor.sh - Display processes consuming the most CPU and memory.

set -uo pipefail

echo "=== ObserveX Process Monitor ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

echo "--- Top 10 Processes by CPU ---"
ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 11

echo
echo "--- Top 10 Processes by Memory ---"
ps -eo pid,ppid,comm,%cpu,%mem --sort=-%mem | head -n 11

echo
echo "=== End of Process Report ==="
