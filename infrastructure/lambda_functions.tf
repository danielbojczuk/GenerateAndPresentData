###data-generator###
module "data_generator_fa" {
  source = "./modules/function_app"

  function_name = "data-generator"
  lambda_zip_path = "../.dist/data_generator_fa.zip"
  lambda_source_code_path = "../data_generator_fa/.dist/"
  lambda_subnet_id = aws_subnet.private_subnet.id
  lambda_security_group_id = aws_default_security_group.default_security_group.id
  lambda_function_environment = {
    SQS_URL = aws_sqs_queue.data_persist_queue.url
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${module.data_generator_fa.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.data_api_gateway.execution_arn}/*/*"
}

data "aws_iam_policy_document" "post_data_persist_queue_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.data_persist_queue.arn]
  }
}

resource "aws_iam_policy" "post_data_persist_queue_policy" {
  name        = "post-data-perist-queue-${terraform.workspace}"
  policy      = data.aws_iam_policy_document.post_data_persist_queue_policy_document.json
}

resource "aws_iam_role_policy_attachment" "post_data_persist_queue_policy_lambda_attach" {
  role       = module.data_generator_fa.lambda_execution_role_name
  policy_arn = aws_iam_policy.post_data_persist_queue_policy.arn
}

###data-persister###
module "data_persister_fa" {
  source = "./modules/function_app"

  function_name = "data-persister"
  lambda_zip_path = "../.dist/data_persister_fa.zip"
  lambda_source_code_path = "../data_persister_fa/.dist/"
  lambda_subnet_id = aws_subnet.private_subnet.id
  lambda_security_group_id = aws_default_security_group.default_security_group.id
  lambda_function_environment = {
    TABLE_NAME = aws_dynamodb_table.data_table.name
  }
}

resource "aws_iam_role_policy_attachment" "post_data_persist_queue_policy_lambda_trigger_attach" {
  role       = module.data_persister_fa.lambda_execution_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_event_source_mapping" "lambda_persister_sqs_trigger" {
  event_source_arn = aws_sqs_queue.data_persist_queue.arn
  function_name    = module.data_persister_fa.lambda_function_name
}

data "aws_iam_policy_document" "table_data_persist_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.data_table.arn]
  }
}

resource "aws_iam_policy" "table_data_persist_policy" {
  name        = "table-data-perist-${terraform.workspace}"
  policy      = data.aws_iam_policy_document.table_data_persist_policy_document.json
}

resource "aws_iam_role_policy_attachment" "table_data_persist_policy_lambda_attach" {
  role       = module.data_persister_fa.lambda_execution_role_name
  policy_arn = aws_iam_policy.table_data_persist_policy.arn
}

###data-presenter###
module "data_presenter_fa" {
  source = "./modules/function_app"

  function_name = "data-presenter"
  lambda_zip_path = "../.dist/data_presenter_fa.zip"
  lambda_source_code_path = "../data_presenter_fa/.dist/"
  lambda_subnet_id = aws_subnet.private_subnet.id
  lambda_security_group_id = aws_default_security_group.default_security_group.id
  lambda_function_environment = {
    TABLE_NAME = aws_dynamodb_table.data_table.name
  }
}

resource "aws_lambda_permission" "apigw_presenter" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${module.data_presenter_fa.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.data_api_gateway.execution_arn}/*/*"
}

data "aws_iam_policy_document" "table_data_present_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem",
                 "dynamodb:Query"]
    resources = [aws_dynamodb_table.data_table.arn]
  }
}

resource "aws_iam_policy" "table_data_present_policy" {
  name        = "table-data-present-${terraform.workspace}"
  policy      = data.aws_iam_policy_document.table_data_present_policy_document.json
}

resource "aws_iam_role_policy_attachment" "table_data_present_policy_lambda_attach" {
  role       = module.data_presenter_fa.lambda_execution_role_name
  policy_arn = aws_iam_policy.table_data_present_policy.arn
}