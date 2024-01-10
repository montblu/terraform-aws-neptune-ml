locals {
  identifier = coalesce(var.resource_group_name, random_id.this.hex)

  account_id = data.aws_caller_identity.this.account_id

  aws_region = data.aws_region.this.name

  database_name = "neptune-${local.identifier}"

  final_snapshot_identifier = (
    local.identifier == random_id.this.hex
    ? "${local.database_name}-final-snapshot"
    : "${local.database_name}-final-snapshot-${random_id.this.hex}"
  )

  neptune_major_version = split(".", var.neptune_engine_version)[1]

  parameter_group_family = (
    tonumber(local.neptune_major_version) > 1
    ? "neptune1.${local.neptune_major_version}"
    : "neptune1"
  )

  iam_logs_prefix = "arn:aws:logs:${local.aws_region}:${local.account_id}"

  iam_batch_prefix = "arn:aws:batch:${local.aws_region}:${local.account_id}"

  neptune_cluster_resource_arn = "arn:aws:neptune-db:${local.aws_region}:${local.account_id}:${aws_neptune_cluster.neptune.cluster_resource_id}"

  extra_subnets_cidr_blocks = [for subnet in data.aws_subnet.extra : subnet.cidr_block]

  neptune_export_jar_uri = "https://s3.amazonaws.com/aws-neptune-customer-samples/neptune-export/bin/neptune-export.jar"

  neptune_endpoint = "https://${aws_neptune_cluster.neptune.endpoint}:${aws_neptune_cluster.neptune.port}"

  # The prefix before ${local.database_name} is required for Neptune to detect the SageMaker notebook.
  sagemaker_notebook_name = "aws-neptune-notebook-for-${local.database_name}"

  sagemaker_notebook_startup_script = <<-SCRIPT
    #!/usr/bin/env bash
    sudo --user ec2-user --login <<EOF

    echo "export GRAPH_NOTEBOOK_AUTH_MODE=DEFAULT" >> ~/.bashrc
    echo "export GRAPH_NOTEBOOK_IAM_PROVIDER=ROLE" >> ~/.bashrc
    echo "export GRAPH_NOTEBOOK_SSL=True" >> ~/.bashrc
    echo "export GRAPH_NOTEBOOK_HOST=${aws_neptune_cluster.neptune.endpoint}" >> ~/.bashrc
    echo "export GRAPH_NOTEBOOK_PORT=${aws_neptune_cluster.neptune.port}" >> ~/.bashrc
    echo "export NEPTUNE_LOAD_FROM_S3_ROLE_ARN=${module.s3.role_arn}" >> ~/.bashrc
    echo "export AWS_REGION=${local.aws_region}" >> ~/.bashrc

    echo "export NEPTUNE_ML_ROLE_ARN=${module.neptune_ml_iam.role_arn}" >> ~/.bashrc

    echo "export NEPTUNE_EXPORT_API_URI=${aws_api_gateway_stage.neptune_export.invoke_url}${module.neptune_export_gateway.uri}" >> ~/.bashrc

    aws s3 cp s3://aws-neptune-notebook/graph_notebook.tar.gz /tmp/graph_notebook.tar.gz
    rm -rf /tmp/graph_notebook
    tar -zxvf /tmp/graph_notebook.tar.gz -C /tmp
    /tmp/graph_notebook/install.sh
    EOF
    SCRIPT

  neptune_export_start_command = <<-EOF
    aws lambda invoke \
      --function name ${module.neptune_export_lambda.arn} \
      --region ${local.aws_region} \
      --payload '\
        { \
          "command": "export-pg -e ${local.neptune_endpoint} --use-ssl --clone-cluster", \
          "outputS3Path": "s3://${aws_s3_bucket.neptune.bucket}/neptune-export", \
          "jobSize": "small|medium|large|xlarge" \
        }' \
      /dev/stdout
    EOF

  neptune_export_status_command = <<-EOF
    aws lambda invoke \
      --function name ${module.neptune_export_status_lambda.arn} \
      --region ${local.aws_region} \
      --payload '\
        { \
          "jobId": "<neptune_export_job_id>" \
        }' \
      /dev/stdout
    EOF

  vpc_endpoint_security_group_ids = compact(
    concat(
      var.vpc_endpoint_security_group_ids,
      [
        aws_security_group.neptune.id,
        aws_security_group.neptune_export.id,
      ],
    )
  )
}
