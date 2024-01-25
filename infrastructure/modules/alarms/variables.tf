variable "lambda_function_names" {
  type = set(string)
}

variable "api_gateway_name" {
  type = string
}

variable "alarm_action_sns_topic_arn" {
  type = string
}