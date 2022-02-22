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
