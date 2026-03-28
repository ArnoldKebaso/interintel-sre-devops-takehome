# Test 1 Config Files

This directory contains deployment and configuration files for the monitoring stack.

## Files

- `namespaces.yaml`: namespace creation for observability components.
- `loki-values.yaml`: Helm values for Loki.
- `promtail-values.yaml`: Helm values for Promtail log shipping.
- `kube-prometheus-stack-values.yaml`: Helm values for Prometheus, Grafana, and related components.
- `helm-install-commands.md`: command sequence used to deploy the stack.

## Deployment Order

1. Apply namespace manifest.
2. Install Loki.
3. Install Promtail.
4. Install kube-prometheus-stack.
5. Apply custom alert rules from `../alerts/prometheus-rules.yaml`.
