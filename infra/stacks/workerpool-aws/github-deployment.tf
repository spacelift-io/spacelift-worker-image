module "github-deployment" {
  source = "../../modules/github-deployment-role"

  role_name  = "github-deployment-spacelift-worker-image-workerpool"
  repository = "spacelift-worker-image"

  refs = ["ref:refs/heads/main", "pull_request", "ref:refs/heads/wojciechp/*"]

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["autoscaling:StartInstanceRefresh"]
        Resource = [module.workerpool.autoscaling_group_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeInstanceRefreshes",
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeLaunchTemplateVersions",
        ]
        Resource = "*"
      },
    ]
  })
}
