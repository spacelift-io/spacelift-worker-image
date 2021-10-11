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
  default = null
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

source "googlecompute" "spacelift" {
  project_id          = var.project_id
  source_image_family = var.source_image_family
  source_image        = var.source_image
  ssh_username        = "spacelift"
  zone                = var.zone
  disk_size           = 50
  machine_type        = var.machine_type
  account_file        = var.account_file

  image_name              = "${var.image_base_name}-${var.image_storage_location}-{{var.suffix}}"
  image_family            = var.image_family
  image_storage_locations = [var.image_storage_location]
}

build {
  sources = ["source.googlecompute.spacelift"]

  provisioner "shell" {
    scripts = [
      "scripts/01-data-directories.sh",
      "scripts/02-apt.sh",
      "scripts/03-docker.sh",
      "scripts/04-gvisor.sh",
      "scripts/05-jq.sh",
    ]
  }
}
