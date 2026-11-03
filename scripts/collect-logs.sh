#!/usr/bin/env bash
# collect-logs.sh - Collect logs from Kubernetes pods.

set -uo pipefail

NAMESPACE="${1:-observex}"
OUTPUT_DIR="../logs"

mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
OUTPUT_FILE="$OUTPUT_DIR/${NAMESPACE}-logs-${TIMESTAMP}.log"

echo "=== ObserveX Log Collector ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Namespace: $NAMESPACE"
echo

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: Namespace '$NAMESPACE' not found."
    exit 1
fi

echo "Collecting pod logs..."

{
    echo "ObserveX Log Collection Report"
    echo "Namespace: $NAMESPACE"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "========================================"

    for POD in $(kubectl get pods -n "$NAMESPACE" -o name); do
        echo
        echo "========== $POD =========="

        kubectl logs -n "$NAMESPACE" "$POD" --all-containers=true --tail=100 2>&1 || true
    done
} > "$OUTPUT_FILE"

echo "Logs saved successfully."
echo "File: $OUTPUT_FILE"
echo
echo "=== End of Log Collection ==="
