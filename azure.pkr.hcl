packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable "client_id" {
  type    = string
  default = ""
}

variable "oidc_request_url" {
  type    = string
  default = env("ACTIONS_ID_TOKEN_REQUEST_URL") // Github built-in variable
}

variable "oidc_request_token" {
  type    = string
  default = env("ACTIONS_ID_TOKEN_REQUEST_TOKEN") // Github built-in variable
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "image_name" {
  type    = string
  default = "spacelift-{{ timestamp }}"
}

variable "image_resource_group" {
  type = string
}

variable "gallery_resource_group" {
  type    = string
  default = null
}

variable "gallery_name" {
  type    = string
}

variable "gallery_image_name" {
  type    = string
  default = null
}

variable "gallery_image_version" {
  type    = string
  default = null
}

variable "gallery_replication_regions" {
  type    = list(string)
  default = null
}

variable "source_image_publisher" {
  type    = string
  default = "Canonical"
}

variable "source_image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-focal-daily"
}

variable "source_image_sku" {
  type    = string
  default = "20_04-daily-lts-gen2"
}

variable "location" {
  type    = string
  default = ""
}

variable "vm_size" {
  type    = string
  default = "Standard_B2S"
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}

variable "packer_work_group" {
  type        = string
  default     = ""
  description = "The resource group for Packer to use while building the VM"
}

source "azure-arm" "spacelift" {
  client_id          = var.client_id
  subscription_id    = var.subscription_id
  tenant_id          = var.tenant_id
  oidc_request_url   = var.oidc_request_url
  oidc_request_token = var.oidc_request_token

  managed_image_name                = var.image_name
  managed_image_resource_group_name = var.image_resource_group

  shared_image_gallery_destination {
    subscription         = var.subscription_id
    resource_group       = var.gallery_resource_group
    gallery_name         = var.gallery_name
    image_name           = var.gallery_image_name
    image_version        = var.gallery_image_version

    target_region {
      name = var.location
    }

    dynamic target_region {
      for_each = var.gallery_replication_regions

      content {
        name = target_region.value
      }
    }
  }

  os_type = "Linux"

  image_publisher = var.source_image_publisher
  image_offer     = var.source_image_offer
  image_sku       = var.source_image_sku
  
  build_resource_group_name = var.packer_work_group

  location = var.location
  vm_size  = var.vm_size

  azure_tags = merge(var.additional_tags, {
    Name                 = "Spacelift Worker Image"
    SourceImagePublisher = var.source_image_publisher
    SourceImageOffer     = var.source_image_offer
    SourceImageSku       = var.source_image_sku
    CreatedAt            = "{{ timestamp }}"
  })
}

build {
  sources = ["source.azure-arm.spacelift"]

  provisioner "shell" {
    scripts = [
      "shared/scripts/data-directories.sh",
      "shared/scripts/apt-update.sh",
      "shared/scripts/apt-install-docker.sh",
      "shared/scripts/gvisor.sh",
      "shared/scripts/apt-install-jq.sh",
      "azure/scripts/azure-cli.sh",
    ]

    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }
  }

  # Deprovision VM
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }

  post-processor "manifest" {
    output = "manifest_azure.json"
  }
}
