# Azure Image

## Usage

### Build your own image

```shell
git clone git@github.com:spacelift-io/spacelift-worker-image.git
cd spacelift-worker-image/azure
packer build spacelift.pkr.hcl
```

Override the defaults using `-var="location=westeurope"`

The variables are located in the `spacelift.pkr.hcl` file.
