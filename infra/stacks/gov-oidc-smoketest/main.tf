# Trivial GovCloud OIDC smoke test — creates NOTHING.
# Proves the Spacelift run federated into the gov account (identity + partition)
# and can make a real gov API call (DescribeRegions, via aws_regions).
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_regions" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id # expect 259242304461
}

output "partition" {
  value = data.aws_partition.current.partition # expect aws-us-gov
}

output "assumed_role_arn" {
  value = data.aws_caller_identity.current.arn # expect .../spacelift-ami-gov-deployer/...
}

output "gov_regions" {
  value = data.aws_regions.current.names # expect us-gov-east-1, us-gov-west-1
}
