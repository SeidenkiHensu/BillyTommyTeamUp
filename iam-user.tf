# Creating up IAM Users
resource "aws_iam_user" "project_users" {
  for_each = {
    for name in var.user_name : name => name if !(name in var.existing_users)
  }
  
  name = each.value

  # Prevent user from being deleted and ignore changes if the user already exists
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name]
  }
}

/*# Setting up IAM User Policy Attachments. This will attach the AmazonEC2FullAccess policy to the user
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  count      = length(var.user_name)
  user       = aws_iam_user.project_users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Setting up IAM Access Keys
resource "aws_iam_access_key" "user_keys" {
  count = length(var.user_name)
  user  = aws_iam_user.project_users[count.index].name
}*/

# Setting up IAM User Policy Attachments. This will attach the AmazonEC2FullAccess policy to the user
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  for_each = aws_iam_user.project_users
  user       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Setting up IAM Access Keys
resource "aws_iam_access_key" "user_keys" {
  for_each = aws_iam_user.project_users
  user = each.value.name
}

# Setting up IAM Access Key Outputs. This is just for demo purposes. In a real world scenario, we would be using secrets manager to store the access keys.
output "iam_user_access_keys" {
  description = "Access keys for provisioned IAM users."
  value = {
    for name, key in aws_iam_access_key.user_keys :
    name => {
      access_key_id     = key.id
      secret_access_key = key.secret
    }
  }
  sensitive = true
}

/*output "iam_user_access_keys" {
  description = "Access keys for provisioned IAM users."
  value = {
    for name, user in aws_iam_access_key.user_keys :
    name => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true
}*/