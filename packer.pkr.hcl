packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

source "amazon-ebs" "example" {
  region           = var.aws_region
  source_ami       = var.source_ami
  instance_type    = var.instance_type
  ssh_username     = "ubuntu"
  ami_name         = "task3"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    script = "./install-ansible.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-17-jdk",
      "sudo apt-get install -y gnupg2 curl software-properties-common"
    ]
  }

  provisioner "shell" {
    inline = [
        "sudo apt-get update",
        "sudo apt-get install -y gnupg curl",
        "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
        "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
        "sudo apt-get update",
        "sudo apt-get install -y jenkins"
    ]
  }
  provisioner "shell" {
    inline = [
      "wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip",
      "sudo apt-get install -y unzip",
      "sudo unzip sonarqube-9.9.0.65466.zip -d /opt",

      "sudo groupadd sonar",
      "sudo useradd -d /opt/sonarqube -g sonar sonar",
      "sudo chown -R sonar:sonar /opt/sonarqube-9.9.0.65466",

      "sudo ln -s /opt/sonarqube-9.9.0.65466 /opt/sonarqube"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '[Unit]' | sudo tee /etc/systemd/system/sonarqube.service",
      "echo 'Description=SonarQube service' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'After=network.target' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo '[Service]' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'Type=forking' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'User=sonar' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'Group=sonar' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'Restart=always' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo '[Install]' | sudo tee -a /etc/systemd/system/sonarqube.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/sonarqube.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable sonarqube",
      "sudo systemctl enable jenkins"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl start sonarqube",
      "sudo systemctl status sonarqube"
    ]
  }

  provisioner "shell" {
    inline = [
      "wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip",
      "sudo apt-get install -y unzip",
      "sudo unzip sonar-scanner-cli-4.7.0.2747-linux.zip -d /opt",
      "sudo ln -s /opt/sonar-scanner-4.7.0.2747-linux /opt/sonar-scanner",

      "echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile",
      ". /etc/profile"
    ]
  }

  provisioner "shell" {
    inline = [
      "/opt/sonar-scanner/bin/sonar-scanner -v"
    ]
  }
}
