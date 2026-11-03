#!/usr/bin/env bash
# disk-monitor.sh - Monitor disk-backed filesystem usage.

set -uo pipefail

WARNING_THRESHOLD=70
CRITICAL_THRESHOLD=85

echo "=== ObserveX Disk Monitor ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

df -P -h -x tmpfs -x devtmpfs -x overlay -x squashfs |
awk -v warning="$WARNING_THRESHOLD" \
    -v critical="$CRITICAL_THRESHOLD" '
BEGIN {
    status = 0
}
NR == 1 {
    print
    next
}
{
    usage = $5
    gsub("%", "", usage)

    print

    if (usage >= critical) {
        print "CRITICAL: " $6 " usage is " usage "%"
        status = 2
    }
    else if (usage >= warning) {
        print "WARNING: " $6 " usage is " usage "%"
        if (status < 1) status = 1
    }
}
END {
    if (status == 2) {
        print "\nSTATUS: CRITICAL"
        exit 2
    }
    else if (status == 1) {
        print "\nSTATUS: WARNING"
        exit 1
    }
    else {
        print "\nSTATUS: HEALTHY"
    }
}'
