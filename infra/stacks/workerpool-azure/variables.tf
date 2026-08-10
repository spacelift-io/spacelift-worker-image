variable "source_image_id" {
  type        = string
  description = "Gallery image version under test. Override per run (the workflow pins the just-built version); defaults to the current ubu_lts line's latest. NOTE: the actively-built definition is spacelift_worker_image_ubu_lts (3.0.x), not the stale spacelift_worker_image (2.0.x)."
  default     = "/communityGalleries/spacelift-40913cda-9bf9-4bcb-bf90-78fd83f30079/images/spacelift_worker_image_ubu_lts/versions/latest"
}

variable "location" {
  type        = string
  description = "Azure region for the test pool."
  default     = "westeurope"
}
