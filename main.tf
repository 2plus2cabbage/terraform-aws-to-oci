# Defines the Terraform provider and version requirements for the AWS deployment
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Specifies the AWS provider source
      version = ">= 5.0.0"       # Ensures a compatible provider version
    }
  }
}