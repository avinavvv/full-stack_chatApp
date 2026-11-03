#!/usr/bin/env bash
# pod-health.sh - Monitor Kubernetes pod health across all namespaces.

set -uo pipefail

echo "=== ObserveX Kubernetes Pod Health Monitor ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Kubernetes cluster is not reachable."
    exit 2
fi

echo "--- Pod Status Across All Namespaces ---"

kubectl get pods -A -o wide

echo
echo "--- Unhealthy Pods ---"

kubectl get pods -A --no-headers |
awk '
{
    namespace = $1
    pod = $2
    ready = $3
    status = $4
    restarts = $5

    if (status != "Running" && status != "Completed") {
        printf "NAMESPACE: %-15s POD: %-40s STATUS: %-20s RESTARTS: %s\n",
               namespace, pod, status, restarts
        unhealthy++
    }
}
END {
    if (unhealthy == 0)
        print "No unhealthy pods detected."
}'

echo
echo "=== End of Pod Health Report ==="
