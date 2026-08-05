variable "ami_id" {
  type        = string
  description = "GovCloud AMI to launch workers from."
}

variable "gov_deployer_role_arn" {
  type        = string
  description = "ARN of the IAM role in Gov Test account that this Spacelift stack assumes via OIDC web identity to create the pool."
  default     = ""
}
