resource "aws_cloudwatch_metric_alarm" "LambdaFunctionErrors" {
    for_each = var.lambda_function_names

    alarm_name                = "${each.value}-errors"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = 1
    metric_name               = "Errors"
    namespace                 = "AWS/Lambda"
    period                    = 60
    statistic                 = "Sum"
    threshold                 = 1
    alarm_description         = "This metric monitors errors on ${each.value}"
    actions_enabled = true
    alarm_actions = [ var.alarm_action_sns_topic_arn ]
    dimensions = {
        FunctionName = each.value
    }
}

resource "aws_cloudwatch_metric_alarm" "ApiGateway5XXErrors" {
    alarm_name                = "${var.api_gateway_name}-5XXError"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = 1
    metric_name               = "5XXError"
    namespace                 = "AWS/ApiGateway"
    period                    = 60
    statistic                 = "Sum"
    threshold                 = 1
    alarm_description         = "This metric monitors errors on ${var.api_gateway_name}"
    actions_enabled = true
    alarm_actions = [ var.alarm_action_sns_topic_arn ]
    dimensions = {
        ApiName = var.api_gateway_name
    }
}