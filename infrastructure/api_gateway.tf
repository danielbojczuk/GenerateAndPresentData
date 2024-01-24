resource "aws_api_gateway_rest_api" "data_api_gateway" {
 name = "data-api-gateway-${terraform.workspace}"
   description = "Terraform Serverless Application Example"

}

resource "aws_api_gateway_resource" "data_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.data_api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.data_api_gateway.root_resource_id}"
  path_part   = "data"
}

resource "aws_api_gateway_method" "data_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.data_api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.data_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.data_api_gateway.id
  resource_id = aws_api_gateway_resource.data_resource.id
  http_method = aws_api_gateway_method.data_post_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.data_generator_fa.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = "${aws_api_gateway_rest_api.data_api_gateway.id}"
  stage_name  = terraform.workspace

  variables = {
    deployed_at = "${timestamp()}"
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${module.data_generator_fa.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.data_api_gateway.execution_arn}/*/*"
}