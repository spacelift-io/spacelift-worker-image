# Networking: default VPC in the GovCloud test account (259242304461), us-gov-west-1.
# The default VPC has an internet gateway, giving workers the outbound path they
# need to reach commercial preprod (app.spacelift.dev) over the public internet.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}
