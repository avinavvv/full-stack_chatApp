#!/usr/bin/env bash
# memory-monitor.sh - Monitor system RAM usage.

set -uo pipefail

WARNING_THRESHOLD=75
CRITICAL_THRESHOLD=90

echo "=== ObserveX Memory Monitor ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

free -b | awk -v warning="$WARNING_THRESHOLD" \
            -v critical="$CRITICAL_THRESHOLD" '
NR == 2 {
    total = $2
    available = $7
    used = total - available
    usage = (used / total) * 100

    printf "Total Memory:     %.2f GiB\n", total / 1024^3
    printf "Used Memory:      %.2f GiB\n", used / 1024^3
    printf "Available Memory: %.2f GiB\n", available / 1024^3
    printf "Memory Usage:     %.2f%%\n\n", usage

    if (usage >= critical) {
        print "STATUS: CRITICAL - Memory usage is high"
        exit 2
    }
    else if (usage >= warning) {
        print "STATUS: WARNING - Memory usage is elevated"
        exit 1
    }
    else {
        print "STATUS: HEALTHY - Memory usage is normal"
    }
}'
