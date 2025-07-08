variable "gcp_project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources to."
  type        = string
  default     = "us-central1"
}

variable "github_repository" {
  description = "The GitHub repository in 'owner/repo' format (e.g., 'your-username/bringee')."
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)."
  type        = string
  default     = "dev"
}