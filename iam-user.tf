# Creating IAM Users
resource "aws_iam_user" "project_users" {
  for_each = {
    for name in var.user_name : name => name
    if !contains(var.existing_users, name)
  }

  name = each.value

  # Prevents user from being deleted and ignoring changes if the user already exists
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name]
  }
}

# Setting up IAM User Policy Attachments. This will attach the AmazonEC2FullAccess policy to the user
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  for_each   = aws_iam_user.project_users
  user       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Setting up IAM Access Keys
resource "aws_iam_access_key" "user_keys" {
  for_each = aws_iam_user.project_users
  user     = each.value.name
}

resource "aws_ssm_parameter" "iam_user_access_keys" {
  for_each = aws_iam_access_key.user_keys

  name = "/BillyTommyTeamUp/${var.environment}/iam/${each.key}"
  type = "SecureString"
  value = jsonencode({
    access_key_id     = each.value.id
    secret_access_key = each.value.secret
  })

  tags = {
    Project     = "BillyTommyTeamUp"
    Environment = var.environment
    User        = each.key
  }
}
