terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.40.0"
    }
  }
}

# Assumes the GovCloud deployer role via Spacelift's per-run OIDC token. If this
# authenticates, Spacelift OIDC -> GovCloud works and the real pool stack can use
# the same pattern. No AWS cloud integration must be attached to this stack.
provider "aws" {
  region = "us-gov-west-1"

  assume_role_with_web_identity {
    role_arn                = var.gov_deployer_role_arn
    web_identity_token_file = "/mnt/workspace/spacelift.oidc"
    session_name            = "spacelift-gov-oidc-smoketest"
  }
}

variable "gov_deployer_role_arn" {
  type        = string
  description = "ARN of the deployer role in 259242304461 (e.g. arn:aws-us-gov:iam::259242304461:role/spacelift-ami-gov-deployer). Set via TF_VAR_gov_deployer_role_arn."
}
