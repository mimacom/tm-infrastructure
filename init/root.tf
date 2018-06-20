provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "mimacom"
  region = "eu-central-1"
}

resource "aws_s3_bucket" "terraform-state-s3-bucket" {
  bucket = "mimacom-tm-tfstate"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "S3 Remote Terraform State Store"
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "DynamoDB Terraform State Lock Table"
  }
}

