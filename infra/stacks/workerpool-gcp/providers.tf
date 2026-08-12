terraform {
  required_version = ">= 1.6"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# In-Spacelift runs use the auto-injected SPACELIFT_API_TOKEN, so no explicit
# credentials are needed. The stack's role must allow managing worker pools.
provider "spacelift" {}

# Auth to GCP via the attached Spacelift GCP cloud integration, which injects a
# short-lived GOOGLE_OAUTH_ACCESS_TOKEN into the run (the same mechanism the
# module's own registry tests use). The integration's service account must be able
# to manage Compute Engine (instance templates, MIGs, routers/NAT) in var.project.
provider "google" {
  project = var.project
  region  = var.region
}
