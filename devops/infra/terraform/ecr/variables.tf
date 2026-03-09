variable "aws_region" {
  description = "AWS region for the ECR repository"
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}