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

# In-Spacelift runs use the auto-injected SPACELIFT_API_TOKEN, so no explicit
# credentials are needed here. The stack's role must allow managing worker pools.
provider "spacelift" {}

# eu-west-1: the private AMI under test is a regional resource in its owner account.
provider "aws" {
  region = "eu-west-1"
}
