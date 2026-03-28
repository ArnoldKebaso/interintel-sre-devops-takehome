# Scenario 1 - Pods Running But Application Is Unreachable

## 1. Most Likely Root Cause

The most likely root cause is a traffic path issue between Ingress/Load Balancer and the service backend, not an application crash.

- Pods are `Running`, so application processes are probably alive.
- Timeout at external URL usually points to routing, exposure, or network filtering.
- Most probable suspects:
  - wrong Service selector or targetPort
  - wrong Ingress backend mapping or ingress class
  - Azure Load Balancer/NSG path blocking traffic or probes

## 2. First 3 kubectl Commands I Would Run

1. `kubectl get pods -n <namespace> -o wide`

- Verify pod readiness, node placement, restart count, and expected labels.

2. `kubectl get svc -n <namespace> -o wide`

- Verify service type, clusterIP/external IP, ports, targetPort.

3. `kubectl describe ingress <ingress-name> -n <namespace>`

- Verify host/path rules, backend service/port, ingress class, and warning events.

## 3. Which Resources to Check First and Why

I would check in this order: **Deployment -> Service -> Ingress -> NSG/LB**.

- Deployment first:
  - Confirms container port and readiness probes match reality.
  - Confirms pods are healthy beyond just status text.
- Service second:
  - Most common breakage is selector mismatch or wrong targetPort.
  - If endpoints are empty, ingress has nothing to route to.
- Ingress third:
  - Confirms external HTTP(S) routes map to the correct service/port.
- NSG/LB fourth:
  - Cloud networking checks come after Kubernetes objects are validated.
  - If K8s config is correct, Azure edge controls are next likely blocker.

## 4. How I Would Isolate Pod vs Service vs Ingress/Network

### Pod-level test

- Run: `kubectl exec -n <namespace> <pod-name> -- curl -sS localhost:<container-port>/health`
- If this fails, issue is inside container/app process.

### Service-level test

- Create debug pod: `kubectl run -it --rm debug --image=busybox:1.36 --restart=Never -- sh`
- From debug pod: `wget -qO- http://<service-name>.<namespace>.svc.cluster.local:<service-port>/health`
- If pod test passes but service test fails, issue is service selector/targetPort/endpoints.

### Ingress/network-level test

- Check ingress events: `kubectl describe ingress <ingress-name> -n <namespace>`
- Check ingress controller logs: `kubectl logs -n <ingress-namespace> <ingress-controller-pod>`
- External test: `curl -vk https://<public-host-or-ip>`
- If service test works but external fails, issue is ingress/LB/NSG/DNS/TLS layer.

## 5. How I Would Fix It

- Fix any Service selector mismatch to point to actual pod labels.
- Fix `targetPort` to match container listening port.
- Fix Ingress backend service name/port and `ingressClassName`.
- Confirm ingress controller is running and watching that class.
- In Azure, allow required inbound and probe traffic in NSG.
- Re-test each layer in order: pod -> service -> ingress -> external URL.

## 6. Two Azure-Specific Causes Even If Kubernetes Looks Correct

1. **NSG rule mismatch**

- NSG on subnet/NIC can block 80/443 or health probe traffic while pods remain healthy.

2. **AKS identity or LB integration drift**

- Managed identity/service principal may lack permission to update LB backend pools or frontend config, leaving external path broken even with valid K8s manifests.

## Practical Assumption

Because this assessment has no live AKS setup for Test 3, this reasoning is based on standard AKS traffic flow and real failure patterns seen in this project (where healthy workloads still required networking and controller-layer fixes).
