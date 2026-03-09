terraform {
  required_version = ">= 1.0, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "backend" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true  # prevent accidental deletion
  }
}

output "repository_url" {
  description = "The full URL of the ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}