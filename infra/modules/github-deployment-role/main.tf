# GitHub Actions OIDC deployment role.
#
# Lets GitHub Actions workflows in the given spacelift-io repository assume an
# IAM role in this account via the GitHub OIDC provider, restricted to the
# given git refs.

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "this" {
  name        = var.role_name
  description = "Role for GitHub Actions deployments from spacelift-io/${var.repository}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [for ref in var.refs : "repo:spacelift-io/${var.repository}:${ref}"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "this" {
  name        = "${var.role_name}-policy"
  description = "Policy for ${var.role_name}"

  policy = var.policy_document
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
