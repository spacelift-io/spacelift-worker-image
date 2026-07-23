resource "spacelift_worker_pool" "this" {
  name        = "ami-build-resilience-workerpool"
  description = "EC2 pool for AMI validation (ami-resilience). Autoscaler disabled."
  space_id    = "root" # else the API defaults the pool to the "legacy" space, invisible to a root stack
}

module "workerpool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v7.2.0"

  binaries_download_base_url = "https://downloads.spacelift.dev"
  base_name                  = "ci-workerpool-aws"
  worker_pool_id             = spacelift_worker_pool.this.id
  ec2_instance_type          = "t3.small"
  ami_id                     = var.ami_id
  min_size                   = 1
  max_size                   = 2
  vpc_subnets                = data.aws_subnets.default.ids
  security_groups            = [data.aws_security_group.default.id]

  manage_log_groups = false

  env_vars = {
    SPACELIFT_TOKEN                 = { value = spacelift_worker_pool.this.config, sensitive = true }
    SPACELIFT_POOL_PRIVATE_KEY      = { value = spacelift_worker_pool.this.private_key, sensitive = true }
    SPACELIFT_WORKER_COMMS_URL      = { value = "https://app.spacelift.dev" }
    SPACELIFT_WORKER_COMMS_PROTOCOL = { value = "poll" }
  }
}
