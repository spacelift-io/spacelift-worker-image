resource "spacelift_stack" "test" {
  name        = "ami-resilience-testing-azure"
  description = "Runs on the Azure worker pool to validate the Azure worker image before publish (ami-resilience). Bound to ami-build-resilience-workerpool-azure."

  repository = "ami-resilience-testing"
  branch     = "main"
  space_id   = "root"

  worker_pool_id = spacelift_worker_pool.this.id

  autodeploy = true
}
