provider "aws" {
  region = "us-east-1"
}

# Create a new EC2 instance
resource "aws_instance" "jenkins" {
  ami           = "ami-005f9685cb30f234b"
  instance_type = "t2.micro"
  key_name      = "mhd-w7"
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install java-1.8.0-openjdk
              sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum -y install jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "jenkins-instance"
  }
}

# Create a security group for Jenkins
resource "aws_security_group" "jenkins" {
  name_prefix = "jenkins-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.26.131.57/32"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Create the S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins_artifacts-mhd" {
  bucket = "mhd-s3-terr-jenk-yembro-8551"
}

resource "aws_s3_bucket_acl" "jenkins_artifacts-mhd123" {
  bucket = "aws_s3_bucket.mhd-s3-terr-jenk-yembro-8551.id"
  acl    = "private"
}
