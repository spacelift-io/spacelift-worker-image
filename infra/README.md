# Test infrastructure

Terraform for the **validation pipeline** — the throwaway worker pools and test stacks that gate
image publishing. See [../docs/build-test-publish.md](../docs/build-test-publish.md) for how the
pipeline works.

Everything here is deployed on the preprod Spacelift instance `spacelift-ci-gh.app.spacelift.dev`.

## Layout

```
stacks/
  workerpool-aws/      EC2 test worker pool (ami-build-resilience-workerpool)
  workerpool-aws-gov/  GovCloud test worker pool
  workerpool-azure/    Azure VMSS test worker pool
  workerpool-gcp/      GCP MIG test worker pool (x86_64)
  workerpool-gcp-arm64/ GCP MIG test worker pool (arm64, T2A)
modules/
  github-deployment-role/  GitHub-OIDC IAM role used by CI to cycle a pool
```

Each `workerpool-*` stack creates a `spacelift_worker_pool` and
brings up the pool via the cloud's `terraform-*-spacelift-workerpool` module. The image under test
is injected at run time (`TF_VAR_ami_id` / `TF_VAR_image`) — never committed — so the pipeline can
point the pool at a freshly built, still-private image.
