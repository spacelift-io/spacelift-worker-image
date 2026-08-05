variable "source_image_id" {
  type        = string
  description = "Gallery image version under test. Override per run; defaults to the current community-gallery latest."
  default     = "/communityGalleries/spacelift-40913cda-9bf9-4bcb-bf90-78fd83f30079/images/spacelift_worker_image/versions/latest"
}

variable "location" {
  type        = string
  description = "Azure region for the test pool."
  default     = "westeurope"
}
