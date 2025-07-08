resource "google_artifact_registry_repository" "bringee_repo" {
  provider      = google-beta
  location      = var.gcp_region
  repository_id = "bringee-artifacts"
  description   = "Docker repository for Bringee microservices"
  format        = "DOCKER"

  depends_on = [
    google_project_service.required_services
  ]
}