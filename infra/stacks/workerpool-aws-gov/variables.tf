variable "ami_id" {
  type        = string
  description = "GovCloud AMI to launch workers from (built private in 092348861888, shared to this account). Injected at run time via TF_VAR_ami_id; never committed."
}

variable "gov_deployer_role_arn" {
  type        = string
  description = "ARN of the IAM role in 259242304461 that this Spacelift stack assumes via OIDC web identity to create the pool. Only used by the preferred (OIDC) auth design; leave unset when using the static-key fallback."
  default     = ""
}
