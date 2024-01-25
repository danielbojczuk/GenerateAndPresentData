resource "aws_sns_topic" "error_topics" {
    count = terraform.workspace=="prd" ? 1 : 0
    name = "data-error-topic-${terraform.workspace}"
}

resource "aws_sns_topic_subscription" "error_topics_email_target" {
    count = terraform.workspace=="prd" ? 1 : 0
    topic_arn = aws_sns_topic.error_topics[0].arn
    protocol  = "email"
    endpoint  = "danielbojczuk@gmail.com"
}

module "alarms" {
    count = terraform.workspace=="prd" ? 1 : 0
    source = "./modules/alarms"
    lambda_function_names = [ 
        module.data_generator_fa.lambda_function_name,
        module.data_persister_fa.lambda_function_name,
        module.data_presenter_fa.lambda_function_name,
        module.data_api_authorizer_fa.lambda_function_name
     ]
     api_gateway_name = aws_api_gateway_rest_api.data_api_gateway.name
     alarm_action_sns_topic_arn = aws_sns_topic.error_topics[0].arn
}



