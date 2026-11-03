#!/usr/bin/env bash
# incident-report.sh - Generate a combined Linux and Kubernetes health report.

set -uo pipefail

OUTPUT_DIR="../reports"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
REPORT_FILE="$OUTPUT_DIR/incident-report-${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

{
    echo "=========================================="
    echo "       OBSERVEX INCIDENT REPORT"
    echo "=========================================="
    echo "Host: $(hostname)"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo

    echo "========== SYSTEM HEALTH =========="
    uptime
    echo
    free -h
    echo
    df -h /
    echo

    echo "========== TOP CPU PROCESSES =========="
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
    echo

    echo "========== KUBERNETES NODES =========="
    kubectl get nodes -o wide 2>&1
    echo

    echo "========== KUBERNETES PODS =========="
    kubectl get pods -A 2>&1
    echo

    echo "========== UNHEALTHY PODS =========="
    kubectl get pods -A --no-headers 2>/dev/null |
    awk '
    {
        if ($4 != "Running" && $4 != "Completed") {
            print
            unhealthy++
        }
    }
    END {
        if (unhealthy == 0)
            print "No unhealthy pods detected."
    }'
    echo

    echo "========== RECENT APPLICATION ERRORS =========="
    if [ -d "../logs" ]; then
        grep -ihE 'error|exception|fatal|failed|warning' ../logs/*.log 2>/dev/null | tail -n 20 || echo "No matching errors found."
    else
        echo "No collected application logs found."
    fi

    echo
    echo "========== END OF INCIDENT REPORT =========="
} > "$REPORT_FILE"

echo "ObserveX Incident Report generated successfully."
echo "Report location: $REPORT_FILE"
