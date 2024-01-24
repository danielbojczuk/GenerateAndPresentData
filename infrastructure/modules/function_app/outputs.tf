output "lambda_invoke_arn" {
  value = aws_lambda_function.data_generator.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.data_generator.function_name
}

output "lambda_execution_role_name" {
  value = aws_iam_role.iam_for_lambda.name
}