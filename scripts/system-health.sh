
#!/usr/bin/env bash
# system-health.sh - Overall host health and Kubernetes connectivity.

set -u

echo "======================================"
echo "       OBSERVEX SYSTEM HEALTH"
echo "======================================"

echo "Host:      $(hostname)"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

echo "--- Uptime & Load ---"
uptime
echo "CPU cores: $(nproc)"
echo

echo "--- Memory ---"
free -h
echo

echo "--- Disk (root) ---"
df -h /
echo

echo "--- Kubernetes Connectivity ---"

if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl is not installed"
elif kubectl cluster-info >/dev/null 2>&1; then
    echo "Cluster reachable: YES"
    echo
    echo "Node Status:"
    kubectl get nodes --no-headers 2>/dev/null |
        awk '{
            printf "  %-30s %s\n", $1, $2
            if ($2 != "Ready") unhealthy=1
        }
        END {
            if (NR == 0) {
                print "  No nodes returned"
                exit 1
            }
            if (unhealthy) exit 2
        }'
else
    echo "Cluster reachable: NO (check kubeconfig or cluster status)"
fi

echo
echo "======================================"
echo "       HEALTH CHECK COMPLETED"
echo "======================================"

