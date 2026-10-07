variable "region" {
  description = "AWS region for the S3 bucket and provider"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name, used as a prefix for resource names and in tags"
  type        = string
  default     = "oriko-project"
}

variable "environment" {
  description = "Deployment environment (e.g. production, staging)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Optional custom domain for the site. Leave empty to use the default CloudFront domain. Wiring a custom domain also requires an ACM certificate in us-east-1."
  type        = string
  default     = ""
}
