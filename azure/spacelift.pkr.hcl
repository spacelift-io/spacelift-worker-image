variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
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
  default = null
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
  default = "West Europe"
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
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  managed_image_name                = var.image_name
  managed_image_resource_group_name = var.image_resource_group

  dynamic "shared_image_gallery_destination" {
    for_each = var.gallery_name != null ? [0] : []
    content {
      subscription         = var.subscription_id
      resource_group       = var.gallery_resource_group
      gallery_name         = var.gallery_name
      image_name           = var.gallery_image_name
      image_version        = var.gallery_image_version
      replication_regions  = var.gallery_replication_regions
    }
  }

  os_type = "Linux"

  image_publisher = var.source_image_publisher
  image_offer     = var.source_image_offer
  image_sku       = var.source_image_sku
  
  resource_group_name = var.packer_work_group

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
      "scripts/01-data-directories.sh",
      "scripts/02-apt.sh",
      "scripts/03-docker.sh",
      "scripts/04-gvisor.sh",
      "scripts/05-jq.sh",
      "scripts/06-azure-cli.sh",
    ]
  }

  # Deprovision VM
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
