resource "spacelift_worker_pool" "this" {
  name        = "ami-build-resilience-workerpool-azure"
  description = "Azure VMSS pool for validating Spacelift Worker images before they are published, driven by https://github.com/spacelift-io/spacelift-worker-image (ami-resilience). Autoscaler disabled."
  space_id    = "root" # else the API defaults the pool to the "legacy" space, invisible to a root stack
}

module "azure-worker" {
  source = "github.com/spacelift-io/terraform-azure-spacelift-workerpool?ref=v3.0.0"

  resource_group   = azurerm_resource_group.this
  subnet_id        = azurerm_subnet.worker.id
  identity_type    = "SystemAssigned"
  admin_public_key = base64encode(tls_private_key.admin.public_key_openssh)

  worker_pool_id  = spacelift_worker_pool.this.id
  source_image_id = var.source_image_id # image under test; defaults to community-gallery latest

  non_autoscaled_vmss_instances = 1
  vmss_sku                      = "Standard_B2S"
  name_prefix                   = "ami-res-azure"

  # Launcher is pulled from downloads.<domain_name>; preprod lives on spacelift.dev.
  domain_name = "spacelift.dev"

  process_exit_behavior = "Reboot"

  # Skip apt unattended-upgrade on boot: it adds minutes to every boot, which slows
  # the reimage/cycle step in the test gate. The image under test is what we validate.
  perform_unattended_upgrade_on_boot = false

  configuration = <<-EOT
    export SPACELIFT_TOKEN=${spacelift_worker_pool.this.config}
    export SPACELIFT_POOL_PRIVATE_KEY=${spacelift_worker_pool.this.private_key}
    export SPACELIFT_WORKER_COMMS_PROTOCOL="poll"
    export SPACELIFT_WORKER_COMMS_URL="https://app.spacelift.dev"
    # Self-report the booted image version as a worker metadata tag (like GCP's gcp_image), so the
    # test gate can assert the worker actually booted the image under test. `exactVersion` resolves
    # "latest" to the concrete gallery version (e.g. 3.0.122); needs IMDS api-version >= 2023-07-01.
    export SPACELIFT_METADATA_image_version="$(curl -s -H Metadata:true --noproxy '*' 'http://169.254.169.254/metadata/instance/compute/storageProfile/imageReference?api-version=2023-07-01' | jq -r '.exactVersion // "unknown"')"
  EOT

  tags = {
    purpose = "ami-resilience-azure-test"
  }
}
