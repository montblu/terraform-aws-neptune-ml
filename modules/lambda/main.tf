resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 90
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  handler       = var.lambda_handler
  runtime       = "python3.8"
  role          = var.lambda_role_arn
  kms_key_arn   = var.kms_key_arn
  s3_bucket     = "aws-neptune-customer-samples-${data.aws_region.this.name}"
  s3_key        = var.lambda_source_key

  environment {
    variables = var.environment_variables
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.permitted_api_gateway_arn}/*"
}
