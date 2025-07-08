# Cloud Run Services Configuration
# Enhanced configuration with better scaling, monitoring, and security

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
            memory = "1Gi"
          }
          requests = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }

        env {
          name  = "ENVIRONMENT"
          value = "production"
        }
        
        env {
          name  = "SERVICE_NAME"
          value = "user-service"
        }

        # Health check configuration
        liveness_probe {
          http_get {
            path = "/health"
          }
          initial_delay_seconds = 30
          period_seconds        = 10
          timeout_seconds       = 5
          failure_threshold     = 3
        }

        readiness_probe {
          http_get {
            path = "/health"
          }
          initial_delay_seconds = 5
          period_seconds        = 5
          timeout_seconds       = 3
          failure_threshold     = 3
        }
      }

      # Service account for the container
      service_account_name = google_service_account.cloud_run_sa.email

      # Container concurrency
      container_concurrency = 80
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "10"
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/cpu-throttling" = "false"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
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
            memory = "1Gi"
          }
          requests = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }

        env {
          name  = "ENVIRONMENT"
          value = "production"
        }
        
        env {
          name  = "SERVICE_NAME"
          value = "shipment-service"
        }

        # Health check configuration
        liveness_probe {
          http_get {
            path = "/health"
          }
          initial_delay_seconds = 30
          period_seconds        = 10
          timeout_seconds       = 5
          failure_threshold     = 3
        }

        readiness_probe {
          http_get {
            path = "/health"
          }
          initial_delay_seconds = 5
          period_seconds        = 5
          timeout_seconds       = 3
          failure_threshold     = 3
        }
      }

      # Service account for the container
      service_account_name = google_service_account.cloud_run_sa.email

      # Container concurrency
      container_concurrency = 80
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "10"
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/cpu-throttling" = "false"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

# Service Account for Cloud Run services
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-services"
  display_name = "Service Account for Cloud Run Services"
  description  = "Service account used by Cloud Run services"
}

# IAM policy for Cloud Run services
resource "google_cloud_run_service_iam_member" "public_access" {
  for_each = toset([
    google_cloud_run_service.user_service.name,
    google_cloud_run_service.shipment_service.name
  ])
  
  location = google_cloud_run_service.user_service.location
  service  = google_cloud_run_service.user_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Cloud Run service outputs
output "user_service_url" {
  value = google_cloud_run_service.user_service.status[0].url
}

output "shipment_service_url" {
  value = google_cloud_run_service.shipment_service.status[0].url
}

# Monitoring and logging
resource "google_logging_project_sink" "cloud_run_logs" {
  name        = "cloud-run-logs-sink"
  destination = "logging.googleapis.com/projects/${var.gcp_project_id}/locations/${var.gcp_region}/buckets/cloud-run-logs"
  filter      = "resource.type = cloud_run_revision"
}

# Cloud Monitoring alerting policy
resource "google_monitoring_alert_policy" "cloud_run_errors" {
  display_name = "Cloud Run Error Rate Alert"
  combiner     = "OR"
  conditions {
    display_name = "Error rate is high"
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 0.05
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# Email notification channel
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  
  labels = {
    email_address = "admin@bringee.com"
  }
}