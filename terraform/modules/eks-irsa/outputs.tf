output "role_id" {
  description = "The role id"
  value       = aws_iam_role.role.id
}

output "role_arn" {
  description = "The role ARN"
  value       = aws_iam_role.role.arn
}