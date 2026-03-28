output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "vm1_id" {
  description = "VM1 (gateway) instance ID"
  value       = aws_instance.vm1.id
}

output "vm1_public_ip" {
  description = "VM1 (gateway) public IP address"
  value       = aws_instance.vm1.public_ip
}

output "vm1_private_ip" {
  description = "VM1 (gateway) private IP address"
  value       = aws_instance.vm1.private_ip
}

output "vm2_id" {
  description = "VM2 (app server) instance ID"
  value       = aws_instance.vm2.id
}

output "vm2_private_ip" {
  description = "VM2 (app server) private IP address"
  value       = aws_instance.vm2.private_ip
}

output "ssh_key_name" {
  description = "SSH key pair name"
  value       = aws_key_pair.deployment.key_name
}

output "ssh_key_file" {
  description = "SSH private key file path"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "security_group_vm1_id" {
  description = "VM1 security group ID"
  value       = aws_security_group.vm1.id
}

output "security_group_vm2_id" {
  description = "VM2 security group ID"
  value       = aws_security_group.vm2.id
}
