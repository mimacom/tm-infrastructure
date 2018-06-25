variable "iam_user_group" {
  description = "The group of users to pick"
}

variable "aws_cli_profile" {
  description = "The aws profile to use to log in"
}

variable "join_groups" {
  type        = "list"
  description = "The groups the users will be associated with"
}
