output "worker_pool_id" {
  value       = spacelift_worker_pool.this.id
  description = "The Spacelift worker pool ID."
}

output "resource_group" {
  value       = azurerm_resource_group.this.name
  description = "The resource group holding the VMSS."
}

# Consumed by the cycle step to reimage the scale set onto a new image.
output "vmss_name" {
  value       = module.azure-worker.vmss_name
  description = "The name of the Virtual Machine Scale Set."
}

output "vmss_id" {
  value       = module.azure-worker.vmss_id
  description = "The ID of the Virtual Machine Scale Set."
}
