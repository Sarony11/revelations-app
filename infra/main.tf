provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "users" {
  name           = "users"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "question_packs" {
  name           = "question_packs"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "PackID"

  attribute {
    name = "PackID"
    type = "S"
  }
}

resource "null_resource" "data_ingestion" {
  # This is a hack to get around the fact that Terraform doesn't support
  # What we do is to ingest data in the different DynamoDB tables.
  provisioner "local-exec" {
    command = <<EOT
      make -f Makefile setup;
      make -f Makefile run;
    EOT
    working_dir = "./data"
  }
  depends_on = [
    aws_dynamodb_table.users,
    aws_dynamodb_table.question_packs
  ]
}