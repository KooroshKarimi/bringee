<<<<<<< HEAD
# Cloud Run Services for Bringee
=======
# Cloud Run Services for Bringee microservices

# User Service
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
resource "google_cloud_run_service" "user_service" {
  name     = "user-service"
  location = var.gcp_region

  template {
    spec {
      containers {
<<<<<<< HEAD
        image = "europe-west3-docker.pkg.dev/${var.gcp_project_id}/bringee-artifacts/user-service:latest"
=======
        image = "us-central1-docker.pkg.dev/${var.gcp_project_id}/bringee-artifacts/user-service:latest"
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
        
        ports {
          container_port = 8080
        }
<<<<<<< HEAD
        
=======

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
<<<<<<< HEAD
        
=======

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
        env {
          name  = "PORT"
          value = "8080"
        }
      }
<<<<<<< HEAD
      
=======

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
      service_account_name = google_service_account.user_service_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
<<<<<<< HEAD
    google_project_service.required_services,
    google_artifact_registry_repository.bringee_repo
  ]
}

=======
    google_project_service.required_services
  ]
}

# Shipment Service
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
resource "google_cloud_run_service" "shipment_service" {
  name     = "shipment-service"
  location = var.gcp_region

  template {
    spec {
      containers {
<<<<<<< HEAD
        image = "europe-west3-docker.pkg.dev/${var.gcp_project_id}/bringee-artifacts/shipment-service:latest"
=======
        image = "us-central1-docker.pkg.dev/${var.gcp_project_id}/bringee-artifacts/shipment-service:latest"
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
        
        ports {
          container_port = 8080
        }
<<<<<<< HEAD
        
=======

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
<<<<<<< HEAD
        
=======

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
        env {
          name  = "PORT"
          value = "8080"
        }
      }
<<<<<<< HEAD
      
=======

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
      service_account_name = google_service_account.shipment_service_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
<<<<<<< HEAD
    google_project_service.required_services,
    google_artifact_registry_repository.bringee_repo
  ]
}

# Service Accounts for Cloud Run Services
resource "google_service_account" "user_service_sa" {
  account_id   = "user-service-sa"
  display_name = "User Service Service Account"
  description  = "Service account for user-service Cloud Run"
=======
    google_project_service.required_services
  ]
}

# Service Accounts for Cloud Run services
resource "google_service_account" "user_service_sa" {
  account_id   = "user-service-sa"
  display_name = "Service Account for User Service"
  description  = "Service account for the user service Cloud Run instance"
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
}

resource "google_service_account" "shipment_service_sa" {
  account_id   = "shipment-service-sa"
<<<<<<< HEAD
  display_name = "Shipment Service Service Account"
  description  = "Service account for shipment-service Cloud Run"
}

# Grant necessary permissions to Cloud Run service accounts
resource "google_project_iam_member" "user_service_sa_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.user_service_sa.email}"
}

resource "google_project_iam_member" "user_service_sa_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.user_service_sa.email}"
}

resource "google_project_iam_member" "shipment_service_sa_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.shipment_service_sa.email}"
}

resource "google_project_iam_member" "shipment_service_sa_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.shipment_service_sa.email}"
}

# IAM bindings for Cloud Run services to be publicly accessible
=======
  display_name = "Service Account for Shipment Service"
  description  = "Service account for the shipment service Cloud Run instance"
}

# Make Cloud Run services publicly accessible
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
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