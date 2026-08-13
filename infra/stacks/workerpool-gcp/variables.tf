variable "image" {
  type        = string
  description = <<-EOT
    Full path of the worker image the pool boots, e.g.
    projects/spacelift-workers/global/images/spacelift-worker-us-<suffix>.
    Required — the rollout workflow pins the just-built image per run (and it is
    persisted on the stack env). Intentionally no family "latest" default: that
    lookup would 403 reading a still-private newest-in-family image during the gate.
  EOT
}

variable "project" {
  type        = string
  description = "GCP project that hosts the test worker pool. TODO confirm — the module's own tests use 'spacelift-development'."
  default     = "spacelift-development"
}

variable "region" {
  type        = string
  description = "GCP region for the test pool (Cloud Router / NAT are regional)."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone for the (zonal) managed instance group."
  default     = "us-central1-a"
}

variable "worker_service_account_email" {
  type        = string
  description = "Service account the worker VMs run as. TODO confirm for the chosen test project."
  default     = "spacelift-test-worker@spacelift-development.iam.gserviceaccount.com"
}
