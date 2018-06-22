resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/tm/"
}

data "aws_iam_user" "root" {
  user_name = "ivan.greguricortolan"
}

resource "aws_iam_user_group_membership" "root_membership" {
  groups = [
    "${aws_iam_group.developers.name}"
  ]
  user = "${data.aws_iam_user.root.user_name}"
}
