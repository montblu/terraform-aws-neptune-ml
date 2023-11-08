output "arn" {
  description = <<-EOF
    ARN of lambda
    EOF
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = <<-EOF
    ARN for invoking lambda from API Gateway
    EOF
  value       = aws_lambda_function.this.invoke_arn
}
