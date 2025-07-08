# Cloud Run Services for automatic deployment

# User Service
resource "google_cloud_run_service" "user_service" {
  name     = "user-service"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.gcp_project_id}/bringee-artifacts/user-service:latest"
        
        ports {
          container_port = 8080
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        env {
          name  = "PORT"
          value = "8080"
        }
      }

      service_account_name = google_service_account.cloud_run_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.required_services,
    google_artifact_registry_repository.bringee_repo
  ]
}

# Shipment Service
resource "google_cloud_run_service" "shipment_service" {
  name     = "shipment-service"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/${var.gcp_project_id}/bringee-artifacts/shipment-service:latest"
        
        ports {
          container_port = 8080
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        env {
          name  = "PORT"
          value = "8080"
        }
      }

      service_account_name = google_service_account.cloud_run_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.required_services,
    google_artifact_registry_repository.bringee_repo
  ]
}

# Service Account for Cloud Run services
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Service Account for Cloud Run services"
  description  = "Service account used by Cloud Run services"
}

# Grant necessary permissions to Cloud Run service account
resource "google_project_iam_member" "cloud_run_sa_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_run_sa_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Make services publicly accessible
resource "google_cloud_run_service_iam_member" "user_service_public" {
  location = google_cloud_run_service.user_service.location
  service  = google_cloud_run_service.user_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "shipment_service_public" {
  location = google_cloud_run_service.shipment_service.location
  service  = google_cloud_run_service.shipment_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Outputs for the service URLs
output "user_service_url" {
  value = google_cloud_run_service.user_service.status[0].url
}

output "shipment_service_url" {
  value = google_cloud_run_service.shipment_service.status[0].url
}