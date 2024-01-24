variable "lambda_zip_path" {
  type = string
}

variable "lambda_source_code_path" {
  type = string
}

variable "lambda_subnet_id" {
  type = string
}

variable "lambda_security_group_id" {
  type = string
}

variable "function_name" {
    type = string
}

variable "lambda_function_environment" {
    type = map(string)
    default = {}
}