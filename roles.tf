module "s3" {
  source    = "./modules/service-role"
  role_name = "NeptuneMLLoadFromS3"

  principal_identifiers = [
    "rds.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "s3:Get*",
        "s3:List*",
      ]
      resources = [
        aws_s3_bucket.neptune.arn,
        "${aws_s3_bucket.neptune.arn}/*",
      ]
    },
    {
      actions = [
        "kms:Decrypt",
      ]
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
  ]

  tags = var.tags
}

module "api_gateway" {
  source    = "./modules/service-role"
  role_name = "NeptuneMLApiGatewayLogs"

  principal_identifiers = [
    "apigateway.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
        "logs:PutLogEvents",
      ]
      resources = [
        "${local.iam_logs_prefix}:*",
      ]
    },
  ]

  tags = var.tags
}

module "ec2" {
  source = "./modules/service-role"

  role_name               = "NeptuneMLEC2Client"
  aws_managed_policy_name = "AmazonEC2ContainerServiceforEC2Role"
  with_instance_profile   = true

  principal_identifiers = [
    "ec2.amazonaws.com",
  ]

  tags = var.tags
}

module "batch_execution" {
  source = "./modules/service-role"

  role_name               = "NeptuneMLBatchExecution"
  aws_managed_policy_name = "AWSBatchServiceRole"

  principal_identifiers = [
    "batch.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "logs:*",
      ]
      resources = [
        "${aws_cloudwatch_log_group.batch.arn}:*",
      ]
    },
    {
      actions = [
        "logs:DescribeLogGroups",
      ]
      resources = [
        "${local.iam_logs_prefix}:log-group::log-stream:*",
      ]
    },
    {
      actions = [
        "ecs:*",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "ec2:*",
      ]
      resources = [
        "arn:aws:ec2:${local.aws_region}:${local.account_id}:*",
      ]
    },
    {
      actions = [
        "kms:Encrypt",
        "kms:GenerateDataKey*",
      ]
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
  ]

  tags = var.tags
}

module "batch_job" {
  source    = "./modules/service-role"
  role_name = "NeptuneMLBatchJob"

  principal_identifiers = [
    "ecs-tasks.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "cloudwatch:PutMetricData",
      ]
      resources = [
        "arn:aws:cloudwatch:${local.aws_region}:${local.account_id}:*",
      ]
    },
    {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
      ],
      resources = [
        "${aws_cloudwatch_log_group.batch.arn}:*",
      ]
    },
    {
      actions = [
        "neptune-db:*",
      ]
      resources = [
        "${local.neptune_cluster_resource_arn}/*",
      ]
    },
    {
      actions = [
        "rds:AddTagsToResource",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:ListTagsForResource",
        "rds:DescribeDBClusterParameters",
        "rds:DescribeDBParameters",
        "rds:ModifyDBParameterGroup",
        "rds:ModifyDBClusterParameterGroup",
        "rds:RestoreDBClusterToPointInTime",
        "rds:DeleteDBInstance",
        "rds:DeleteDBClusterParameterGroup",
        "rds:DeleteDBParameterGroup",
        "rds:DeleteDBCluster",
        "rds:CreateDBInstance",
        "rds:CreateDBClusterParameterGroup",
        "rds:CreateDBParameterGroup",
      ]
      resources = [
        "arn:aws:rds:${local.aws_region}:${local.account_id}:*",
      ]
    },
    {
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:Encrypt",
      ]
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
    {
      actions = [
        "s3:PutObject",
        "s3:PutObjectTagging",
        "s3:GetObject",
      ]
      resources = [
        "arn:aws:s3:::*",
      ]
    },
  ]

  tags = var.tags
}

module "neptune_ml_iam" {
  source    = "./modules/service-role"
  role_name = "NeptuneMLIAM"

