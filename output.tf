output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_deployment.default.invoke_url}"
}
