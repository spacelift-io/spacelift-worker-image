variable "image" {
  type        = string
  description = <<-EOT
    Full self-link/path of the worker image under test. Override per run (the
    workflow pins the just-built image). When null, defaults to the latest
    non-deprecated image in the public 'spacelift-worker' family.
  EOT
  default     = null
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
