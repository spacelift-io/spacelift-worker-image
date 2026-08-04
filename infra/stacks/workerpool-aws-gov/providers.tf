terraform {
  required_version = ">= 1.6"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
    aws = {
      source = "hashicorp/aws"
      # >= 6.40, < 7.0 — the autoscaling submodule (v9.3.0) requires aws >= 6.56.0,
      # which the tighter "~> 6.40.0" (< 6.41.0) cap would exclude on a fresh init.
      version = "~> 6.40"
    }
  }
}

# Manages the worker pool in commercial preprod. In-Spacelift runs use the
# auto-injected SPACELIFT_API_TOKEN; the stack's role must allow managing worker pools.
provider "spacelift" {}

# GovCloud test account 259242304461, us-gov-west-1.
#
# The standard Spacelift AWS cloud integration assumes a role FROM Spacelift's
# commercial account (324880187172); cross-partition sts:AssumeRole is unsupported,
# so it cannot reach GovCloud.
# Uses Spacelift OIDC federation (no long-lived keys). Register Spacelift
# as an IAM OIDC provider in 259242304461 (issuerhttps://spacelift-ci-gh.app.spacelift.dev)
# create a deployer role trusting it, and assume it via web identity below.
provider "aws" {
  region = "us-gov-west-1"

  assume_role_with_web_identity {
    role_arn                = var.gov_deployer_role_arn
    web_identity_token_file = "/mnt/workspace/spacelift.oidc"
    session_name            = "spacelift-ami-gov-testpool"
  }
}
