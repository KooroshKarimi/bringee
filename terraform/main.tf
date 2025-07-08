terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "bringee-terraform-state-bucket-unique" # Needs to be globally unique and created beforehand
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

variable "gcp_project_id" {
  description = "The GCP project ID to deploy resources to."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources to."
  type        = string
  default     = "us-central1"
}

resource "google_project_service" "required_services" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "iamcredentials.googleapis.com"
  ])

  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = true
}