# Setting up IAM Users
resource "aws_iam_user" "project_users" {
  count = length(var.user_name)
  name  = var.user_name[count.index]

  # Prevent user from being deleted and ignore changes if the user already exists
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name]
  }
}

# Setting up IAM User Policy Attachments. This will attach the AmazonEC2FullAccess policy to the user
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  count      = length(var.user_name)
  user       = aws_iam_user.project_users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Setting up IAM Access Keys
resource "aws_iam_access_key" "user_keys" {
  count = length(var.user_name)
  user  = aws_iam_user.project_users[count.index].name
}

# Setting up IAM Access Key Outputs
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