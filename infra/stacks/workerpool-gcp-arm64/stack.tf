resource "spacelift_stack" "test" {
  name        = "ami-resilience-testing-gcp-arm64"
  description = "Runs on the GCP arm64 worker pool to validate the arm64 GCP worker image before publish (ami-resilience). Bound to ami-build-resilience-workerpool-gcp-arm64."

  repository = "ami-resilience-testing"
  branch     = "main"
  space_id   = "root"

  worker_pool_id = spacelift_worker_pool.this.id

  autodeploy = true
}
