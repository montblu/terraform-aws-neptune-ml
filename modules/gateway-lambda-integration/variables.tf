variable "rest_api_id" {
  description = <<-EOF
    ID of the associated REST API.
    EOF
  type        = string
}

variable "parent_id" {
  description = <<-EOF
    ID of the parent API resource.
    EOF
  type        = string
}

variable "path_part" {
  description = <<-EOF
    Last path segment of this API resource.
    EOF
  type        = string
}

variable "lambda_invoke_arn" {
  description = <<-EOF
    ARN of Lambda invocation.
    EOF
  type        = string
}
