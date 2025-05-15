data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

data "aws_subnet" "extra" {
  count = length(var.extra_subnet_ids)
  id    = var.extra_subnet_ids[count.index]
}

data "aws_iam_user" "admin" {
  count     = length(var.kms_admin_user_names)
  user_name = var.kms_admin_user_names[count.index]
}

data "aws_iam_role" "admin" {
  count = length(var.kms_admin_role_names)
  name  = var.kms_admin_role_names[count.index]
}

data "aws_kms_key" "s3" {
  count  = var.create_kms_key ? 0 : 1
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "rds" {
  count  = var.create_kms_key ? 0 : 1
  key_id = "alias/aws/rds"
}

data "aws_kms_key" "lambda" {
  count  = var.create_kms_key ? 0 : 1
  key_id = "alias/aws/lambda"
}
