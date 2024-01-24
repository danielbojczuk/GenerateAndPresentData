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