provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "jenkins_sonarqube_sg" {
  name        = "ami-image-instance-sg"
  description = "Security group for Jenkins and SonarQube"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080  # Jenkins default port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000  # SonarQube default port
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SonarQube-SG"
  }
}

resource "aws_instance" "jenkins_sonarqube" {
  ami           = "ami-0396d8acdc48b0151"  # Replace with your custom AMI ID
  instance_type = "t3.medium"
  key_name      = "local"     # Replace with your SSH key pair name
  security_groups = [aws_security_group.jenkins_sonarqube_sg.name]

  tags = {
    Name = "Jenkins-SonarQube-Instance"
  }
}
