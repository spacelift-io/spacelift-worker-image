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

# Auth to Azure via the attached Spacelift Azure cloud integration, which injects
# ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID into the run.
provider "azurerm" {
  features {}

  # The integration's service principal is not granted rights to register resource
  # providers; the Test subscription already has Microsoft.Compute/Network registered.
  resource_provider_registrations = "none"
}
