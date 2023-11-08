output "resource_id" {
  description = <<-EOF
    ID of the API Gateway resource
    EOF
  value       = aws_api_gateway_resource.this.id
}

output "uri" {
  description = <<-EOF
    Complete path for this API resource, including all parent paths
    EOF
  value       = aws_api_gateway_resource.this.path
}

output "properties" {
  description = <<-EOF
    The properties of all resources created by this module.
    Used for triggering redeployments of API Gateway.
    EOF
  value = [
    aws_api_gateway_resource.this,
    aws_api_gateway_method.this,
    aws_api_gateway_method_response.this,
    aws_api_gateway_integration.this,
    aws_api_gateway_integration_response.this,
  ]
}
