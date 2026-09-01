# The module attaches no access_config to the instance template, so the workers
# have no external IP. They are egress-only (pull from Spacelift + downloads.spacelift.dev),
# so we give the default network Cloud NAT for outbound.
#
# Deliberately duplicated from workerpool-gcp (with renamed resources) rather than
# shared: the two stacks must never depend on each other's state, so an arm64-side
# apply failure can never break the amd64 publish gate (and vice versa).
resource "google_compute_router" "this" {
  name    = "ami-res-gcp-arm64-router"
  region  = var.region
  network = "default"
  project = var.project

  bgp {
    asn = 64515
  }
}

resource "google_compute_router_nat" "this" {
  name                               = "ami-res-gcp-arm64-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  project                            = var.project
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
