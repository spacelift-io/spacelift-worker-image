output "worker_pool_id" {
  value = spacelift_worker_pool.this.id
}

output "asg_name" {
  value = module.workerpool.autoscaling_group_name
}

output "test_stack_id" {
  value = spacelift_stack.test.id
}