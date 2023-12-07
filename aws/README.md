# AWS Image

## Usage

### Use an official AMI

Find the latest AMIs in the [releases](https://github.com/spacelift-io/spacelift-worker-image/releases) section

#### awscli

Use the `awscli` to get the latest AMI

```shell
aws ec2 describe-images \
  --owners 643313122712 \
  --filters "Name=name,Values=spacelift-*" "Name=architecture,Values=x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1]'
```

Architecture could be either `x86_64` or `arm64`.

#### Terraform

Use a terraform data source to retrieve the latest AMI

```hcl
provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "spacelift" {
  most_recent      = true
  owners           = ["643313122712"] # spacelift owner

  filter {
    name   = "name"
    values = ["spacelift-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami" {
  value = data.aws_ami.spacelift.image_id
}
```

### Build your own AMI

```shell
git clone git@github.com:spacelift-io/spacelift-worker-image.git
cd spacelift-worker-image
packer build aws.pkr.hcl
```

Override the defaults using `-var="region=us-east-2"`

The variables are located in the `aws.pkr.hcl` file.
