output "role_arn" {
  description = <<-EOF
    ARN of the IAM role
    EOF
  value       = aws_iam_role.this.arn
}

output "instance_profile_arn" {
  description = <<-EOF
    ARN of the IAM role's instance profile. Can be null
    EOF
  value       = var.with_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}
