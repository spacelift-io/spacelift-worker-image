# GCP Image

## Usage

### Build your own image

```shell
git clone git@github.com:spacelift-io/spacelift-worker-image.git
cd spacelift-worker-image
packer build gcp.pkr.hcl
```

Override the defaults using `-var="zone=europe-west1-d"`

The variables are located in the `gcp.pkr.hcl` file.

#### ARM64

Pass the arm64 variable set (the source image family, an ARM machine type, and a zone that
offers it — T2A exists in us-central1-a/b/f, europe-west4 and asia-southeast1; C4A is
Hyperdisk-only and won't work with the default build disk):

```shell
packer build \
  -var="arch=arm64" \
  -var="source_image_family=ubuntu-2404-lts-arm64" \
  -var="machine_type=t2a-standard-2" \
  -var="zone=us-central1-a" \
  gcp.pkr.hcl
```

### Consuming the images

- amd64 images: `spacelift-worker-<us|eu|asia>-<suffix>`, family `spacelift-worker`.
- arm64 images: `spacelift-worker-arm64-<us|eu|asia>-<suffix>`, family `spacelift-worker-arm64`.

The families are architecture-specific on purpose — never point an x86 machine type at the
arm64 family or vice versa. When using
[terraform-google-spacelift-workerpool](https://github.com/spacelift-io/terraform-google-spacelift-workerpool)
with an arm64 image, override `image` **and** `machine_type` together: the module default
(`e2-medium`) is x86-only, so pick an ARM machine type such as `t2a-standard-2`.
