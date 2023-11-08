resource "aws_api_gateway_resource" "this" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "this" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.this.id

  authorization = "AWS_IAM"
  http_method   = "ANY"
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "201"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method

  type = "AWS_PROXY"
  uri  = var.lambda_invoke_arn

  integration_http_method = "POST"
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.this.status_code

  depends_on = [
    aws_api_gateway_integration.this,
  ]
}
