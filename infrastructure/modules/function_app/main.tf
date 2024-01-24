resource "aws_lambda_function" "data_generator" {
    filename = var.lambda_zip_path
    handler = "app.lambdaHandler"
    runtime = "nodejs20.x"
    function_name = "${var.function_name}-${terraform.workspace}"
    source_code_hash = filebase64sha256(var.lambda_zip_path)
    role = aws_iam_role.iam_for_lambda.arn
    timeout = 30
    depends_on = [
        null_resource.build_lambda_function
    ]
    vpc_config {
        subnet_ids         = [var.lambda_subnet_id]
        security_group_ids = [var.lambda_security_group_id]
    }
    environment  {
      variables = var.lambda_function_environment
    }
}

resource "null_resource" "sam_metadata_aws_lambda_function_data_generator" {
    triggers = {
        resource_name = "aws_lambda_function.${var.function_name}-${terraform.workspace}"
        resource_type = "ZIP_LAMBDA_FUNCTION"
        original_source_code = var.lambda_source_code_path
        built_output_path = var.lambda_zip_path
    }
    depends_on = [
        null_resource.build_lambda_function
    ]
}

resource "null_resource" "build_lambda_function" {
    triggers = {
        build_number = "${timestamp()}"
    }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "role-${var.function_name}-${terraform.workspace}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
EOF
  inline_policy {
    name = "CloudWatch"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:PutLogEvents",
                      "logs:CreateLogStream",
                      "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  inline_policy {
    name = "VPCNetworking"

    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
})
  }
}