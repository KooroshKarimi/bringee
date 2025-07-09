variable "gcp_project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources to."
  type        = string
  default     = "europe-west3"
}

variable "github_repository" {
  description = "The GitHub repository in 'owner/repo' format."
  type        = string
}

variable "environment" {
  description = "The environment to deploy to (dev, staging, prod)."
  type        = string
  default     = "dev"
}