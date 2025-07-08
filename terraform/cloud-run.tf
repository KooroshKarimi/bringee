# Cloud Run Services for Bringee microservices

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

      service_account_name = google_service_account.user_service_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.required_services
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

      service_account_name = google_service_account.shipment_service_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.required_services
  ]
}

# Service Accounts for Cloud Run services
resource "google_service_account" "user_service_sa" {
  account_id   = "user-service-sa"
  display_name = "Service Account for User Service"
  description  = "Service account for the user service Cloud Run instance"
}

resource "google_service_account" "shipment_service_sa" {
  account_id   = "shipment-service-sa"
  display_name = "Service Account for Shipment Service"
  description  = "Service account for the shipment service Cloud Run instance"
}

# Make Cloud Run services publicly accessible
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

# Outputs for service URLs
output "user_service_url" {
  value = google_cloud_run_service.user_service.status[0].url
}

output "shipment_service_url" {
  value = google_cloud_run_service.shipment_service.status[0].url
}