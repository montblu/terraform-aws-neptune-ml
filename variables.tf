variable "resource_group_name" {
  description = <<-EOF
    A name to add as prefix or suffix created resources.
    For example environment, like `test` or `prod`, or company name.
    EOF
  type        = string
  nullable    = false
  default     = ""
}

variable "vpc_id" {
  description = <<-EOF
    The ID of the VPC to set up Neptune in.
    EOF
  type        = string
  nullable    = false
}

variable "vpc_endpoint_security_group_ids" {
  description = <<-EOF
    IDs of security groups allowed to access VPC endpoints.
    EOF
  type        = list(string)
  nullable    = false
  default     = []
}

variable "route_table_ids" {
  description = <<-EOF
    IDs of route tables to add to S3 VPC Endpoint.
    EOF
  type        = list(string)
  nullable    = false
  default     = []
}

variable "neptune_subnet_ids" {
  description = <<-EOF
    IDs of VPC subnets to set up Neptune ML resources in.
    EOF
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.neptune_subnet_ids) > 0
    error_message = "List must be non-empty."
  }
}

variable "extra_subnet_ids" {
  description = <<-EOF
    IDs of other subnets where requests to Neptune may originate from.
    EOF
  type        = list(string)
  nullable    = false
  default     = []
}

variable "kms_admin_user_names" {
  description = <<-EOF
    Names of additional IAM users that will be administrators of the
    KMS key. Not required, but strongly recommended. Root is always added.
    EOF
  type        = list(string)
  nullable    = false
  default     = []
}

variable "kms_admin_role_names" {
  description = <<-EOF
    Names of additional IAM roles that will be administrators of the
    KMS key. Not required, but strongly recommended. Root is always added.
    EOF
  type        = list(string)
  nullable    = false
  default     = []
}

variable "neptune_engine_version" {
  description = <<-EOF
    The version of the Neptune engine to run the cluster.
    EOF
  type        = string
  nullable    = false
  default     = "1.2.1.0"
}

variable "neptune_apply_immediately" {
  description = <<-EOF
    Whether or not to apply changes to Neptune immediately or wait for
    maintenance window.
    EOF
  type        = bool
  nullable    = false
  default     = false
}

variable "neptune_skip_final_snapshot" {
  description = <<-EOF
    Whether or not to skip taking a snapshot of the database before deletion.
    EOF
  type        = bool
  nullable    = false
  default     = false
}

variable "neptune_port" {
  description = <<-EOF
    The port which Neptune will expose.
    EOF
  type        = number
  nullable    = false
  default     = 8182
}

variable "neptune_backup_retention_period" {
  description = <<-EOF
    The days to retain backups for.
    EOF
  type        = number
  nullable    = false
  default     = 1
}

variable "neptune_backup_window" {
  description = <<-EOF
    Window of time to run backups of Neptune cluster.
    EOF
  type        = string
  nullable    = false
  default     = "07:00-09:00"
}

variable "neptune_allow_major_version_upgrade" {
  description = <<-EOF
    Whether or not to allow automatic major version upgrades of Neptune
    cluster.
    EOF
  type        = bool
  nullable    = false
  default     = true
}

variable "neptune_maintenance_window" {
  description = <<-EOF
    Window of time to run maintenance of Neptune cluster.
    EOF
  type        = string
  nullable    = false
  default     = "sat:22:00-sun:04:00"
}

variable "neptune_iam_authentication" {
  description = <<-EOF
    Whether or not enable IAM authentication for the Neptune cluster.
    EOF
  type        = bool
  nullable    = false
  default     = false
}

variable "neptune_storage_type" {
  description = <<-EOF
    storage_type - Storage type associated with the cluster `standard/iopt1`.
    EOF
  type        = string
  nullable    = false
  default     = "standard"
}

variable "serverless_min_capacity" {
  description = <<-EOF
    Minimum Neptune Capacity Units (NCUs) for serverless scaling configuration.
    EOF
  type        = number
  nullable    = false
  default     = 0
}

variable "serverless_max_capacity" {
  description = <<-EOF
    Maximum Neptune Capacity Units (NCUs) for serverless scaling configuration.
    EOF
  type        = number
  nullable    = false
  default     = 0
}

variable "database_instance_type" {
  description = <<-EOF
    Neptune DB instance type.
    EOF
  type        = string
  nullable    = false
  default     = "db.t3.medium"
}

variable "cluster_instance_count" {
  description = <<-EOF
    Number of instances to run in Neptune cluster.
    EOF
  type        = number
  nullable    = false
  default     = 1
}

variable "cluster_parameter_group" {
  # https://docs.aws.amazon.com/neptune/latest/userguide/parameters.html
  description = <<-EOF
    Configuration parameters for Neptune cluster as a map of string to any.
    EOF
  type        = map(any)
  nullable    = false
  default = {
    neptune_enable_audit_log   = 1
    neptune_lab_mode           = "NeptuneML=enabled"
    neptune_query_timeout      = 120000
    neptune_streams            = 0
    neptune_lookup_cache       = 1
    neptune_autoscaling_config = "{}"
  }
}

variable "instance_parameter_group" {
  # https://docs.aws.amazon.com/neptune/latest/userguide/parameters.html
  description = <<-EOF
    Configuration parameters for Neptune instances as a map of string to any.
    EOF
  type        = map(any)
  nullable    = false
  default = {
    neptune_dfe_query_engine = "viaQueryHint"
    neptune_query_timeout    = 120000
    neptune_result_cache     = 0
  }
}

variable "sagemaker_notebook_platform_id" {
  description = <<-EOF
    The platform ID of the SageMaker notebook.
    EOF
  type        = string
  nullable    = false
  default     = "notebook-al2-v2"
}

variable "sagemaker_notebook_instance_type" {
  description = <<-EOF
    The instance type of the SageMaker notebook.
    EOF
  type        = string
  nullable    = false
  default     = "ml.t3.medium"
}

variable "batch_compute_instance_types" {
  description = <<-EOF
    List of instance types to use for Batch compute environments.
    EOF
  type        = list(string)
  nullable    = false
  default = [
    "c5",
  ]
}

variable "create_iam_user" {
  description = <<-EOF
    Whether or not to create an IAM user with assumable role to access Neptune
    ML resources. If true, variable 'neptune_iam_authentication' should also be
    set to true, and variable 'pgp_key' should also be provided, otherwise the
    user's secret key will be stored in plain text in the Terraform state file.
    EOF
  type        = bool
  nullable    = false
  default     = false
}

variable "pgp_key" {
  description = <<-EOF
    For IAM user secret key. A base-64 encoded PGP public key, or a keybase
    username in the form keybase:some_person_that_exists. If PGP key, provide
    \"unarmored\" version (e.g. avoid passing the `-a` option to gpg `--export`).
    EOF
  type        = string
  nullable    = true
  default     = null
}

variable "tags" {
  description = <<-EOF
    Tags to add to resources.
    EOF
  type        = map(string)
  nullable    = false
  default     = {}
}
