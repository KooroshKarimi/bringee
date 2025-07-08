# Enhanced IAM Configuration for GitHub Actions and Cloud Run
# Provides secure authentication and minimal required permissions

# Service Account for GitHub Actions
resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-runner"
  display_name = "Service Account for GitHub Actions"
  description  = "Allows GitHub Actions to deploy to Cloud Run and push to Artifact Registry"
}

# Service Account for Cloud Run services
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-services"
  display_name = "Service Account for Cloud Run Services"
  description  = "Service account used by Cloud Run services"
}

# Grant Artifact Registry Writer role to the GitHub Actions Service Account
resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Cloud Run Admin role to the GitHub Actions Service Account
resource "google_project_iam_member" "cloud_run_admin" {
  project = var.gcp_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Service Account User role to allow GitHub Actions SA to act as Cloud Run SA
resource "google_project_iam_member" "service_account_user" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Storage Object Viewer for GitHub Actions (for reading Terraform state)
resource "google_project_iam_member" "storage_object_viewer" {
  project = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Logging Writer to Cloud Run Service Account
resource "google_project_iam_member" "cloud_run_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Grant Monitoring Metric Writer to Cloud Run Service Account
resource "google_project_iam_member" "cloud_run_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Workload Identity Federation for GitHub Actions
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Pool for GitHub Actions runners"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
    "attribute.sha"        = "assertion.sha"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    allowed_audiences = ["https://token.actions.githubusercontent.com"]
  }
}

# Allow the GitHub Actions SA to be impersonated by GitHub Actions runners
resource "google_service_account_iam_member" "github_actions_impersonation" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
}

# Allow GitHub Actions to impersonate Cloud Run Service Account
resource "google_service_account_iam_member" "cloud_run_impersonation" {
  service_account_id = google_service_account.cloud_run_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Variables
variable "github_repository" {
  description = "The GitHub repository in 'owner/repo' format."
  type        = string
}

# Outputs
output "github_actions_sa_email" {
  value = google_service_account.github_actions_sa.email
}

output "cloud_run_sa_email" {
  value = google_service_account.cloud_run_sa.email
}

output "workload_identity_provider" {
  value = "projects/${var.gcp_project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
}