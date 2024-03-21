# Description: This file is used to create the DynamoDB table used to store the state of the step function.

resource "aws_dynamodb_table" "dynamodbTable" {
  name           = local.name_cc
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "dbinstance"
  range_key      = "restoredate"

  attribute {
    name = "dbinstance"
    type = "S"
  }

  attribute {
    name = "restoredate"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
