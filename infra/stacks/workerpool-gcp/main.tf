resource "spacelift_worker_pool" "this" {
  name        = "ami-build-resilience-workerpool-gcp"
  description = "GCP MIG pool for validating Spacelift Worker images before they are published, driven by https://github.com/spacelift-io/spacelift-worker-image (ami-resilience). Autoscaler disabled."
  space_id    = "root" # else the API defaults the pool to the "legacy" space, invisible to a root stack
}

locals {
  mig_name = "ami-res-gcp-workers"
}

module "gcp-worker" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v2.0.0"

  image                       = var.image
  network                     = "default"
  region                      = var.region
  zone                        = var.zone
  size                        = 1
  project                     = var.project
  email                       = var.worker_service_account_email
  instance_group_manager_name = local.mig_name

  # Launcher is pulled from downloads.<domain_name>; preprod lives on spacelift.dev.
  domain_name = "spacelift.dev"

  configuration = <<-EOT
    export SPACELIFT_TOKEN=${spacelift_worker_pool.this.config}
    export SPACELIFT_POOL_PRIVATE_KEY=${spacelift_worker_pool.this.private_key}
    export SPACELIFT_WORKER_COMMS_PROTOCOL="poll"
    export SPACELIFT_WORKER_COMMS_URL="https://app.spacelift.dev"
    # Report the boot image as a worker metadata tag (gcp_image) so the rollout
    # workflow can assert, via the Spacelift API alone, that the cycled worker
    # actually booted from the image under test.
    export SPACELIFT_METADATA_gcp_image="$(curl -sf -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/image || true)"
  EOT

  providers = {
    google = google
  }

  # Workers have no external IP; they need NAT egress before they can register.
  depends_on = [google_compute_router_nat.this]
}
