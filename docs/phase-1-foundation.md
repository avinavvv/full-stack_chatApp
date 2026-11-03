# ObserveX – Phase 1: Foundation & Linux Operations

## 1. Overview

Phase 1 establishes the foundation for ObserveX, a Kubernetes Operations, Observability and Site Reliability Engineering (SRE) platform.

The objective of this phase is to build a Linux and Kubernetes health-monitoring toolkit using Bash scripts.

These scripts help monitor system resources, inspect Kubernetes workloads, collect application logs and generate incident reports.

## 2. Environment

| Component | Configuration |
|---|---|
| Operating System | Ubuntu Linux |
| Infrastructure | AWS EC2 |
| CPU | 2 vCPUs |
| Memory | 7.6 GiB |
| Container Runtime | Docker |
| Kubernetes | kind |
| Kubernetes Version | v1.33.1 |
| Cluster Name | argocd-cluster |
| Cluster Nodes | 3 |
| Scripting | Bash |
| Container Orchestration | Kubernetes |

**Important:** All three kind nodes run on a single EC2 instance. They provide a multi-node Kubernetes test environment, not physical multi-host high availability.

## 3. Project Structure

```text
full-stack_chatApp/
│
├── scripts/
│   ├── system-health.sh
│   ├── disk-monitor.sh
│   ├── memory-monitor.sh
│   ├── process-monitor.sh
│   ├── pod-health.sh
│   ├── collect-logs.sh
│   └── incident-report.sh
│
├── logs/
│   └── observex-logs-<timestamp>.log
│
├── reports/
│   └── incident-report-<timestamp>.txt
│
├── docs/
│   └── phase-1-foundation.md
│
├── kubernetes/
├── backend/
├── frontend/
└── README.md
```

## 4. Implemented Monitoring Scripts

### 4.1 System Health Monitor

**File:** `scripts/system-health.sh`

**Purpose:**

Provides an overview of Linux host health and Kubernetes connectivity.

**Monitors:**
- System uptime and load average.
- Available CPU cores.
- Memory utilization.
- Root filesystem disk usage.
- Kubernetes cluster connectivity.
- Kubernetes node status.

**Execution:**

```bash
chmod +x scripts/system-health.sh
./scripts/system-health.sh
```

### 4.2 Disk Monitor

**File:** `scripts/disk-monitor.sh`

**Purpose:**

Monitors filesystem utilization and identifies potential disk-capacity problems.

**Features:**
- Displays filesystem usage.
- Excludes temporary and pseudo filesystems.
- Generates warning and critical statuses.
- Uses configurable thresholds.

**Thresholds:**

| Status | Disk Usage |
|---|---:|
| Healthy | Below 70% |
| Warning | 70% or above |
| Critical | 85% or above |

**Execution:**

```bash
./scripts/disk-monitor.sh
```

### 4.3 Memory Monitor

**File:** `scripts/memory-monitor.sh`

**Purpose:**

Tracks system RAM utilization and identifies high-memory usage conditions.

**Features:**
- Displays total memory.
- Calculates used memory using the Linux available-memory metric.
- Displays available memory.
- Evaluates memory usage against configured thresholds.

**Thresholds:**

| Status | Memory Usage |
|---|---:|
| Healthy | Below 75% |
| Warning | 75% or above |
| Critical | 90% or above |

**Execution:**

```bash
./scripts/memory-monitor.sh
```

### 4.4 Process Monitor

**File:** `scripts/process-monitor.sh`

**Purpose:**

Identifies processes consuming the highest CPU and memory resources.

**Features:**
- Displays the top 10 CPU-consuming processes.
- Displays the top 10 memory-consuming processes.
- Shows PID, parent PID, process name, CPU and memory utilization.

**Execution:**

```bash
./scripts/process-monitor.sh
```

### 4.5 Kubernetes Pod Health Monitor

**File:** `scripts/pod-health.sh`

**Purpose:**

Checks Kubernetes pod status across all namespaces.

**Features:**
- Checks Kubernetes cluster connectivity.
- Lists pods across all namespaces.
- Displays pod status and restart counts.
- Identifies pods whose phase is neither Running nor Completed.

**Execution:**

```bash
./scripts/pod-health.sh
```

