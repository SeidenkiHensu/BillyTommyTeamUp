# Project Goal Overview
This README is a walkthrough for a deployment with minimal downtime and fast rollback capability. This repo and demostration will take you on how a deployment goes from Github, utilizing Github Actions, AWS Services, and finally monitoring. 

Within this repository, I will automate application deployments using infrastructure as code and a blue-green deployment strategy practice. This includes provisioning, deploying, switching traffic, and rolling back all while using free-tier AWS services.

## Key Features
- ✅ **CI/CD Workflow:** Triggered by a GitHub push to `main` branch using GitHub Actions
- ✅ **Terraform-Based Provisioning:** EC2, IAM, Security Groups
- ✅ **Blue-Green Deployment:** Switch traffic between two environments
- ✅ **Zero-Downtime Rollouts:** Promote new version after testing
- ✅ **Rollback Support:** Easily revert to previous environment
- ✅ **Free-Tier Friendly:** Uses AWS Free Tier services only to host the application environments
- ✅ **Flask (Python):** Lightweight web application
- ✅ **Cloud-Init:** Auto-configure EC2 instances at boot

## Tech Stack
| Tool             | Purpose                                 |
|------------------|------------------------------------------|
| GitHub Actions   | CI/CD automation for build & deployment |
| Terraform        | Infrastructure as Code (IaC)            |
| AWS EC2 (Free Tier) | Host the application environments       |
| IAM              | Secure AWS access via Terraform         |
| Flask (Python)   | Lightweight web application              |
| Cloud-Init       | Auto-configure EC2 instances at boot    |

## Terraform
This project demonstrates a fully automated CI/CD pipeline for zero-downtime deployments using a blue-green deployment strategy on AWS EC2, managed by Terraform and triggered by GitHub Actions. Terraform is a form of IaC that allows you to build, change, and version infrastructure safely and efficiently.

### Terraform files:
- `main.tf`: Main configuration and provider setup
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `iam-users.tf`: Provision IAM users for EC2 management
- `terraform.tfvars`: Sets variables for Terraform and allows GitHub Actions to pick up variable values automatically
- `deploy.yml`: GitHub Actions workflow for CI/CD


### Pipeline steps
1. Code push to `main` triggers the workflow.
2. Terraform provisions and updates infrastructure, maintaining both blue and green EC2 instances.
3. New code is deployed to the inactive environment (blue or green).
4. Automated tests run against the inactive environment.
5. If tests pass, the load balancer switches traffic to the new environment by updating the `active_env` variable and re-applying Terraform.
6. Outputs include the load balancer DNS and both EC2 public IPs for verification.

Checkout [this article](https://www.terraform.io/intro/index.html) for more information Terraform and it's many uses.

## AWS Services
This project uses AWS EC2 for hosting the application environments, IAM for secure access, and Cloud-Init for auto-configuration at boot.

### EC2
EC2 is used for hosting the application environments. Each environment is an EC2 instance, and the load balancer distributes traffic between them.

### IAM
IAM is used for secure access to AWS resources. The IAM users are provisioned by Terraform and have the necessary permissions to manage EC2 resources.

### Cloud-Init
Cloud-Init is used for auto-configuration at boot. It allows you to run custom scripts and packages during the instance initialization process. 
