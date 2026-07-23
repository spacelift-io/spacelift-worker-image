variable "ami_id" {
  type        = string
  description = "AMI to launch workers from. Injected at run time via TF_VAR_ami_id; never committed."
}
