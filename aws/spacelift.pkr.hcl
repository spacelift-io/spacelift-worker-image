variable "ami_name" {
  type    = string
  default = "kernel-5-spacelift-{{timestamp}}"
}

variable "ami_regions" {
  type = list(string)
  default = [
    "eu-west-1",
  ]
}

variable "base_ami" {
  type    = string
  default = null
}

variable "source_ami_filters" {
  type    = map(string)
  default = {
    virtualization-type = "hvm"
    name                = "amzn2-ami-kernel-5.10-hvm-2*-x86_64-gp2"
    root-device-type    = "ebs"
  }
}

variable "source_ami_owners" {
  type    = list(string)
  default = ["137112412989"] # defaults to Amazon for Amazon Linux, see https://docs.aws.amazon.com/AmazonECR/latest/userguide/amazon_linux_container_image.html
}

variable "source_ami_most_recent" {
  type    = bool
  default = true
}

variable "ami_groups" {
  type    = list(string)
  default = ["all"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "encrypt_boot" {
  type    = bool
  default = true
}

variable "shared_credentials_file" {
  type    = string
  default = null
}

variable "subnet_filter" {
  type    = map(string)
  default = null
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = null
}

source "amazon-ebs" "spacelift" {
  source_ami = var.base_ami

  dynamic "source_ami_filter" {
    for_each = var.base_ami == null ? [1] : []
    content {
      filters     = var.source_ami_filters
      owners      = var.source_ami_owners
      most_recent = var.source_ami_most_recent
    }
  }

  ami_name    = var.ami_name
  ami_regions = var.ami_regions
  ami_groups  = var.ami_groups

  shared_credentials_file = var.shared_credentials_file
  encrypt_boot            = var.encrypt_boot
  instance_type           = var.instance_type
  ssh_username            = "ec2-user"

  vpc_id = var.vpc_id
  region = var.region

  dynamic "subnet_filter" {
    for_each = var.subnet_filter == null ? [] : [1]
    content {
      filters = var.subnet_filter
      most_free = true
      random = false
    }
  }

  tags = merge(var.additional_tags, {
    Name      = "Spacelift AMI"
    Purpose   = "Spacelift"
    BaseAMI   = "{{ .SourceAMI }}"
  })
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
