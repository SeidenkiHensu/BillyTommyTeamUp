resource "aws_iam_user" "project_users" {
  count = length(var.user_name)
  name  = var.user_name[count.index]
}

resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  count      = length(var.user_name)
  user       = aws_iam_user.project_users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_access_key" "user_keys" {
  count = length(var.user_name)
  user  = aws_iam_user.project_users[count.index].name
}

output "iam_user_access_keys" {
  description = "Access keys for provisioned IAM users."
  value = {
    for idx, user in aws_iam_user.project_users :
    user.name => {
      access_key_id     = aws_iam_access_key.user_keys[idx].id
      secret_access_key = aws_iam_access_key.user_keys[idx].secret
    }
  }
  sensitive = true
}