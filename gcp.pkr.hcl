variable "account_file" {
  type    = string
  default = null
}

variable "project_id" {
  type    = string
  default = null
}

variable "image_base_name" {
  type    = string
  default = "spacelift-private-worker"
}

variable "image_family" {
  type    = string
  default = "spacelift-private-worker"
}

variable "image_storage_location" {
  type    = string
  default = "us"
}

variable "source_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "source_image" {
  type    = string
  default = null
}

variable "suffix" {
  type    = string
  description = "A suffix to add to image names to ensure each version is unique. For example a timestamp or version number."
}

variable "machine_type" {
  type    = string
  default = "n1-standard-2"
}

variable "additional_labels" {
  type    = map(string)
  default = {}
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

locals {
  # Input could be "ubuntu-2004-lts" or "ubuntu-2004-lts-arm64"
  # Output should be x64 or arm64
  image_architecture = replace(replace(var.source_image_family, "ubuntu-2004-lts-arm64", "arm64"), "ubuntu-2004-lts", "x64")
    
}

source "googlecompute" "spacelift" {
  project_id          = var.project_id
  source_image_family = var.source_image_family
  source_image        = var.source_image
  ssh_username        = "spacelift"
  zone                = var.zone
  disk_size           = 50
  machine_type        = var.machine_type
  account_file        = var.account_file

  image_name              = "${var.image_base_name}-${var.image_storage_location}-${var.suffix}-${local.image_architecture}"
  image_family            = var.image_family
  image_storage_locations = [var.image_storage_location]
}

build {
  sources = ["source.googlecompute.spacelift"]

  provisioner "shell" {
    scripts = [
      "shared/scripts/data-directories.sh",
      "shared/scripts/apt-update.sh",
      "shared/scripts/apt-install-docker.sh",
      "shared/scripts/gvisor.sh",
      "shared/scripts/apt-install-jq.sh",
    ]
  }
}
