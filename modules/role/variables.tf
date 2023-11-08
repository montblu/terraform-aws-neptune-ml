variable "role_name" {
  description = <<-EOF
    Name of the IAM role.
    EOF
  type        = string
  nullable    = false
}

variable "statements" {
  description = <<-EOF
    Actions and resources allowed by the IAM role.
    EOF
  type = list(object({
    actions   = list(string)
    resources = list(string)
    conditions = list(object({
      test     = string
      variable = string
      values   = list(string)
    }))
  }))
  nullable = false
  default  = []
}

variable "aws_managed_policy_name" {
  description = <<-EOF
    Name of AWS managed policy to attach to the role.
    EOF
  type        = string
  nullable    = false
  default     = ""
}

variable "principal_type" {
  description = <<-EOF
    Type of principal for IAM trust policy.
    EOF
  type        = string
  default     = "Service"
  nullable    = false
}

variable "principal_identifiers" {
  description = <<-EOF
    Identifiers of a principal type for IAM trust policy.
    EOF
  type        = list(string)
  nullable    = false
}

variable "with_instance_profile" {
  description = <<-EOF
    Whether or not to also an create an instance profile for this IAM role.
    EOF
  type        = bool
  default     = false
}

variable "tags" {
  description = <<-EOF
    Tags to add to resources.
    EOF
  type        = map(string)
}
