output "worker_pool_id" {
  value = spacelift_worker_pool.this.id
}

output "asg_name" {
  value = module.workerpool.autoscaling_group_name
}

# ARN of the GitHub Actions OIDC role for the ASG-refresh (cycle) step.
# Set as the repo secret PRIVATE_WORKER_POOL_AWS_ROLE_TO_ASSUME.
output "cycle_role_arn" {
  value = module.github-deployment.role_arn
}
