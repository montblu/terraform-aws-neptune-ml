# Neptune ML

Terraform module which attempts to be analogous to and creates almost all the same resources as AWS's [CloudFormation template](https://docs.aws.amazon.com/neptune/latest/userguide/machine-learning-quick-start.html) for Neptune ML. It strives to be more customizable than the CloudFormation template.

Rather than creating a separate VPC, like in the CloudFormation template, this module will set up everything in an existing VPC. You are therefore required to provide a VPC ID as an input argument when using this module.

Resources in IAM policy documents are, where possible, stricter than their CloudFormation counterparts, and all resources use at-rest encryption by default.

Contributions are welcome.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.26.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ./modules/role | n/a |
| <a name="module_batch_execution"></a> [batch\_execution](#module\_batch\_execution) | ./modules/role | n/a |
| <a name="module_batch_job"></a> [batch\_job](#module\_batch\_job) | ./modules/role | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/role | n/a |
| <a name="module_lambda_execution"></a> [lambda\_execution](#module\_lambda\_execution) | ./modules/role | n/a |
| <a name="module_neptune_export_gateway"></a> [neptune\_export\_gateway](#module\_neptune\_export\_gateway) | ./modules/gateway-lambda-integration | n/a |
| <a name="module_neptune_export_gateway_proxy"></a> [neptune\_export\_gateway\_proxy](#module\_neptune\_export\_gateway\_proxy) | ./modules/gateway-lambda-integration | n/a |
| <a name="module_neptune_export_lambda"></a> [neptune\_export\_lambda](#module\_neptune\_export\_lambda) | ./modules/lambda | n/a |
| <a name="module_neptune_export_status_lambda"></a> [neptune\_export\_status\_lambda](#module\_neptune\_export\_status\_lambda) | ./modules/lambda | n/a |
| <a name="module_neptune_ml_iam"></a> [neptune\_ml\_iam](#module\_neptune\_ml\_iam) | ./modules/role | n/a |
| <a name="module_neptune_user"></a> [neptune\_user](#module\_neptune\_user) | ./modules/role | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ./modules/role | n/a |
| <a name="module_sagemaker_execution"></a> [sagemaker\_execution](#module\_sagemaker\_execution) | ./modules/role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.neptune_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_deployment.neptune_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_rest_api.neptune_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api_policy.neptune_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api_policy) | resource |
| [aws_api_gateway_stage.neptune_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_batch_compute_environment.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) | resource |
| [aws_batch_job_definition.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_definition) | resource |
| [aws_batch_job_queue.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_cloudwatch_log_group.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.sagemaker_notebook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.sagemaker_processing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_access_key.neptune_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.neptune_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.neptune_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_kms_alias.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_neptune_cluster.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_cluster) | resource |
| [aws_neptune_cluster_instance.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_cluster_instance) | resource |
| [aws_neptune_cluster_parameter_group.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_cluster_parameter_group) | resource |
| [aws_neptune_parameter_group.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_parameter_group) | resource |
| [aws_neptune_subnet_group.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/neptune_subnet_group) | resource |
| [aws_s3_bucket.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_sagemaker_notebook_instance.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_notebook_instance) | resource |
| [aws_sagemaker_notebook_instance_lifecycle_configuration.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_notebook_instance_lifecycle_configuration) | resource |
| [aws_security_group.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.neptune](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.neptune_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.neptune_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.neptune_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.neptune_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpce_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_iam_user.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_user) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_batch_compute_instance_types"></a> [batch\_compute\_instance\_types](#input\_batch\_compute\_instance\_types) | List of instance types to use for Batch compute environments. | `list(string)` | <pre>[<br>  "c5"<br>]</pre> | no |
| <a name="input_cluster_parameter_group"></a> [cluster\_parameter\_group](#input\_cluster\_parameter\_group) | Configuration parameters for database cluster as a map of string to any. | `map(any)` | <pre>{<br>  "neptune_autoscaling_config": "{}",<br>  "neptune_enable_audit_log": 1,<br>  "neptune_lab_mode": "NeptuneML=enabled",<br>  "neptune_lookup_cache": 1,<br>  "neptune_query_timeout": 120000,<br>  "neptune_streams": 0<br>}</pre> | no |
| <a name="input_create_iam_user"></a> [create\_iam\_user](#input\_create\_iam\_user) | Whether or not to create an IAM user with assumable role to access Neptune<br>ML resources. If true, variable 'neptune\_iam\_authentication' should also be<br>set to true, and variable 'pgp\_key' should also be provided, otherwise the<br>user's secret key will be stored in plain text in the Terraform state file. | `bool` | `false` | no |
| <a name="input_database_instance_type"></a> [database\_instance\_type](#input\_database\_instance\_type) | Neptune DB instance type. | `string` | `"db.t3.medium"` | no |
| <a name="input_database_min_instances"></a> [database\_min\_instances](#input\_database\_min\_instances) | How many instances to run at a minimum. | `number` | `1` | no |
| <a name="input_extra_subnet_ids"></a> [extra\_subnet\_ids](#input\_extra\_subnet\_ids) | IDs of other subnets where requests to Neptune may originate from. | `list(string)` | `[]` | no |
| <a name="input_instance_parameter_group"></a> [instance\_parameter\_group](#input\_instance\_parameter\_group) | Configuration parameters for instances as a map of string to any. | `map(any)` | <pre>{<br>  "neptune_dfe_query_engine": "viaQueryHint",<br>  "neptune_query_timeout": 120000,<br>  "neptune_result_cache": 0<br>}</pre> | no |
| <a name="input_kms_admin_role_names"></a> [kms\_admin\_role\_names](#input\_kms\_admin\_role\_names) | Names of additional IAM roles that will be administrators of the<br>KMS key. Not required, but very recommended. Root is always added. | `list(string)` | `[]` | no |
| <a name="input_kms_admin_user_names"></a> [kms\_admin\_user\_names](#input\_kms\_admin\_user\_names) | Names of additional IAM users that will be administrators of the<br>KMS key. Not required, but very recommended. Root is always added. | `list(string)` | `[]` | no |
| <a name="input_neptune_allow_major_version_upgrade"></a> [neptune\_allow\_major\_version\_upgrade](#input\_neptune\_allow\_major\_version\_upgrade) | Whether or not to allow automatic major version upgrades of Neptune<br>cluster. | `bool` | `true` | no |
| <a name="input_neptune_apply_immediately"></a> [neptune\_apply\_immediately](#input\_neptune\_apply\_immediately) | Whether or not to apply changes to Neptune immediately or wait for<br>maintenance window. | `bool` | `false` | no |
| <a name="input_neptune_backup_window"></a> [neptune\_backup\_window](#input\_neptune\_backup\_window) | Window of time to run backups of Neptune cluster. | `string` | `"07:00-09:00"` | no |
| <a name="input_neptune_engine_version"></a> [neptune\_engine\_version](#input\_neptune\_engine\_version) | The version of the Neptune engine to run the cluster. | `string` | `"1.2.1.0"` | no |
| <a name="input_neptune_iam_authentication"></a> [neptune\_iam\_authentication](#input\_neptune\_iam\_authentication) | Whether or not enable IAM authentication for the Neptune cluster. | `bool` | `false` | no |
| <a name="input_neptune_maintenance_window"></a> [neptune\_maintenance\_window](#input\_neptune\_maintenance\_window) | Window of time to run maintenance of Neptune cluster. | `string` | `"sat:22:00-sun:04:00"` | no |
| <a name="input_neptune_port"></a> [neptune\_port](#input\_neptune\_port) | The port which Neptune will expose. | `number` | `8182` | no |
| <a name="input_neptune_skip_final_snapshot"></a> [neptune\_skip\_final\_snapshot](#input\_neptune\_skip\_final\_snapshot) | Whether or not to skip taking a snapshot of the database before deletion. | `bool` | `false` | no |
| <a name="input_neptune_subnet_ids"></a> [neptune\_subnet\_ids](#input\_neptune\_subnet\_ids) | IDs of subnets to set up NeptuneML resources running in. | `list(string)` | n/a | yes |
| <a name="input_pgp_key"></a> [pgp\_key](#input\_pgp\_key) | For IAM user secret key. A base-64 encoded PGP public key, or a keybase<br>username in the form keybase:some\_person\_that\_exists. If PGP key, provide<br>\"unarmored\" version (e.g. avoid passing the `-a` option to gpg `--export`). | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | A name to add as prefix or suffix created resources.<br>Can be environment, like `test` or `prod`. | `string` | `""` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | IDs of route tables to add to S3 VPC Endpoint. | `list(string)` | `[]` | no |
| <a name="input_sagemaker_notebook_instance_type"></a> [sagemaker\_notebook\_instance\_type](#input\_sagemaker\_notebook\_instance\_type) | The instance type of the SageMaker notebook. | `string` | `"ml.t3.medium"` | no |
| <a name="input_sagemaker_notebook_platform_id"></a> [sagemaker\_notebook\_platform\_id](#input\_sagemaker\_notebook\_platform\_id) | The platform ID of the SageMaker notebook. | `string` | `"notebook-al2-v1"` | no |
| <a name="input_serverless_max_capacity"></a> [serverless\_max\_capacity](#input\_serverless\_max\_capacity) | Maximum Neptune Capacity Units (NCUs) for serverless scaling configuration. | `number` | `0` | no |
| <a name="input_serverless_min_capacity"></a> [serverless\_min\_capacity](#input\_serverless\_min\_capacity) | Minimum Neptune Capacity Units (NCUs) for serverless scaling configuration. | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_security_group_ids"></a> [vpc\_endpoint\_security\_group\_ids](#input\_vpc\_endpoint\_security\_group\_ids) | IDs of security groups allowed to access VPC endpoints. | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to set up Postgres in. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of KMS key used for encrypting data created by Neptune ML resources |
| <a name="output_neptune_cluster_arn"></a> [neptune\_cluster\_arn](#output\_neptune\_cluster\_arn) | ARN of the Neptune cluster |
| <a name="output_neptune_cluster_endpoint"></a> [neptune\_cluster\_endpoint](#output\_neptune\_cluster\_endpoint) | URL of the Neptune cluster |
| <a name="output_neptune_cluster_id"></a> [neptune\_cluster\_id](#output\_neptune\_cluster\_id) | ID of the Neptune cluster |
| <a name="output_neptune_cluster_reader_endpoint"></a> [neptune\_cluster\_reader\_endpoint](#output\_neptune\_cluster\_reader\_endpoint) | URL of read-only endpoint of the Neptune cluster |
| <a name="output_neptune_cluster_resource_id"></a> [neptune\_cluster\_resource\_id](#output\_neptune\_cluster\_resource\_id) | Resource ID of the Neptune cluster |
| <a name="output_neptune_cluster_subnet_group_id"></a> [neptune\_cluster\_subnet\_group\_id](#output\_neptune\_cluster\_subnet\_group\_id) | ID of subnet group for Neptune cluster |
| <a name="output_neptune_ec2_client_role_arn"></a> [neptune\_ec2\_client\_role\_arn](#output\_neptune\_ec2\_client\_role\_arn) | ARN of IAM role with AWS managed permission 'AmazonEC2ContainerServiceforEC2Role' attached |
| <a name="output_neptune_ec2_instance_profile_arn"></a> [neptune\_ec2\_instance\_profile\_arn](#output\_neptune\_ec2\_instance\_profile\_arn) | ARN of instance profile for EC2 client role |
| <a name="output_neptune_export_api_uri"></a> [neptune\_export\_api\_uri](#output\_neptune\_export\_api\_uri) | URL of API Gateway for Neptune exports |
| <a name="output_neptune_export_security_group_id"></a> [neptune\_export\_security\_group\_id](#output\_neptune\_export\_security\_group\_id) | ID of security group for Neptune export resources |
| <a name="output_neptune_export_start_command"></a> [neptune\_export\_start\_command](#output\_neptune\_export\_start\_command) | Template of CLI command start Neptune exports via AWS Lambda |
| <a name="output_neptune_export_status_command"></a> [neptune\_export\_status\_command](#output\_neptune\_export\_status\_command) | Template of CLI command to check status of Neptune exports via AWS Lambda |
| <a name="output_neptune_iam_auth_role_arn"></a> [neptune\_iam\_auth\_role\_arn](#output\_neptune\_iam\_auth\_role\_arn) | ARN of IAM role for Neptune IAM auth user |
| <a name="output_neptune_iam_auth_user_access_key_id"></a> [neptune\_iam\_auth\_user\_access\_key\_id](#output\_neptune\_iam\_auth\_user\_access\_key\_id) | Access key ID of Neptune IAM auth user |
| <a name="output_neptune_iam_auth_user_arn"></a> [neptune\_iam\_auth\_user\_arn](#output\_neptune\_iam\_auth\_user\_arn) | ARN of Neptune IAM auth user |
| <a name="output_neptune_iam_auth_user_secret_access_key"></a> [neptune\_iam\_auth\_user\_secret\_access\_key](#output\_neptune\_iam\_auth\_user\_secret\_access\_key) | Secret access key of Neptune IAM auth user |
| <a name="output_neptune_load_from_s3_iam_role_arn"></a> [neptune\_load\_from\_s3\_iam\_role\_arn](#output\_neptune\_load\_from\_s3\_iam\_role\_arn) | ARN of IAM role permitting Neptune to load files from S3 |
| <a name="output_neptune_ml_iam_role_arn"></a> [neptune\_ml\_iam\_role\_arn](#output\_neptune\_ml\_iam\_role\_arn) | ARN of IAM role permitting Neptune to create resources for SageMaker |
| <a name="output_neptune_security_group_id"></a> [neptune\_security\_group\_id](#output\_neptune\_security\_group\_id) | ID of security group for Neptune ML resources |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of S3 bucket for loading data into Neptune |
| <a name="output_sagemaker_notebook_lifecycle_configuration_id"></a> [sagemaker\_notebook\_lifecycle\_configuration\_id](#output\_sagemaker\_notebook\_lifecycle\_configuration\_id) | ID of lifecycle configuration used by the SageMaker notebook |
| <a name="output_sagemaker_notebook_name"></a> [sagemaker\_notebook\_name](#output\_sagemaker\_notebook\_name) | Name of the SageMaker notebook |
<!-- END_TF_DOCS -->
