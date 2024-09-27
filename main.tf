provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "null_resource" "packer_build" {
  provisioner "local-exec" {
    command = "packer build -var 'aws_region=us-east-1' -var 'source_ami=ami-0e86e20dae9224db8' -var 'instance_type=t2.micro' packer.pkr.hcl"
  }
}

