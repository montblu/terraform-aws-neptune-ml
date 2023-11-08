variable "lambda_name" {
  description = <<-EOF
    Name of the lambda to create.
    EOF
  type        = string
}

variable "lambda_handler" {
  description = <<-EOF
    Handler function of the lambda to create.
    EOF
  type        = string
}

variable "lambda_role_arn" {
  description = <<-EOF
    ARN of IAM role for the lambda to assume.
    EOF
  type        = string
}

variable "kms_key_arn" {
  description = <<-EOF
    ARN of KMS key used for encryption.
    EOF
  type        = string
}

variable "lambda_source_key" {
  description = <<-EOF
    Name of the S3 object containing the lambda source code.
    EOF
  type        = string
}

variable "environment_variables" {
  description = <<-EOF
    Environment variables for the lambda.
    EOF
  type        = map(any)
}

variable "permitted_api_gateway_arn" {
  description = <<-EOF
    ARN of API Gateway permitted to invoke the lambda.
    EOF
  type        = string
}

variable "tags" {
  description = <<-EOF
    Tags to add to resources.
    EOF
  type        = map(string)
}