  principal_identifiers = [
    "rds.amazonaws.com",
    "sagemaker.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:CreateVpcEndpoint",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteNetworkInterfacePermission",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpcs",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
      ]
      resources = [
        "*",
        "arn:aws:ecr:*:*:repository/*",
      ]
    },
    {
      actions = [
        "iam:PassRole",
      ]
      resources = [
        "arn:aws:iam::${local.account_id}:role/*",
      ]
      conditions = [
        {
          test     = "StringEquals"
          variable = "iam:PassedToService"
          values = [
            "sagemaker.amazonaws.com",
          ]
        }
      ]
    },
    {
      actions = [
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
      ],
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
    {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resources = [
        "${local.iam_logs_prefix}:log-group:/aws/sagemaker/*",
      ]
    },
    {
      actions = [
        "sagemaker:CreateEndpoint",
        "sagemaker:CreateEndpointConfig",
        "sagemaker:CreateHyperParameterTuningJob",
        "sagemaker:CreateModel",
        "sagemaker:CreateProcessingJob",
        "sagemaker:CreateTrainingJob",
        "sagemaker:DeleteEndpoint",
        "sagemaker:DeleteEndpointConfig",
        "sagemaker:StopHyperParameterTuningJob",
        "sagemaker:DeleteModel",
        "sagemaker:StopProcessingJob",
        "sagemaker:StopTrainingJob",
        "sagemaker:DescribeEndpoint",
        "sagemaker:DescribeEndpointConfig",
        "sagemaker:DescribeHyperParameterTuningJob",
        "sagemaker:DescribeModel",
        "sagemaker:DescribeProcessingJob",
        "sagemaker:DescribeTrainingJob",
        "sagemaker:InvokeEndpoint",
        "sagemaker:ListTags",
        "sagemaker:AddTags",
        "sagemaker:ListTrainingJobsForHyperParameterTuningJob",
        "sagemaker:UpdateEndpoint",
        "sagemaker:UpdateEndpointWeightsAndCapacities",
      ]
      resources = [
        "arn:aws:sagemaker:${local.aws_region}:${local.account_id}:*",
      ]
    },
    {
      actions = [
        "sagemaker:ListEndpointConfigs",
        "sagemaker:ListEndpoints",
        "sagemaker:ListHyperParameterTuningJobs",
        "sagemaker:ListModels",
        "sagemaker:ListProcessingJobs",
        "sagemaker:ListTrainingJobs",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListBucket",
      ]
      resources = [
        "arn:aws:s3:::*",
      ]
    },
  ]

  tags = var.tags
}

module "sagemaker_execution" {
  source    = "./modules/service-role"
  role_name = "NeptuneMLSagemakerExecution"

  principal_identifiers = [
    "sagemaker.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "cloudwatch:PutMetricData",
      ]
      resources = [
        "arn:aws:cloudwatch:${local.aws_region}:${local.account_id}:*",
      ]
    },
    {
      actions = [
        "logs:CreateLogDelivery",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DeleteLogDelivery",
        "logs:Describe*",
        "logs:GetLogDelivery",
        "logs:GetLogEvents",
        "logs:ListLogDeliveries",
        "logs:PutLogEvents",
        "logs:PutResourcePolicy",
        "logs:UpdateLogDelivery",
      ]
      resources = [
        "${aws_cloudwatch_log_group.sagemaker_notebook.arn}:*",
        "${aws_cloudwatch_log_group.sagemaker_processing.arn}:*",
      ]
    },
    {
      actions = [
        "neptune-db:*",
      ]
      resources = [
        "${local.neptune_cluster_resource_arn}/*",
      ]
    },
    {
      actions = [
        "s3:Put*",
        "s3:Get*",
        "s3:List*",
      ]
      resources = [
        aws_s3_bucket.neptune.arn,
        "${aws_s3_bucket.neptune.arn}/*",
        "arn:aws:s3:::aws-neptune-notebook",
        "arn:aws:s3:::aws-neptune-notebook/*",
      ]
    },
    {
      actions = [
        "execute-api:Invoke",
      ]
      resources = [
        "arn:aws:execute-api:${local.aws_region}:${local.account_id}:*/*",
      ]
    },
    {
      actions = [
        "sagemaker:CreateModel",
        "sagemaker:CreateEndpointConfig",
        "sagemaker:CreateEndpoint",
        "sagemaker:DescribeModel",
        "sagemaker:DescribeEndpointConfig",
        "sagemaker:DescribeEndpoint",
        "sagemaker:DescribeNotebookInstance",
        "sagemaker:DeleteModel",
        "sagemaker:DeleteEndpointConfig",
        "sagemaker:DeleteEndpoint",
      ]
      resources = [
        "arn:aws:sagemaker:${local.aws_region}:${local.account_id}:*/*",
      ]
    },
    {
      actions = [
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
      ]
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
    {
      actions = [
        "iam:PassRole",
      ]
      resources = [
        module.neptune_ml_iam.role_arn,
      ]
    },
  ]

  tags = var.tags
}

