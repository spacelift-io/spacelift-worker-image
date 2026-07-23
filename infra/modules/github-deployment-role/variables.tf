variable "role_name" {
  type        = string
  description = "Name of the IAM role (must be unique in the account)"
}

variable "repository" {
  type        = string
  description = "spacelift-io repository allowed to assume the role"
}

variable "refs" {
  type        = list(string)
  description = "Git references allowed to assume the role, e.g. ref:refs/heads/main"
}

variable "policy_document" {
  type        = string
  description = "JSON policy document granting the role's permissions"
}
