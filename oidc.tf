# Pulls the AWS account ID dynamically to avoid exposing the account ID in a public repo
data "aws_caller_identity" "current" {}

# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Project     = "BillyTommyTeamUp"
    Environment = var.environment
  }
}

# Checks job role — read-only
resource "aws_iam_role" "github_actions_checks" {
  name = "bttu-github-actions-checks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:SeidenkiHensu/BillyTommyTeamUp:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Project     = "BillyTommyTeamUp"
    Environment = var.environment
  }
}

# Deploy job role — write access
resource "aws_iam_role" "github_actions_deploy" {
  name = "bttu-github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:SeidenkiHensu/BillyTommyTeamUp:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Project     = "BillyTommyTeamUp"
    Environment = var.environment
  }
}

# Checks policy — read-only across what the pipeline touches
resource "aws_iam_role_policy" "checks_policy" {
  name = "bttu-checks-policy"
  role = aws_iam_role.github_actions_checks.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "elasticloadbalancing:Describe*",
          "iam:Get*",
          "iam:List*",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:Describe*",
          "logs:Get*",
          "logs:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Deploy policy — full write access across what the pipeline touches
resource "aws_iam_role_policy" "deploy_policy" {
  name = "bttu-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "iam:*",
          "ssm:*",
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Output the role ARNs so deploy.yml can reference them easily
output "checks_role_arn" {
  description = "IAM role ARN for the GitHub Actions checks job"
  value       = aws_iam_role.github_actions_checks.arn
}

output "deploy_role_arn" {
  description = "IAM role ARN for the GitHub Actions deploy job"
  value       = aws_iam_role.github_actions_deploy.arn
}
