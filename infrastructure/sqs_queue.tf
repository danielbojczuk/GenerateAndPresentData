resource "aws_sqs_queue" "data_persist_queue" {
  name                      = "data-persist-queue-${terraform.workspace}"
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