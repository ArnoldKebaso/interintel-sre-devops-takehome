# Test 2 - Infrastructure Automation

## Objective

Automate the provisioning of a simple cloud environment using Infrastructure as Code (IaC) tools.

## Part A - Tool Selection & Justification

### Tools Chosen

**Terraform** (infrastructure provisioning) + **Ansible** (post-provisioning configuration)

### Why This Combination?

**Terraform:**

- Declarative IaC for cloud resource lifecycle (create, update, destroy).
- Multi-cloud support (AWS, Azure, GCP) with consistent syntax.
- State file ensures idempotent operations; safe rollbacks.
- Easy to version control and review in CI/CD pipelines.
- Best tool for: infrastructure definition, scaling, dependency management.

**Ansible:**

- Agentless configuration management; no agent installation required on target VMs.
- Simple YAML-based playbooks; readable and maintainable.
- Flexible post-provisioning: install packages, configure services, manage users.
- Best tool for: OS-level configuration, service deployment, bootstrap tasks.

**Real-world Division:**

- Terraform provisions: VPC, subnets, security groups, VMs, IP addresses, DNS.
- Ansible configures: OS patches, nginx install, hostname, SSH users, service startup.

### Secrets and Sensitive Values Handling

1. **Terraform-level secrets:**
   - Use `.tfvars` files (excluded from Git via `.gitignore`).
   - Environment variables: `TF_VAR_*` for sensitive inputs.
   - Use `sensitive = true` in variable definitions to prevent accidental logs.
   - AWS credentials: sourced from `~/.aws/credentials` or `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` env vars.

2. **Ansible-level secrets:**
   - SSH private key stored securely, not committed to Git.
   - Environment variables or `.env` files for dynamic values.
   - Option: Ansible Vault for encrypted playbook data (not used here for simplicity).

3. **Version Control Safety:**
   - `.gitignore` excludes: `*.tfvars`, `*.tfstate`, `*.tfstate.*`, `.env`, SSH keys.
   - `.gitignore` includes: example files (`terraform.tfvars.example`).

## Part B - Infrastructure Provisioning

### Target Environment

**AWS** (free tier eligible, Windows-friendly, no banking card constraints).

### Architecture Overview

```
AWS Account
│
├── VPC (10.0.0.0/16)
│   ├── Public Subnet (10.0.1.0/24) — us-east-1a
│   │   └── VM1 (Gateway): Ubuntu 22.04, Public IP, Security Group (SG1)
│   │
│   └── Private Subnet (10.0.2.0/24) — us-east-1b
│       └── VM2 (App Server): Ubuntu 22.04, No Public IP, Security Group (SG2)
│
└── Security Groups
    ├── SG1 (VM1): allows SSH:22/your-ip, HTTP:80/all, HTTPS:443/all
    └── SG2 (VM2): allows SSH:22/SG1, all traffic to/from SG1 (peering)
```

### Required Resources Created

1. **VPC**: 10.0.0.0/16
2. **Subnets**:
   - Public: 10.0.1.0/24
   - Private: 10.0.2.0/24
3. **EC2 Instances**:
   - VM1 (gateway): t3.micro, Public IP, Ubuntu 22.04
   - VM2 (app-server): t3.micro, No Public IP, Ubuntu 22.04
4. **Security Groups**:
   - VM1: SSH (22) from your IP, HTTP (80) from anywhere, HTTPS (443) from anywhere
   - VM2: SSH (22) from VM1 SG, All traffic from VM1 SG
5. **Internet Gateway** and **NAT Gateway** for connectivity
6. **Route Tables** for subnet routing

### Post-Provisioning Configuration (Ansible)

**On VM1 (Gateway):**

- Install and start nginx
- Configure hostname to "gateway"
- Create SSH user `ansible-user` with SSH key access

**Verification:**

- SSH into VM1 from your machine
- From VM1, SSH into VM2 (internal testing)
- Test `http://VM1-public-IP` returns nginx default page

## Part C - Setup and Deployment

### Prerequisites

1. **AWS Account** with free tier eligibility
2. **Terraform** installed on Windows (v1.0+)
3. **Ansible** installed on Windows (via WSL2 or native; v2.9+)
4. **SSH client** (built into Windows 10/11)
5. **AWS CLI** (optional, for credential management)
6. **Your public IP address** (for SSH security group rule)

### Credentials Setup

1. Create AWS IAM user with programmatic access:
   - Permissions: EC2 full, VPC full, security group full
   - Download CSV with Access Key ID and Secret Access Key
2. Configure AWS credentials on Windows:
   ```bash
   aws configure
   # or set environment variables:
   $env:AWS_ACCESS_KEY_ID = "your-access-key"
   $env:AWS_SECRET_ACCESS_KEY = "your-secret-key"
   $env:AWS_DEFAULT_REGION = "us-east-1"
   ```

### Terraform Execution

#### Step 1: Initialize Terraform

```bash
cd test-2-automation/terraform
terraform init
```

Output: Terraform downloads AWS provider and initializes state.

#### Step 2: Create Variables File

Create `terraform.tfvars` in `test-2-automation/terraform/`:

```hcl
aws_region           = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
instance_type        = "t3.micro"
your_ip              = "YOUR_PUBLIC_IP/32"  # e.g., "203.0.113.42/32"
```

