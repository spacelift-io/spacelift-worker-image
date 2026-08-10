terraform {
  required_version = ">= 1.6"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.56"
    }
  }
}

provider "spacelift" {}


# The standard Spacelift AWS cloud integration assumes a role FROM Spacelift's
# commercial account; cross-partition sts:AssumeRole is unsupported,
# so it cannot reach GovCloud.
# Uses Spacelift OIDC federation (no long-lived keys).
provider "aws" {
  region = "us-gov-west-1"

  assume_role_with_web_identity {
    role_arn                = var.gov_deployer_role_arn
    web_identity_token_file = "/mnt/workspace/spacelift.oidc"
    session_name            = "spacelift-ami-gov-testpool"
  }
}
