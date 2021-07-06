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

### Shared Image Gallery

By default, the template creates a Managed image in the resource group defined by the `image_resource_group`
variable. The image can optionally be published to a shared image gallery by setting the `gallery_*`
variables.
