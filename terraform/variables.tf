variable "gcp_project_id" {
  description = "Die GCP Project ID, in die deployt werden soll."
  type        = string
}

variable "gcp_region" {
  description = "Die GCP Region für die Ressourcen (z.B. europe-west3)."
  type        = string
  default     = "europe-west3"
}

variable "github_repository" {
  description = "Das GitHub Repository im Format 'owner/repo' (z.B. 'your-username/bringee')."
  type        = string
}

variable "environment" {
  description = "Die Umgebung für das Deployment (dev, staging, prod)."
  type        = string
  default     = "dev"
}