module "lambda_execution" {
  source    = "./modules/service-role"
  role_name = "NeptuneMLLambdaExecution"

  principal_identifiers = [
    "lambda.amazonaws.com",
  ]

  statements = [
    {
      actions = [
        "logs:CreateLogGroup",
      ]
      resources = [
        "${local.iam_logs_prefix}:*",
      ]
    },
    {
      actions = [
        "logs:CreateLogStream",
        "logs:GetLogEvents",
        "logs:PutLogEvents",
      ]
      resources = [
        "${local.iam_logs_prefix}:log-group:/aws/lambda/*:*",
      ]
    },
    {
      actions = [
        "batch:DescribeJobs",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "s3:ListBucket",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "batch:SubmitJob",
      ]
      resources = [
        "${local.iam_batch_prefix}:job-definition/${aws_batch_job_definition.neptune.name}",
        "${aws_batch_job_queue.neptune.arn}*",
      ]
    },
    {
      actions = [
        "batch:TerminateJob",
      ]
      resources = [
        "${local.iam_batch_prefix}:job/${aws_batch_job_definition.neptune.name}*",
        "${aws_batch_job_queue.neptune.arn}*",
      ]
    },
    {
      actions = [
        "kms:CreateGrant",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
      ]
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
  ]

  tags = var.tags
}

module "neptune_user" {
  count = var.create_iam_user ? 1 : 0

  source    = "./modules/service-role"
  role_name = "NeptuneMLUser"

  aws_managed_policy_name = "NeptuneReadOnlyAccess"

  principal_type = "AWS"
  principal_identifiers = [
    aws_iam_user.neptune_user[0].arn,
  ]

  statements = [
    {
      actions = [
        "neptune-db:CancelLoaderJob",
        "neptune-db:CancelMLDataProcessingJob",
        "neptune-db:CreateMLEndpoint",
        "neptune-db:CancelMLModelTransformJob",
        "neptune-db:CancelMLModelTrainingJob",
        "neptune-db:DeleteMLEndpoint",
        "neptune-db:StartLoaderJob",
        "neptune-db:StartMLDataProcessingJob",
        "neptune-db:StartMLModelTrainingJob",
        "neptune-db:StartMLModelTransformJob",
      ]
      resources = [
        "${local.neptune_cluster_resource_arn}/*",
      ]
    },
    {
      actions = [
        "sagemaker:CreateEndpoint*",
        "sagemaker:DeleteEndpoint*",
        "sagemaker:DeleteInferenceExperiment",
        "sagemaker:Describe*",
        "sagemaker:Get*",
        "sagemaker:List*",
        "sagemaker:StartInferenceExperiment",
      ]
      resources = [
        aws_sagemaker_notebook_instance.neptune.arn,
      ]
    },
    {
      actions = [
        "s3:Describe*",
        "s3:Get*",
        "s3:List*",
        "s3:PutObject*",
      ]
      resources = [
        aws_s3_bucket.neptune.arn,
        "${aws_s3_bucket.neptune.arn}/*",
      ]
    },
    {
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
      ]
      resources = [
        aws_kms_key.neptune.arn,
      ]
    },
  ]

  tags = var.tags
}
