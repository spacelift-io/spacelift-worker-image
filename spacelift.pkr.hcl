variable "ami_regions" {
  type = list(string)
  default = [
    "us-east-1",
    "ap-southeast-1",
    "eu-central-1",
    "eu-west-1",
  ]
}

variable "base_ami" {
  type = string
}

source "amazon-ebs" "spacelift" {
  source_ami = var.base_ami

  instance_type = "t2.micro"
  ssh_username  = "ec2-user"

  ami_name    = "spacelift-{{timestamp}}"
  ami_regions = var.ami_regions
  ami_groups  = ["all"]

  tags = {
    Name    = "Spacelift AMI"
    Purpose = "Spacelift"
    BaseAMI = var.base_ami
  }
}

build {
  sources = ["source.amazon-ebs.spacelift"]

  provisioner "file" {
    source      = "configs/"
    destination = "/tmp"
  }

  provisioner "shell" {
    scripts = [
      "scripts/01-data-directories.sh",
      "scripts/02-yum.sh",
      "scripts/03-docker.sh",
      "scripts/04-gvisor.sh",
      "scripts/05-cloudwatch-agent.sh",
      "scripts/06-jq.sh",
    ]
  }
}