#### Step 3: Validate Configuration

```bash
terraform validate
```

Output: Configuration syntax is checked.

#### Step 4: Plan Deployment

```bash
terraform plan -out=plan.tfplan > plan-output.txt
```

Output: Shows resources to be created. **Save `plan-output.txt` before moving forward.**

#### Step 5: Apply Deployment

```bash
terraform apply plan.tfplan
```

Output: Creates all AWS resources. Saves state in `terraform.tfstate`.

**Outputs captured automatically:**

- VM1 public IP
- VM1 private IP
- VM2 private IP
- EC2 key pair name

#### Step 6: Retrieve SSH Key

After `terraform apply`, download the private key from AWS Systems Manager Parameter Store or console.

Or, if generated locally by Terraform:

```bash
terraform output -raw private_key > your-key.pem
chmod 400 your-key.pem
```

### Ansible Execution

#### Step 1: Create Inventory File

Create `test-2-automation/ansible/inventory.ini`:

```ini
[gateways]
vm1 ansible_host=<VM1-PUBLIC-IP> ansible_user=ec2-user ansible_ssh_private_key_file=./your-key.pem

[app_servers]
vm2 ansible_host=<VM2-PRIVATE-IP> ansible_user=ec2-user ansible_ssh_private_key_file=./your-key.pem
```

Replace `<VM1-PUBLIC-IP>` and `<VM2-PRIVATE-IP>` with actual values from Terraform outputs.

#### Step 2: Test SSH Connectivity

```bash
ansible all -i inventory.ini -m ping
```

Output: Should show `SUCCESS` for both hosts.

#### Step 3: Run Ansible Playbook

```bash
cd test-2-automation/ansible
ansible-playbook -i inventory.ini site.yml
```

Output: Installs nginx, configures hostname, creates SSH user.

#### Step 4: Verify Configuration

```bash
# SSH into VM1
ssh -i your-key.pem ec2-user@<VM1-PUBLIC-IP>

# From VM1, test nginx
curl http://localhost

# From VM1, SSH to VM2
ssh -i /tmp/vm-key.pem ec2-user@10.0.2.x
```

## What Would Be Improved in Production

1. **State File Management:**
   - Use remote state (S3 + DynamoDB for locking) instead of local `terraform.tfstate`.
   - Enable versioning and encryption on S3.

2. **Secrets Management:**
   - Use AWS Secrets Manager or Parameter Store for storing SSH keys.
   - Rotate credentials regularly.
   - Use Terraform Cloud/Enterprise with VCS integration for CI/CD.

3. **Monitoring & Logging:**
   - Enable VPC Flow Logs to CloudWatch.
   - Install CloudWatch agent on both VMs.
   - Set up CloudTrail for API audit logging.

4. **High Availability:**
   - Auto Scaling Groups for multi-AZ redundancy.
   - Load Balancer (ALB/NLB) in front of VMs.
   - RDS or DynamoDB for stateful data.

5. **Security Hardening:**
   - Use Bastion host pattern (VM1 as SSH gateway only).
   - Disable root login and password authentication.
   - Use IAM instance profiles instead of hardcoded credentials on VMs.
   - Enable AWS Config for compliance monitoring.

6. **IaC Improvements:**
   - Modularize Terraform code (networking, compute, security modules).
   - Add pre-commit hooks for Terraform formatting and validation.
   - Use Terraform testing frameworks (Terratest).
   - Implement policy-as-code (OPA/Sentinel) for governance.

7. **Deployment Pipeline:**
   - Automated `terraform plan` on PR; manual approval for apply.
   - Ansible Tower/AWX for centralized playbook execution.
   - Integration with GitHub Actions or AWS CodePipeline.

## Assumptions

- AWS free tier is available and will not incur charges for t3.micro instances and NAT gateway (within free tier limits).
- SSH key material is kept secure and never committed to Git.
- Your public IP is static or regularly updated in `terraform.tfvars`.
- Windows users have WSL2 with a Linux distribution for Ansible, or use Windows native Ansible via Cygwin/MSYS2.
- Internet connectivity is available for downloading Ubuntu AMI and packages.

## Troubleshooting

See `test-2-automation/docs/troubleshooting.md` for common issues and solutions.

## File Structure

```
test-2-automation/
├── README.md                          (this file)
├── terraform/
│   ├── main.tf                       (AWS provider, VPC, subnets, IGW, NAT)
│   ├── instances.tf                  (EC2 instances, EBS volumes)
│   ├── security.tf                   (Security groups and rules)
│   ├── variables.tf                  (Input variables and defaults)
│   ├── outputs.tf                    (Output values for Ansible)
│   └── terraform.tfvars.example      (Template for .tfvars)
├── ansible/
│   ├── site.yml                      (Main playbook)
│   ├── inventory.ini.example         (Template for inventory)
│   ├── roles/
│   │   ├── nginx/
│   │   │   └── tasks/main.yml       (Install and start nginx)
│   │   ├── hostname/
│   │   │   └── tasks/main.yml       (Configure hostname)
│   │   └── ssh-user/
│   │       └── tasks/main.yml       (Create SSH user)
│   └── host_vars/
│       └── vm1.yml                   (VM-specific variables)
└── plan-output.txt                   (Terraform plan output - required)
```
