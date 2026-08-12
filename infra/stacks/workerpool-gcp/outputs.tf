output "worker_pool_id" {
  value       = spacelift_worker_pool.this.id
  description = "The Spacelift worker pool ID."
}

# Consumed by the workflow's verify step (gcloud needs the MIG name + location).
# The module exposes no outputs, so we surface the values we pass in.
output "instance_group_manager_name" {
  value       = local.mig_name
  description = "Name of the zonal managed instance group backing the pool."
}

output "zone" {
  value       = var.zone
  description = "Zone of the managed instance group."
}

output "project" {
  value       = var.project
  description = "GCP project hosting the test pool."
}
