resource "spacelift_stack" "test" {
  name        = "ami-resilience-testing-gcp"
  description = "Runs on the GCP worker pool to validate the GCP worker image before publish (ami-resilience). Bound to ami-build-resilience-workerpool-gcp."

  repository = "ami-resilience-testing"
  branch     = "main"
  space_id   = "root"

  worker_pool_id = spacelift_worker_pool.this.id

  autodeploy = true
}
