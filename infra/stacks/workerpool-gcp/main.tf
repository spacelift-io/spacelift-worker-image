resource "spacelift_worker_pool" "this" {
  name        = "ami-build-resilience-workerpool-gcp"
  description = "GCP MIG pool for validating Spacelift Worker images before they are published, driven by https://github.com/spacelift-io/spacelift-worker-image (ami-resilience). Autoscaler disabled."
  space_id    = "root" # else the API defaults the pool to the "legacy" space, invisible to a root stack
}

# Default to the latest public worker image when the workflow has not pinned one.
# The images are public (allAuthenticatedUsers imageUser), so the run's integration
# SA can read the family. NOTE: cross-project read of spacelift-workers is assumed;
# if the run SA lacks it, pin var.image instead.
data "google_compute_image" "latest" {
  family  = "spacelift-worker"
  project = "spacelift-workers"
}

locals {
  image    = coalesce(var.image, data.google_compute_image.latest.self_link)
  mig_name = "ami-res-gcp-workers"
}

module "gcp-worker" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v2.0.0"

  image                       = local.image
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
  EOT

  providers = {
    google = google
  }

  # Workers have no external IP; they need NAT egress before they can register.
  depends_on = [google_compute_router_nat.this]
}
