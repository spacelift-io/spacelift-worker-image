# spacelift-worker-image
Building Spacelift-friendly image for private workers

## Usage

```
git clone git@github.com:spacelift-io/spacelift-worker-image.git
cd spacelift-worker-image
packer build spacelift.pkr.hcl
```

Override the defaults using `-var="region=us-east-2"`

The variables are located in the `spacelift.pkr.hcl` file.
