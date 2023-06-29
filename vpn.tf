provider "aws" {
  region = var.aws_region[terraform.workspace]
}

locals {
  project_name = format("%s_%s", "openvpn", var.aws_region[terraform.workspace])

}



data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  map_public_ip_on_launch = true
  cidr                    = "10.0.0.0/16"
  azs                     = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24"]

  #enable_nat_gateway = true
  #enable_vpn_gateway = false

  tags = {
    Name = local.project_name
  }

}

#security group
resource "aws_security_group" "web-sg" {
  vpc_id = module.vpc.vpc_id
  name   = "web_sg"

  ingress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    protocol    = "udp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    protocol    = "tcp"
    to_port     = 53
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 53
    protocol    = "udp"
    to_port     = 53
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.project_name
  }
}


resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.this.key_name

  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data = file("${path.module}/bootstrap.sh")

  associate_public_ip_address = true
  tags = {
    Name = local.project_name
  }
}

resource "aws_key_pair" "this" {
  key_name   = local.project_name
  public_key = file("~/.ssh/id_rsa.pub")
}

output "aws_instance_public_ip" {
  value = aws_instance.this.public_ip
}
