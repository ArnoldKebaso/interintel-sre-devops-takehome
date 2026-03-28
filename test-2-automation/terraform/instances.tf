# VM1 - Gateway (Public)
resource "aws_instance" "vm1" {
  ami                    = local.selected_ubuntu_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployment.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.vm1.id]

  associate_public_ip_address = true

  tags = {
    Name = "gateway-vm"
    Role = "gateway"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  monitoring = true
}

# VM2 - App Server (Private)
resource "aws_instance" "vm2" {
  ami                    = local.selected_ubuntu_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployment.key_name
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.vm2.id]

  associate_public_ip_address = false

  tags = {
    Name = "app-server-vm"
    Role = "app-server"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  monitoring = true
}

# Network Interfaces (for explicit output)
resource "aws_network_interface" "vm1" {
  count           = 0  # Placeholder; use instance details instead
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.vm1.id]
}
