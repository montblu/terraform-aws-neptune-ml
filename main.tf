resource "random_id" "this" {
  byte_length = 8
}

##################################
#               KMS              #
##################################
resource "aws_kms_key" "neptune" {
  description             = "Encryption key for Neptune ML"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.neptune_kms.json
}

resource "aws_kms_alias" "neptune" {
  name          = "alias/${local.database_name}"
  target_key_id = aws_kms_key.neptune.id
}

####################################
#                S3                #
####################################
resource "aws_s3_bucket" "neptune" {
  bucket = "${local.database_name}-bucket"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "neptune" {
  bucket = aws_s3_bucket.neptune.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "neptune" {
  bucket = aws_s3_bucket.neptune.bucket

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.neptune.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "neptune" {
  bucket = aws_s3_bucket.neptune.id
  policy = data.aws_iam_policy_document.neptune_s3.json
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${local.aws_region}.s3"
  route_table_ids   = var.route_table_ids
  policy            = data.aws_iam_policy_document.vpce_s3.json

  tags = var.tags
}

#########################################
#            Security group             #
#########################################
resource "aws_security_group" "neptune" {
  name        = local.database_name
  description = "Control traffic to and from Neptune"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all within self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  dynamic "ingress" {
    for_each = length(local.extra_subnets_cidr_blocks) > 0 ? { TCP = var.neptune_port, SSH = 22 } : {}
    content {
      description = "${ingress.key} connections from extra subnets"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = local.extra_subnets_cidr_blocks
    }
  }

  egress {
    description = "All outgoing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = var.tags
}

resource "aws_security_group" "neptune_export" {
  name        = "${local.database_name}-export"
  description = "For exporting data from Neptune"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all within self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow TCP from ${local.database_name} security group"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    security_groups = [
      aws_security_group.neptune.id,
    ]
  }

  egress {
    description = "All outgoing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = var.tags
}

resource "aws_security_group" "batch" {
  name        = "${local.database_name}-batch"
  description = "Allow traffic between batch instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all within self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All outgoing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

###############################################
#                   Neptune                   #
###############################################
resource "aws_cloudwatch_log_group" "neptune" {
  name              = "/aws/neptune/${local.database_name}/audit"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.neptune.arn
  tags              = var.tags
}

resource "aws_neptune_subnet_group" "neptune" {
  name       = local.database_name
  subnet_ids = var.neptune_subnet_ids
  tags       = var.tags
}

resource "aws_neptune_cluster_parameter_group" "neptune" {
  family = local.parameter_group_family
  name   = "${local.database_name}-cluster"

  dynamic "parameter" {
    for_each = merge(var.cluster_parameter_group, { neptune_ml_iam_role = module.neptune_ml_iam.role_arn })
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = var.tags
}

resource "aws_neptune_parameter_group" "neptune" {
  family = local.parameter_group_family
  name   = "${local.database_name}-instances"

  dynamic "parameter" {
    for_each = var.instance_parameter_group
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = var.tags
}

resource "aws_neptune_cluster" "neptune" {
  cluster_identifier = local.database_name
  engine             = "neptune"
  engine_version     = var.neptune_engine_version
  port               = var.neptune_port

  backup_retention_period = var.neptune_backup_retention_period
  preferred_backup_window = var.neptune_backup_window

  allow_major_version_upgrade  = var.neptune_allow_major_version_upgrade
  apply_immediately            = var.neptune_apply_immediately
  preferred_maintenance_window = var.neptune_maintenance_window

  skip_final_snapshot       = var.neptune_skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier

  storage_type      = var.neptune_storage_type
  storage_encrypted = true
  kms_key_arn       = aws_kms_key.neptune.arn

  neptune_subnet_group_name = aws_neptune_subnet_group.neptune.id

  neptune_cluster_parameter_group_name = aws_neptune_cluster_parameter_group.neptune.name

  vpc_security_group_ids = [
    aws_security_group.neptune.id,
    aws_security_group.neptune_export.id,
  ]

  iam_database_authentication_enabled = var.neptune_iam_authentication

  iam_roles = [
    module.neptune_ml_iam.role_arn,
    module.s3.role_arn,
  ]

  dynamic "serverless_v2_scaling_configuration" {
    for_each = toset(var.serverless_min_capacity > 0 && var.serverless_max_capacity > 0 ? [0] : [])
    content {
      min_capacity = var.serverless_min_capacity
      max_capacity = var.serverless_max_capacity
    }
  }

  enable_cloudwatch_logs_exports = [
    "audit",
  ]

  tags = var.tags
}

resource "aws_neptune_cluster_instance" "neptune" {
  count = var.cluster_instance_count

  identifier         = "${local.database_name}-${count.index + 1}"
  instance_class     = var.database_instance_type
  cluster_identifier = aws_neptune_cluster.neptune.id
  engine             = aws_neptune_cluster.neptune.engine
  port               = aws_neptune_cluster.neptune.port

  publicly_accessible = false

  neptune_subnet_group_name = aws_neptune_cluster.neptune.neptune_subnet_group_name

  neptune_parameter_group_name = aws_neptune_parameter_group.neptune.name

  apply_immediately            = false
  preferred_maintenance_window = aws_neptune_cluster.neptune.preferred_maintenance_window

  tags = var.tags
}

###################################################
#                   API Gateway                   #
###################################################
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/neptune-export/v1"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.neptune.arn
  tags              = var.tags
}

resource "aws_api_gateway_account" "neptune_export" {
  cloudwatch_role_arn = module.api_gateway.role_arn
}

resource "aws_vpc_endpoint" "api_gateway" {
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.aws_region}.execute-api"
  subnet_ids          = var.neptune_subnet_ids
  security_group_ids  = local.vpc_endpoint_security_group_ids
  private_dns_enabled = true

  tags = var.tags
}

resource "aws_api_gateway_rest_api" "neptune_export" {
  name        = "neptune-export-${local.identifier}"
  description = "Neptune Export API"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = [
      aws_vpc_endpoint.api_gateway.id,
    ]
  }

  tags = var.tags

  depends_on = [
    aws_api_gateway_account.neptune_export
  ]
}

resource "aws_api_gateway_rest_api_policy" "neptune_export" {
  rest_api_id = aws_api_gateway_rest_api.neptune_export.id
  policy      = data.aws_iam_policy_document.api_gateway.json
}

module "neptune_export_gateway" {
  source = "./modules/gateway-lambda-integration"

  rest_api_id = aws_api_gateway_rest_api.neptune_export.id
  parent_id   = aws_api_gateway_rest_api.neptune_export.root_resource_id
  path_part   = aws_api_gateway_rest_api.neptune_export.name

  lambda_invoke_arn = module.neptune_export_lambda.invoke_arn
}

module "neptune_export_gateway_proxy" {
  source = "./modules/gateway-lambda-integration"

  rest_api_id = aws_api_gateway_rest_api.neptune_export.id
  parent_id   = module.neptune_export_gateway.resource_id
  path_part   = "{proxy+}"

  lambda_invoke_arn = module.neptune_export_status_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "neptune_export" {
  rest_api_id = aws_api_gateway_rest_api.neptune_export.id

  triggers = {
    redeployment = sha1(
      join(" ",
        [
          aws_api_gateway_rest_api_policy.neptune_export.policy,
          jsonencode(
            concat(
              module.neptune_export_gateway.properties,
              module.neptune_export_gateway_proxy.properties,
            ),
          )
        ]
      )
    )
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.neptune_export_gateway,
    module.neptune_export_gateway_proxy,
  ]
}

resource "aws_api_gateway_stage" "neptune_export" {
  rest_api_id   = aws_api_gateway_rest_api.neptune_export.id
  deployment_id = aws_api_gateway_deployment.neptune_export.id
  stage_name    = "v1"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    # Format is copied from here: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html
    format = jsonencode(
      {
        requestId         = "$context.requestId"
        extendedRequestId = "$context.extendedRequestId"
        ip                = "$context.identity.sourceIp"
        caller            = "$context.identity.caller"
        user              = "$context.identity.user"
        requestTime       = "$context.requestTime"
        httpMethod        = "$context.httpMethod"
        resourcePath      = "$context.resourcePath"
        status            = "$context.status"
        protocol          = "$context.protocol"
        responseLength    = "$context.responseLength"
      }
    )
  }

  tags = var.tags
}

################################
#            Lambda            #
################################
module "neptune_export_lambda" {
  source = "./modules/lambda"

  lambda_name               = "neptune-export-${local.identifier}"
  lambda_handler            = "neptune_export_lambda.lambda_handler"
  lambda_role_arn           = module.lambda_execution.role_arn
  kms_key_arn               = aws_kms_key.neptune.arn
  lambda_source_key         = "neptune-export/install/lambda/neptune_export_lambda.zip"
  permitted_api_gateway_arn = aws_api_gateway_rest_api.neptune_export.execution_arn

  environment_variables = {
    JOB_SUFFIX                = local.identifier
    MAX_FILE_DESCRIPTOR_COUNT = 10000
    NEPTUNE_EXPORT_JAR_URI    = local.neptune_export_jar_uri
  }

  tags = var.tags
}

module "neptune_export_status_lambda" {
  source = "./modules/lambda"

  lambda_name               = "neptune-export-status-${local.identifier}"
  lambda_handler            = "neptune_export_status_lambda.lambda_handler"
  lambda_role_arn           = module.lambda_execution.role_arn
  kms_key_arn               = aws_kms_key.neptune.arn
  lambda_source_key         = "neptune-export/install/lambda/neptune_export_lambda.zip"
  permitted_api_gateway_arn = aws_api_gateway_rest_api.neptune_export.execution_arn

  environment_variables = {
    JOB_SUFFIX             = local.identifier
    NEPTUNE_EXPORT_JAR_URI = local.neptune_export_jar_uri
  }

  tags = var.tags
}

#############################################
#                   Batch                   #
#############################################
resource "aws_cloudwatch_log_group" "batch" {
  name              = "/aws/batch/job"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.neptune.arn
  tags              = var.tags
}

resource "aws_launch_template" "batch" {
  name = "neptune-export-${local.identifier}"

  block_device_mappings {
    device_name = "/dev/sdb"

    ebs {
      volume_size           = 1000
      volume_type           = "io1"
      encrypted             = true
      iops                  = 10000
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

    --==MYBOUNDARY==
    Content-Type: text/cloud-config; charset="us-ascii"

    runcmd:
    - file_system_id_01=/dev/nvme1n1
    - my_directory=/mnt/neptune

    - mkdir -p $${my_directory}
    - echo "$${file_system_id_01} $${my_directory} auto defaults 0 0" >> /etc/fstab
    - mkfs -t ext4 $${file_system_id_01}
    - mount $${file_system_id_01} $${my_directory}

    --==MYBOUNDARY==--
    EOF
  )
}

resource "aws_batch_compute_environment" "neptune" {
  compute_environment_name = "neptune-export-${local.identifier}"
  service_role             = module.batch_execution.role_arn
  type                     = "MANAGED"

  compute_resources {
    instance_role = module.ec2.instance_profile_arn
    type          = "EC2"
    max_vcpus     = 256
    subnets       = var.neptune_subnet_ids

    instance_type = var.batch_compute_instance_types

    security_group_ids = [
      aws_security_group.neptune.id,
      aws_security_group.batch.id,
    ]

    launch_template {
      launch_template_id = aws_launch_template.batch.id
    }
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.batch
  ]
}

resource "aws_batch_job_queue" "neptune" {
  name = "neptune-export-queue-${local.identifier}"

  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.neptune.arn
  }

  tags = var.tags
}

resource "aws_batch_job_definition" "neptune" {
  name = "neptune-export-job-${local.identifier}"
  type = "container"

  platform_capabilities = [
    "EC2",
  ]

  container_properties = jsonencode(
    {
      jobRoleArn = module.batch_job.role_arn
      image      = "openjdk:8"
      resourceRequirements = [
        {
          type  = "MEMORY"
          value = "64000"
        },
        {
          type  = "VCPU"
          value = "8"
        },
      ]
      mountPoints = [
        {
          containerPath = "/neptune"
          sourceVolume  = "neptune"
          readOnly      = false
        },
      ]
      volumes = [
        {
          name = "neptune"
          host = {
            sourcePath = "/mnt/neptune"
          }
        },
      ]
      ulimits = [
        {
          hardLimit = 10000
          softLimit = 10000
          name      = "nofile"
        },
      ]
    }
  )

  tags = var.tags

  depends_on = [
    aws_batch_job_queue.neptune,
  ]
}

##########################################################
#                        Sagemaker                       #
##########################################################
resource "aws_cloudwatch_log_group" "sagemaker_notebook" {
  name              = "/aws/sagemaker/NotebookInstances"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.neptune.arn
}

resource "aws_cloudwatch_log_group" "sagemaker_processing" {
  name              = "/aws/sagemaker/ProcessingJobs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.neptune.arn
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "neptune" {
  name     = local.sagemaker_notebook_name
  on_start = base64encode(local.sagemaker_notebook_startup_script)

  depends_on = [
    aws_cloudwatch_log_group.sagemaker_notebook,
    aws_cloudwatch_log_group.sagemaker_processing,
  ]
}

resource "aws_sagemaker_notebook_instance" "neptune" {
  name                  = local.sagemaker_notebook_name
  role_arn              = module.sagemaker_execution.role_arn
  instance_type         = var.sagemaker_notebook_instance_type
  platform_identifier   = var.sagemaker_notebook_platform_id
  kms_key_id            = aws_kms_key.neptune.id
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.neptune.name
  subnet_id             = var.neptune_subnet_ids[0]

  security_groups = [
    aws_security_group.neptune.id,
  ]

  instance_metadata_service_configuration {
    minimum_instance_metadata_service_version = "1"
  }

  tags = var.tags
}

resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.aws_region}.sagemaker.api"
  subnet_ids          = var.neptune_subnet_ids
  security_group_ids  = local.vpc_endpoint_security_group_ids
  private_dns_enabled = false

  tags = var.tags
}

resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${local.aws_region}.sagemaker.runtime"
  subnet_ids          = var.neptune_subnet_ids
  security_group_ids  = local.vpc_endpoint_security_group_ids
  private_dns_enabled = false

  tags = var.tags
}

########################################
#                 IAM                  #
########################################
resource "aws_iam_user" "neptune_user" {
  count = var.create_iam_user ? 1 : 0

  name          = "neptune-ml"
  force_destroy = true
  # See module.neptune_user in ./roles.tf for role created for this user
}

resource "aws_iam_access_key" "neptune_user" {
  count = var.create_iam_user ? 1 : 0

  user    = aws_iam_user.neptune_user[0].name
  pgp_key = var.pgp_key
}

resource "aws_iam_user_policy" "neptune_user" {
  count = var.create_iam_user ? 1 : 0

  user   = aws_iam_user.neptune_user[0].name
  policy = data.aws_iam_policy_document.neptune_user[0].json
}
