output "worker_pool_id" {
  value = spacelift_worker_pool.this.id
}

output "asg_name" {
  value = module.workerpool.autoscaling_group_name
}

# The ASG-refresh (cycle) role is a manual prerequisite in 259242304461:
#   arn:aws-us-gov:iam::259242304461:role/deployment-spacelift-worker-image
# Set that ARN as the repo secret consumed by the CI cycle step.
