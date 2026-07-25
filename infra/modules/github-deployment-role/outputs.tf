output "role_arn" {
  description = "ARN of the deployment role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the deployment role"
  value       = aws_iam_role.this.name
}
