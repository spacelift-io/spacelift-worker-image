resource "spacelift_worker_pool" "this" {
  name        = "ami-build-resilience-workerpool-gcp-arm64"
  description = "GCP ARM64 (T2A) MIG pool for validating arm64 Spacelift Worker images before they are published, driven by https://github.com/spacelift-io/spacelift-worker-image (ami-resilience). Autoscaler disabled."
  space_id    = "root" # else the API defaults the pool to the "legacy" space, invisible to a root stack
}

# Egress: the workers get no external IP, so they need Cloud NAT to reach Spacelift
# and downloads.spacelift.dev. This stack deliberately does NOT create its own router/NAT:
# GCP allows only one NAT with ALL_SUBNETWORKS_ALL_IP_RANGES per network+region, and the
# x86_64 pool (workerpool-gcp) already owns `ami-res-gcp-nat` on default/us-central1, which
# covers these workers too. A second one is rejected with
#   "Can not create new Nats since a Nat with option ALL_SUBNETWORKS_ALL_IP_RANGES exists".
# Moving this pool to another region would let it own its own NAT again.
locals {
  mig_name = "ami-res-gcp-arm64-workers"
}

module "gcp-worker" {
  source = "github.com/spacelift-io/terraform-google-spacelift-workerpool?ref=v2.0.0"

  image = var.image
  # The module default (e2-medium) is x86-only; an ARM64 image can't boot on it.
  # T2A is the ARM series that works with the module's default Persistent Disk
  # (C4A is Hyperdisk-only) and is offered in us-central1-a.
  machine_type                = "t2a-standard-1"
  network                     = "default"
  region                      = var.region
  zone                        = var.zone
  size                        = 1
  project                     = var.project
  email                       = var.worker_service_account_email
  instance_group_manager_name = local.mig_name

  # Launcher is pulled from downloads.<domain_name>; preprod lives on spacelift.dev.
  # The module's startup script downloads spacelift-launcher-$(uname -m), so ARM
  # workers fetch the aarch64 binary automatically.
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
}
