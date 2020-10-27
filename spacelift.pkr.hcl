variable "base_ami" {
  type = string
}

source "amazon-ebs" "spacelift" {
  source_ami    = var.base_ami
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "spacelift"

  tags = {
    Name    = "Spacelift AMI"
    Purpose = "Spacelift"
    BaseAMI = var.base_ami
  }
}

build {
  sources = ["source.amazon-ebs.spacelift"]

  provisioner "shell" {
    inline = [
      "ls -la",
      "ps aux",
    ]
  }
}
