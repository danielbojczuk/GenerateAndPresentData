resource "aws_sqs_queue" "data_persist_queue" {
  name                      = "data-persist-queue-${terraform.workspace}"
}



