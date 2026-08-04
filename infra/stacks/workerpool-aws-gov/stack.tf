resource "spacelift_stack" "test" {
  name        = "ami-resilience-testing-gov-aws"
  description = "Runs on the GovCloud AMI test pool to validate the gov worker image before publish (ami-resilience). Bound to ami-build-resilience-workerpool-gov."

  repository = "ami-resilience-testing"
  branch     = "main"
  space_id   = "root"

  worker_pool_id = spacelift_worker_pool.this.id

  autodeploy = true
}
