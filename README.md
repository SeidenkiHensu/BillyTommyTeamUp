# Project Goal Overview
This README is a walkthrough for a deployment with minimal downtime and fast rollback capability. This repo and demostration will take you on how a deployment goes from Github, utilizing Github Actions, AWS Services being created and established, and finally monitoring within AWS. Github Actions will showcase application deployments using infrastructure as code and a blue-green deployment strategy practice. This includes provisioning, deploying, creating monitoring, switching traffic, and rolling back all while using free-tier AWS services.

## Key Features
- ✅ **CI/CD Workflow:** Triggered by a GitHub push to `main` branch using GitHub Actions
- ✅ **Terraform-Based Provisioning:** EC2, IAM, Security Groups, Cloudwatch
- ✅ **Blue-Green Deployment & Rollback:** Switch traffic between two environments with ease to revert to previous environment
- ✅ **Zero-Downtime Rollouts:** Promote new version after testing
- ✅ **Free-Tier Friendly:** Uses AWS Free Tier services only to host the application environments
- ✅ **CloudWatch:** Dashboard monitoring and logging

## Tech Stack
| Tool             | Purpose                                 |
|------------------|------------------------------------------|
| GitHub Actions   | CI/CD automation for build & deployment |
| Terraform        | Infrastructure as Code (IaC)            |
| AWS EC2 (Free Tier) | Host the application environments       |
| IAM              | Secure AWS access via Terraform         |
| CloudWatch       | Monitoring and logging                  |

## Github Actions
This project uses GitHub Actions for CI/CD automation. The workflow is triggered on every push to the `main` branch.

### Github Actions Workflow
The workflow is defined in `.github/workflows/deploy.yml`. It performs the following steps:
1. Checks out the repository
2. Sets up Terraform
3. Initializes Terraform backend
4. Plans Terraform changes
5. Applies Terraform changes

## Terraform
Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share.

This project demonstrates a fully automated CI/CD pipeline for zero-downtime deployments using a blue-green deployment strategy on AWS EC2, managed by Terraform and triggered by GitHub Actions. Terraform is a form of IaC that allows you to build, change, and version infrastructure safely and efficiently.

### Terraform files:
- `main.tf`: Main configuration and provider setup
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `iam-users.tf`: Provision IAM users for EC2 management
- `terraform.tfvars`: Sets variables for Terraform and allows GitHub Actions to pick up variable values automatically
- `deploy.yml`: GitHub Actions workflow for CI/CD

For a more polished demo, I would also setup Modules so it could be more spread out and organized.

### Pipeline steps
1. Code push to `main` triggers the workflow.
2. Terraform provisions and updates infrastructure, maintaining both blue and green EC2 instances.
3. New code is deployed to the inactive environment (blue or green).
4. Automated tests run against the inactive environment.
5. If tests pass, the load balancer switches traffic to the new environment by updating the `active_env` variable and re-applying Terraform.
6. Outputs include the load balancer DNS and both EC2 public IPs for verification.

Checkout [this article](https://www.terraform.io/intro/index.html) for more information Terraform and it's many uses.

## AWS Services
This project uses AWS services EC2 establishing Instances, Security Groups, Network Interface, Load Balancer, Target Groups. For IAM, Users will be established. CloudWatch will have a dashboard and Log Groups for monitoring. VPC's will be established

### EC2
EC2 is used for hosting the application environments. Each environment is an EC2 instance, and the load balancer distributes traffic between them.

Checkout [this article](https://docs.aws.amazon.com/ec2/) for more information and it's uses.

### IAM
IAM is used for secure access to AWS resources. The IAM users are provisioned by Terraform and have the necessary permissions to manage EC2 resources.

Checkout [this article](https://docs.aws.amazon.com/iam/) for more information and it's uses.

### Cloudwatch
CloudWatch is used for monitoring dashboards and logging for the EC2 instances, load balancers, and other AWS resources.

Checkout [this article](https://docs.aws.amazon.com/cloudwatch/) for more information and it's uses.

### VPC
The Virtual Private Cloud (VPC) is where the AWS resources are launched. It provides a logically isolated section within the AWS cloud where you can launch resources in a custom network.

Checkout [this article](https://docs.aws.amazon.com/vpc/) for more information and it's uses.