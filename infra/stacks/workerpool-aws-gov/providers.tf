terraform {
  required_version = ">= 1.6"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.40.0"
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
# so it cannot reach GovCloud. Two viable auth paths instead:
#
#   PREFERRED — Spacelift OIDC federation (no long-lived keys). Register Spacelift
#     as an IAM OIDC provider in 259242304461 (issuer
#     https://spacelift-ci-gh.app.spacelift.dev, aud spacelift-ci-gh.app.spacelift.dev),
#     create a deployer role trusting it, and assume it via web identity below.
#     Same federation model GitHub OIDC already uses into this account.
#
#   FALLBACK — a dedicated IAM user with static access keys set as SECRET stack env
#     vars (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY). Guaranteed but long-lived.
#     NOT the console "Support" user (that's password + TOTP MFA, unusable by TF).
provider "aws" {
  region = "us-gov-west-1"

  # Design 2 (preferred). For the static-key fallback, delete this block and set
  # the AWS_* env vars on the stack instead.
  assume_role_with_web_identity {
    role_arn                = var.gov_deployer_role_arn
    web_identity_token_file = "/mnt/workspace/spacelift.oidc"
    session_name            = "spacelift-ami-gov-testpool"
  }
}
