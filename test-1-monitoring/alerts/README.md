# Alert Rules for Test 1

This folder contains custom Prometheus alert rules required by the assessment.

## Included Alerts

1. PodCrashLoopBackOff
- Condition: pod is in CrashLoopBackOff for more than 5 minutes
- Severity: critical

2. NodeHighCPUUsage
- Condition: node CPU usage > 80% for more than 3 minutes
- Severity: warning

3. HighPodRestarts (custom)
- Condition: pod restarts > 3 within 10 minutes
- Severity: warning
- Why this is useful: restart bursts are often an early warning before outages or full crash loops.

## Apply

```bash
kubectl apply -f test-1-monitoring/alerts/prometheus-rules.yaml
```
