resource "aws_api_gateway_rest_api" "data_api_gateway" {
 name = "data-api-gateway-${terraform.workspace}"
   description = "Data API"

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
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.apigw_authorizer.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.data_api_gateway.id
  resource_id = aws_api_gateway_resource.data_resource.id
  http_method = aws_api_gateway_method.data_post_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.data_generator_fa.lambda_invoke_arn
}

resource "aws_api_gateway_method" "data_get_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.data_api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.data_resource.id}"
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.apigw_authorizer.id
}

resource "aws_api_gateway_integration" "get_data_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.data_api_gateway.id
  resource_id = aws_api_gateway_resource.data_resource.id
  http_method = aws_api_gateway_method.data_get_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.data_presenter_fa.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.get_data_lambda_integration
  ]

  rest_api_id = "${aws_api_gateway_rest_api.data_api_gateway.id}"
  
  variables = {
    deployed_at = "${timestamp()}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "apigw_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.data_api_gateway.id
  stage_name    = terraform.workspace
  xray_tracing_enabled = true
}

resource "aws_api_gateway_authorizer" "apigw_authorizer" {
  name                   = "api-gateway-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.data_api_gateway.id
  authorizer_uri         = module.data_api_authorizer_fa.lambda_invoke_arn
}