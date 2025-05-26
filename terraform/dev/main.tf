provider "aws" {
  region = "ap-southeast-1"
}

# ✅ Let Terraform manage the key pair
resource "aws_key_pair" "opswat" {
  key_name   = "opswat-key"
  public_key = file("~/.ssh/opswat-key.pub")
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "coffee-vpc" }
}

# Subnets
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Internet Gateway + Route Table
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "dev_sg" {
  name   = "coffee-dev-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "coffee-sg" }
}

# EC2 Instance
resource "aws_instance" "dev_ec2" {
  ami                    = "ami-02f7b163d79aae0cb" # Amazon Linux 2 (ap-southeast-1)
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.opswat.key_name
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              EOF

  tags = { Name = "coffee-ec2" }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "coffee-subnet-group"
  subnet_ids = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

# RDS PostgreSQL
resource "aws_db_instance" "coffee_db" {
  identifier              = "coffee-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "coffee"
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.dev_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
}