**Current limitation:** This initial implementation checks pod phase. It does not independently detect every readiness failure or flag high restart counts when a pod is still Running. These checks can be enhanced in a later iteration.

### 4.6 Kubernetes Log Collector

**File:** `scripts/collect-logs.sh`

**Purpose:**

Collects application logs from Kubernetes pods and saves them to local files.

**Features:**
- Accepts a namespace as an optional argument.
- Uses `observex` as the default namespace.
- Collects logs from all containers in each pod.
- Collects the latest 100 lines per pod.
- Stores collected logs with timestamps.

**Execution:**

Default namespace:

```bash
./scripts/collect-logs.sh
```

Specific namespace:

```bash
./scripts/collect-logs.sh observex
```

**Output location:**

```text
logs/observex-logs-<timestamp>.log
```

**Current limitation:** This collector gathers current container logs. It does not retrieve previous container-instance logs or maintain continuous log streaming.

### 4.7 Incident Report Generator

**File:** `scripts/incident-report.sh`

**Purpose:**

Combines Linux system information and Kubernetes health information into a single incident report.

**Report includes:**
- Hostname and timestamp.
- System uptime.
- Memory utilization.
- Root filesystem usage.
- Top CPU-consuming processes.
- Kubernetes node status.
- Kubernetes pod status across namespaces.
- Recent application log errors and warnings.

**Execution:**

```bash
./scripts/incident-report.sh
```

**Output location:**

```text
reports/incident-report-<timestamp>.txt
```

## 5. Initial Validation Results

The scripts were executed and validated on the Ubuntu EC2 environment.

| Resource | Observed Result |
|---|---|
| CPU Cores | 2 |
| Total Memory | 7.59 GiB |
| Used Memory | 2.26 GiB |
| Available Memory | 5.33 GiB |
| Memory Usage | 29.82% |
| Root Disk Usage | 48% |
| Kubernetes Nodes | 3 Ready |
| Application Pods | Running |

**Validation summary:**

- Linux system health checks executed successfully.
- Disk monitoring returned HEALTHY.
- Memory monitoring returned HEALTHY.
- Process monitoring displayed CPU and memory consumption.
- Kubernetes pod monitoring completed.
- Application logs were collected successfully.
- Incident report was generated successfully.

## 6. Log Investigation

During log collection, the following application error was identified:

```text
ENOENT: no such file or directory,
stat '/frontend/dist/index.html'
```

**Meaning:**

The application attempted to access a frontend build file that was not found at the specified path.

The backend also showed a successful MongoDB connection, and frontend health probes returned HTTP 200.

This issue was recorded for further investigation. No application or ArgoCD configuration was changed as part of Phase 1.

## 7. Operational Commands

Run scripts from the repository root:

```bash
cd ~/full-stack_chatApp
```

Execute individual scripts:

```bash
./scripts/system-health.sh
./scripts/disk-monitor.sh
./scripts/memory-monitor.sh
./scripts/process-monitor.sh
./scripts/pod-health.sh
./scripts/collect-logs.sh
./scripts/incident-report.sh
```

Inspect generated logs:

```bash
ls -lh logs/
```

Inspect generated reports:

```bash
ls -lh reports/
```

Read the latest incident report:

```bash
latest_report=$(ls -t reports/incident-report-*.txt | head -n 1)
cat "$latest_report"
```

## 8. Phase 1 Deliverables

- Linux system health monitoring.
- Disk utilization monitoring.
- Memory utilization monitoring.
- CPU and memory process inspection.
- Kubernetes pod status inspection.
- Kubernetes application log collection.
- Automated incident report generation.
- Initial operational documentation.

## 9. Next Phase

**Phase 2 – Microservices Deployment**

The next phase will focus on deploying an instrumented microservices application and a custom FastAPI service on Kubernetes.

Planned work:

- OpenTelemetry Demo deployment.
- Custom FastAPI application.
- Kubernetes Deployments and Services.
- ConfigMaps and application configuration.
- Readiness and liveness probes.
- Resource requests and limits.
- Controlled fault injection.

This will establish the application layer that ObserveX will monitor in subsequent observability phases.

---

**Project:** ObserveX – Kubernetes Operations, Observability & SRE Platform

**Phase:** 1 – Foundation & Linux Operations

**Status:** Implementation and initial validation completed. Documentation and repository integration in progress.
