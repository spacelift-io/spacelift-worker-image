# The module attaches no access_config to the instance template, so the workers
# have no external IP. They are egress-only (pull from Spacelift + downloads.spacelift.dev),
# so we give the default network Cloud NAT for outbound. Mirrors the module's
# examples/default-network test case.
resource "google_compute_router" "this" {
  name    = "ami-res-gcp-router"
  region  = var.region
  network = "default"
  project = var.project

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "this" {
  name                               = "ami-res-gcp-nat"
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
