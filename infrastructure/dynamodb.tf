resource "aws_dynamodb_table" "data_table" {
  name           = "data-table-${terraform.workspace}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "userId"
  range_key      = "timestamp"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}
