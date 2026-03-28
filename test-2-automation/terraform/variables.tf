variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ubuntu_ami_id" {
  description = "Optional override for Ubuntu AMI ID (example: ami-xxxxxxxx). Leave empty to auto-discover Canonical Ubuntu 22.04."
  type        = string
  default     = ""
}

variable "your_ip" {
  description = "Your public IP address for SSH access (CIDR notation, e.g., 203.0.113.42/32)"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "test"
}
