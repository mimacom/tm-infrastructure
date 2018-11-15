provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "mimacom"
  region                  = "eu-central-1"
}

resource "aws_s3_bucket" "terraform-state" {

  bucket = "mimacom-tm-terraform-state"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    prefix = ""
    noncurrent_version_expiration {
      days = 10
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "mimacom-tm-terraform-state"
    Environment = "global"
    App = "state"
  }
}

resource "aws_dynamodb_table" "terraform-state-lock" {

  name           = "terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-state-lock"
    Environment = "global"
    App = "state"
  }
}
