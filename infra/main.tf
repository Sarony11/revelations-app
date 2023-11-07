provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "users" {
  name           = "users"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "question_packs" {
  name           = "question_packs"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "question_categories" {
  name           = "question_categories"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "questions" {
  name           = "questions"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "null_resource" "data_ingestion" {
  provisioner "local-exec" {
    command = <<EOT
      make -f Makefile setup;
      make -f Makefile run;
      make -f Makefile delete;
    EOT
    working_dir = "./data"
  }
}