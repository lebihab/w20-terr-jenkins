# TERRAFORM main.tf file 

# Create EC2 Instance

resource "aws_instance" "jenkins_server" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.mhd_ssh_key_name
  subnet_id       = aws_subnet.subnet.id
  security_groups = [aws_security_group.jenkins_security_group.id]
  user_data       = var.ec2_user_data

  tags = {
    Name = var.ec2_tag
  }
}


#  Create VPC Resources

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_md_cidr

  tags = {
    Name = var.vpc_tag
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_tag
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.internet_gateway_tag
  }
}

resource "aws_default_route_table" "default_route" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = var.internet_gateway_tag
  }
}

resource "aws_s3_bucket" "s3" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

# Public IP and add to Security Group

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

# Create EC2 Security Group and Security Rules

resource "aws_security_group" "jenkins_security_group" {
  name        = var.security_group_name
  description = "Apply to Jenkins EC2 instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from MY Public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow access to Jenkis from My IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All Outbound"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins_Security_Group"
  }
}

