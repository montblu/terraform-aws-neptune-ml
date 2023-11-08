output "kms_key_arn" {
  description = <<-EOF
    ARN of KMS key used for encrypting data created by Neptune ML resources
    EOF
  value       = aws_kms_key.neptune.arn
}

output "s3_bucket_name" {
  description = <<-EOF
    Name of S3 bucket for loading data into Neptune
    EOF
  value       = aws_s3_bucket.neptune.bucket
}

output "neptune_cluster_id" {
  description = <<-EOF
    ID of the Neptune cluster
    EOF
  value       = aws_neptune_cluster.neptune.id
}

output "neptune_cluster_resource_id" {
  description = <<-EOF
    Resource ID of the Neptune cluster
    EOF
  value       = aws_neptune_cluster.neptune.cluster_resource_id
}

output "neptune_cluster_arn" {
  description = <<-EOF
    ARN of the Neptune cluster
    EOF
  value       = aws_neptune_cluster.neptune.arn
}

output "neptune_cluster_endpoint" {
  description = <<-EOF
    URL of the Neptune cluster
    EOF
  value       = local.neptune_endpoint
}

output "neptune_cluster_reader_endpoint" {
  description = <<-EOF
    URL of read-only endpoint of the Neptune cluster
    EOF
  value       = aws_neptune_cluster.neptune.reader_endpoint
}

output "neptune_cluster_subnet_group_id" {
  description = <<-EOF
    ID of subnet group for Neptune cluster
    EOF
  value       = aws_neptune_subnet_group.neptune.id
}

output "neptune_security_group_id" {
  description = <<-EOF
    ID of security group for Neptune ML resources
    EOF
  value       = aws_security_group.neptune.id
}

output "neptune_export_security_group_id" {
  description = <<-EOF
    ID of security group for Neptune export resources
    EOF
  value       = aws_security_group.neptune_export.id
}

output "neptune_ml_iam_role_arn" {
  description = <<-EOF
    ARN of IAM role permitting Neptune to create resources for SageMaker
    EOF
  value       = module.neptune_ml_iam.role_arn
}

output "neptune_ec2_instance_profile_arn" {
  description = <<-EOF
    ARN of instance profile for EC2 client role
    EOF
  value       = module.ec2.instance_profile_arn
}

output "neptune_ec2_client_role_arn" {
  description = <<-EOF
    ARN of IAM role with AWS managed permission 'AmazonEC2ContainerServiceforEC2Role' attached
    EOF
  value       = module.ec2.role_arn
}

output "neptune_load_from_s3_iam_role_arn" {
  description = <<-EOF
    ARN of IAM role permitting Neptune to load files from S3
    EOF
  value       = module.s3.role_arn
}

output "neptune_iam_auth_user_arn" {
  description = <<-EOF
    ARN of Neptune IAM auth user
    EOF
  value       = var.create_iam_user ? aws_iam_user.neptune_user[0].arn : ""
}

output "neptune_iam_auth_user_access_key_id" {
  description = <<-EOF
    Access key ID of Neptune IAM auth user
    EOF
  value       = var.create_iam_user ? aws_iam_access_key.neptune_user[0].id : ""
  sensitive   = true
}

output "neptune_iam_auth_user_secret_access_key" {
  description = <<-EOF
    Secret access key of Neptune IAM auth user
    EOF
  value       = var.create_iam_user ? (var.pgp_key != null ? aws_iam_access_key.neptune_user[0].encrypted_secret : aws_iam_access_key.neptune_user[0].secret) : ""
  sensitive   = true
}

output "neptune_iam_auth_role_arn" {
  description = <<-EOF
    ARN of IAM role for Neptune IAM auth user
    EOF
  value       = var.create_iam_user ? module.neptune_user[0].role_arn : ""
}

output "neptune_export_start_command" {
  description = <<-EOF
    Template of CLI command start Neptune exports via AWS Lambda
    EOF
  value       = local.neptune_export_start_command
}

output "neptune_export_status_command" {
  description = <<-EOF
    Template of CLI command to check status of Neptune exports via AWS Lambda
    EOF
  value       = local.neptune_export_status_command
}

output "neptune_export_api_uri" {
  description = <<-EOF
    URL of API Gateway for Neptune exports
    EOF
  value       = aws_api_gateway_stage.neptune_export.invoke_url
}

output "sagemaker_notebook_lifecycle_configuration_id" {
  description = <<-EOF
    ID of lifecycle configuration used by the SageMaker notebook
    EOF
  value       = aws_sagemaker_notebook_instance_lifecycle_configuration.neptune.id
}

output "sagemaker_notebook_name" {
  description = <<-EOF
    Name of the SageMaker notebook
    EOF
  value       = aws_sagemaker_notebook_instance.neptune.name
}
