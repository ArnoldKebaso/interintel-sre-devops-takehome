# Test 1 - Monitoring Stack

## Objective

Set up a practical logging and metrics monitoring stack for a Kubernetes environment (AKS preferred), then provide useful dashboards and alerts for on-call operations.

## Part A - Tool Selection and Justification

### Logging Tools Chosen

- Promtail
- Loki
- Grafana

Why this logging stack:

- Lightweight and Kubernetes-native compared to heavier ELK-style stacks.
- Promtail integrates directly with pod/container log collection.
- Loki keeps label-based indexing costs lower than full-text indexing approaches.
- Grafana provides a unified interface for logs and metrics.

### Metrics Tools Chosen

- Prometheus
- kube-state-metrics
- node-exporter
- Grafana

Why this metrics stack:

- Strong fit for Kubernetes and AKS operations.
- Widely adopted, well documented, and easy to extend.
- Good balance between setup speed and operational depth.
- Provides all required signals: CPU, memory, pod status/counts.

### Cost, Maintainability, and AKS Fit

- Open-source components reduce direct licensing costs.
- Components are Helm-deployable and straightforward to manage.
- Works in AKS and local Kubernetes with minimal changes.

## Part B - Setup Steps

## Environment Used

- Kubernetes target: Local Kubernetes (Minikube on WSL2 / Docker driver)
- Context: minikube
- Date deployed: 2026-03-28

## Prerequisites

- `kubectl`
- `helm`
- Cluster access (AKS preferred)

## Deployment Commands

```bash
kubectl config current-context

kubectl apply -f test-1-monitoring/config/namespaces.yaml

helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki \
  --namespace observability \
  -f test-1-monitoring/config/loki-values.yaml

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace observability \
  -f test-1-monitoring/config/kube-prometheus-stack-values.yaml

helm upgrade --install promtail grafana/promtail \
  --namespace observability \
  -f test-1-monitoring/config/promtail-values.yaml

kubectl apply -f test-1-monitoring/alerts/prometheus-rules.yaml
```

If Loki was previously installed with incompatible values, recover with:

```bash
helm uninstall loki -n observability || true
helm upgrade --install loki grafana/loki \
  --namespace observability \
  -f test-1-monitoring/config/loki-values.yaml
```

## Verification

```bash
kubectl get pods -n observability
kubectl get svc -n observability
kubectl get prometheusrules -n observability
```

Port-forward Grafana:

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n observability
```

Login:

- URL: `http://localhost:3000`
- Username: `admin`
- Password: value from `test-1-monitoring/config/kube-prometheus-stack-values.yaml`

## Part C - Dashboards and Alerts

## Dashboard 1 - Cluster Health Overview

File: `test-1-monitoring/dashboards/cluster-health-overview.json`

Includes:

- Cluster CPU usage percent
- Cluster memory usage percent
- Running pod count
- Failed pod count

## Dashboard 2 - Application Logs

File: `test-1-monitoring/dashboards/application-logs.json`

Includes:

- Logs from all pods with namespace/pod filters
- Error-level log count over time

## Dashboard 3 - On-call Choice: Workload Reliability

File: `test-1-monitoring/dashboards/workload-reliability.json`

Why chosen:

- On-call teams need early warning of instability, not only hard failures.
- Restarts and unavailable replicas highlight reliability degradation quickly.

Includes:

- Pod restart trend
- Pending pod count
- Unavailable replica count by deployment

## Alerts

Defined in `test-1-monitoring/alerts/prometheus-rules.yaml`:

1. PodCrashLoopBackOff (>5m)
2. NodeHighCPUUsage (>80% for 3m)
3. HighPodRestarts (custom reliability alert)

## Required Evidence (Screenshots)

Place screenshots under `test-1-monitoring/screenshots/`.

Minimum required:

1. Monitoring stack running (pods/services healthy)
2. Metrics query/dashboard visible
3. Logs visible in Grafana

Filenames:

- `01-grafana-datasources.png`
- `02-cluster-health-dashboard.png`
- `03-application-logs-dashboard.png`
- `04-workload-reliability-dashboard.png`
- `05-alert-rules.png`

## Assumptions

- PrometheusRule CRD is available via kube-prometheus-stack.
- Cluster has enough resources to run Loki + Promtail + kube-prometheus-stack.
- Internet access is available for pulling Helm charts and container images.
- Due to Azure subscription constraints with local credit cards during account creation, the environment was simulated locally using Minikube to ensure 100% technical compliance with the monitoring requirements.

## What I Would Improve in Production

- Enable persistent storage for Grafana and Loki.
- Add TLS and ingress for Grafana access.
- Route alerts to Teams/Slack/PagerDuty.
- Add SLO-based alerting and multi-cluster federation.
- Integrate with Azure Monitor for long-term retention and cross-platform visibility.
