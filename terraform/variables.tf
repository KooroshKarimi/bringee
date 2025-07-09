variable "gcp_project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources to."
  type        = string
<<<<<<< HEAD
  default     = "europe-west3"
}

variable "github_repository" {
  description = "The GitHub repository in 'owner/repo' format."
=======
  default     = "us-central1"
}

variable "github_repository" {
  description = "The GitHub repository in 'owner/repo' format (e.g., 'your-username/bringee')."
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
  type        = string
}

variable "environment" {
<<<<<<< HEAD
  description = "The environment to deploy to (dev, staging, prod)."
=======
  description = "The deployment environment (dev, staging, prod)."
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
  type        = string
  default     = "dev"
}