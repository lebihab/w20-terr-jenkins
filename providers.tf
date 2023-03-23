# Below are the Variables for main.tf file

# VPC variables

variable "vpc_md_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_tag" {
  description = "Name tag for VPC"
  type        = string
  default     = "MHD-VPC"
}

variable "subnet_tag" {
  description = "Name tag for Subnet"
  type        = string
  default     = "MHD-Subnet"
}

variable "subnet_cidr" {
  description = "Subnet cidr block"
  type        = string
  default     = "10.0.0.0/24"
}

variable "internet_gateway_tag" {
  description = "Name tag for Internet Gateway"
  type        = string
  default     = "MHD-Internet-Gateway"
}

# S3 Variables

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "mhdbucket1234"
}

# Security Group

variable "security_group_name" {
  description = "Name for Security Group"
  type        = string
  default     = "MHD TERR Security Group"
}

# EC2

variable "ami" {
  description = "EC2 AMI"
  type        = string
  default     = "ami-0dfcb1ef8550277af"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "mhd_ssh_key_name" {
  description = "SSH Key for EC2"
  type        = string
  default     = "oury1"
}

variable "ec2_user_data" {
  description = "User data script for EC2"
  type        = string
  default     = <<EOF
#!/bin/bash
# Install Jenkins and Java 
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y upgrade
# Add required dependencies for the jenkins package
sudo amazon-linux-extras install -y java-openjdk11 
sudo yum install -y jenkins
sudo systemctl daemon-reload

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Firewall Rules
if [[ $(firewall-cmd --state) = 'running' ]]; then
    YOURPORT=8080
    PERM="--permanent"
    SERV="$PERM --service=jenkins"

    firewall-cmd $PERM --new-service=jenkins
    firewall-cmd $SERV --set-short="Jenkins ports"
    firewall-cmd $SERV --set-description="Jenkins port exceptions"
    firewall-cmd $SERV --add-port=$YOURPORT/tcp
    firewall-cmd $PERM --add-service=jenkins
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload
fi
EOF
}


variable "ec2_tag" {
  description = "Tag for EC2"
  type        = string
  default     = "Jenkins_MhdTerr_Server"
}
