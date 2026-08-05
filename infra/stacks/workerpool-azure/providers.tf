terraform {
  required_version = ">= 1.6"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.42"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# In-Spacelift runs use the auto-injected SPACELIFT_API_TOKEN, so no explicit
# credentials are needed. The stack's role must allow managing worker pools.
provider "spacelift" {}

# Auth to Azure via Spacelift OIDC federated into a user-assigned managed identity
# (a classic Azure cloud integration needs Entra admin consent, which we avoid).
# ARM_CLIENT_ID (the MI's client id), ARM_TENANT_ID and ARM_SUBSCRIPTION_ID are set
# as stack environment variables.
provider "azurerm" {
  features {}

  use_oidc             = true
  oidc_token_file_path = "/mnt/workspace/spacelift.oidc"

  # The managed identity is not granted rights to register resource providers;
  # the Test subscription already has Microsoft.Compute/Network registered.
  resource_provider_registrations = "none"
}
