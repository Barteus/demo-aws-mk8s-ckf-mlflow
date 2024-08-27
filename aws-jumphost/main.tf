variable "key_pair_name" {
  description = "The name of the existing key pair to use for the instance"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "The IP address allowed to connect to the instance via SSH"
  type        = string
}

resource "aws_security_group" "jumphost_security_group" {
  name        = "jumphost_security_group"
  description = "Allow SSH from a specific IP address"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Find the latest Ubuntu 22.04 AMI ID
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Create an EC2 instance
resource "aws_instance" "jumphost" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = var.key_pair_name

  # Attach the security group created above
  vpc_security_group_ids = [aws_security_group.jumphost_security_group.id]

  # Define the block device mapping
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  tags = {
    Name = "Jumphost"
  }
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.jumphost.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.jumphost.public_ip
}
