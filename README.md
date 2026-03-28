# SRE / DevOps Intern Take-Home Assessment

This repository contains my submission for the SRE/DevOps  technical assessment.

## Scope

- Test 1: Monitoring Stack (Prometheus, Grafana, Loki, Promtail)
- Test 2: Infrastructure Automation (to be added)
- Test 3: Troubleshooting Scenarios (Scenario 1 completed)

## Repository Structure

- test-1-monitoring/: Monitoring stack configs, dashboards, alerts, docs, screenshots
- test-2-automation/: IaC and automation deliverables (next phase)
- test-3-troubleshooting/: Scenario markdown answers


## Test 1 Status ✓

Test 1 implementation is **completed and operational** on local Kubernetes (Minikube on WSL2):

- **Monitoring Stack**: Full kube-prometheus-stack (Prometheus, Grafana, Alertmanager) + Loki (log aggregation) + Promtail (log forwarding)
- **Configurations**: YAML Helm values in `test-1-monitoring/config/`
- **Dashboards**: Three custom Grafana dashboards in `test-1-monitoring/dashboards/`
  - cluster-health-overview.json (CPU, memory, pod counts)
  - application-logs.json (Loki log exploration with filters)
  - workload-reliability.json (pod restart trends, unavailable replicas)
- **Alerts**: Three custom PrometheusRule alerts in `test-1-monitoring/alerts/`
  - PodCrashLoopBackOff (>5 min sustained)
  - NodeHighCPUUsage (>80% for 3 min)
  - HighPodRestarts (>3 restarts in 10 min)
  
- **Evidence**: Screenshots pending in `test-1-monitoring/screenshots/` (8 files recommended)

**Key Achievements**:

- All 9 pods running (Loki, Prometheus, Grafana, Alertmanager, node-exporter, kube-state-metrics, etc.)
- Data sources healthy (Prometheus, Loki, Alertmanager show "Health check passed" in Grafana)
- Loki queries returning log lines with proper namespace/pod labels
- Prometheus metrics aggregating pod/node data correctly
- Custom dashboards successfully imported into Grafana
- Alert rules loaded and monitoring for defined conditions

## Test 2 Status ✓

Test 2 infrastructure automation is **implemented and validated** on AWS:

- **Tool Stack**: Terraform (v1.0+) for AWS infrastructure provisioning, Ansible (v2.9+) for post-provisioning configuration
- **AWS Architecture**:
  - VPC (10.0.0.0/16) with public/private subnets
  - 2 × t3.micro Ubuntu 22.04 LTS instances (VM1 gateway + VM2 app-server)
  - NAT Gateway for private subnet internet access
  - Security Groups (public SSH + HTTP/HTTPS, private SSH from gateway only)
  - Auto-generated SSH key pair for Terraform-Ansible handoff
- **Terraform Files** (in `test-2-automation/terraform/`):
  - main.tf: VPC, subnets, internet gateway, NAT gateway, route tables, data sources
  - variables.tf: Input variables with sensible defaults (aws_region, vpc_cidr, instance_type, your_ip)
  - security.tf: Security groups with least-privilege rules and SSH key pair generation
  - instances.tf: EC2 instance definitions for public and private deployments
  - outputs.tf: Export VM IPs, security group IDs, SSH key path for Ansible integration
  - terraform.tfvars.example: Template for user-provided values
- **Ansible Playbooks** (in `test-2-automation/ansible/`):
  - site.yml: Main playbook orchestrating VM1 (gateway) and VM2 (app-server) configuration
  - Three roles with stand-alone tasks:
    - nginx: Install, enable, and start nginx; create index.html showing gateway status
    - hostname: Set system hostname and update /etc/hosts
    - ssh-user: Create ansible-user with sudo access and SSH key setup
  - inventory.ini.example: Ansible inventory template with proxy jump setup for private subnet access

**Validated Execution**:

- Terraform `plan` and `apply` completed successfully with live resource creation
- Ansible playbook executed against both hosts with `failed=0`
- nginx installed and running on VM1 gateway
- Hostname and SSH user configuration applied to both VMs
- Execution evidence captured in `test-2-automation/docs/terminal_1.txt` and `test-2-automation/docs/terminal2.txt`
- Delivery summary documented in `test-2-automation/docs/test2-delivery-summary.md`

**Operational Notes**:

1. WSL `/mnt/c/...` directories may show a non-blocking Ansible world-writable warning.
2. Python interpreter discovery warning is informational and non-blocking.
3. Clean up AWS resources after assessment: `terraform destroy`.

## Test 3 Status ✓

- **Scenario 1** analysis completed in `test-3-troubleshooting/scenario-1.md`
  - Root cause analysis of misconfigured Ingress/Service traffic flow
  - First 3 kubectl commands for initial diagnosis
  - Systematic resource check order (Deployment → Service → Ingress → Azure network)
  - Pod/service/ingress isolation testing procedures
  - Azure-specific causes identified (NSG blocking, AKS identity drift)
  - Production troubleshooting workflow for distributed system failures
