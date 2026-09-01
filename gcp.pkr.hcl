packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "credentials_json" {
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
  default = "ubuntu-2404-lts-amd64"
}

variable "arch" {
  type        = string
  default     = "x86_64"
  description = "Target image architecture. Must match source_image_family and machine_type; stamps the produced image's architecture field and names the manifest file."

  validation {
    condition     = contains(["x86_64", "arm64"], var.arch)
    error_message = "The arch must be x86_64 or arm64."
  }
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

source "googlecompute" "spacelift" {
  project_id                = var.project_id
  source_image_family       = var.source_image_family
  ssh_username              = "spacelift"
  ssh_clear_authorized_keys = true
  zone                      = var.zone
  disk_size                 = 50
  machine_type              = var.machine_type
  credentials_json          = var.credentials_json

  image_name              = "${var.image_base_name}-${var.image_storage_location}-${var.suffix}"
  image_family            = var.image_family
  image_storage_locations = [var.image_storage_location]
  # GCE inherits the architecture from the source disk when unset, but plugin 1.1.5
  # once regressed that default (hashicorp/packer-plugin-googlecompute#232) and the
  # plugin version floats (~> 1), so stamp it explicitly.
  image_architecture = var.arch
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

    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }
  }

  post-processor "manifest" {
    output = "manifest_gcp_${var.arch}.json"
  }
}
