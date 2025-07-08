# 🚀 Automatische Deployment-Verbindung: GitHub ↔ Google Cloud Platform

Diese Anleitung beschreibt die vollständige Einrichtung einer automatischen CI/CD-Pipeline zwischen GitHub und Google Cloud Platform für das Bringee-Projekt.

## 📋 Übersicht

Die Pipeline bietet folgende Funktionen:

### ✅ Automatische Deployments
- **Trigger:** Push zu `main` oder `develop` Branch
- **Manueller Trigger:** GitHub Actions Workflow Dispatch
- **Umgebungen:** Staging und Production

### 🔒 Sicherheit
- **Workload Identity Federation:** Sichere Authentifizierung ohne Secrets
- **Vulnerability Scanning:** Trivy für Code und Docker Images
- **Security Scanning:** GitHub Security Tab Integration
- **Minimale Berechtigungen:** Principle of Least Privilege

### 🏗️ Infrastruktur
- **Cloud Run:** Serverless Container Deployment
- **Artifact Registry:** Sichere Docker Image Speicherung
- **Terraform:** Infrastructure as Code
- **Monitoring:** Cloud Monitoring und Logging

### 🔄 CI/CD Pipeline
- **Tests:** Automatische Tests bei jedem Push
- **Build:** Docker Images mit Buildx Cache
- **Deploy:** Zero-downtime Deployments
- **Health Checks:** Automatische Service-Validierung

## 🛠️ Schnelle Einrichtung

### Voraussetzungen

1. **Google Cloud SDK**
```bash
# Installation
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# Authentifizierung
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

2. **Terraform**
```bash
# Installation
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
```

3. **Docker**
```bash
# Installation
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
```

### Automatische Einrichtung

```bash
# Setup-Skript ausführbar machen
chmod +x setup-gcp-deployment.sh

# Setup ausführen
./setup-gcp-deployment.sh
```

Das Skript führt Sie durch alle notwendigen Schritte:

1. ✅ **Validierung:** Tools und Authentifizierung prüfen
2. 🏗️ **Infrastruktur:** Terraform State Bucket erstellen
3. 🔧 **APIs:** GCP APIs aktivieren
4. 🚀 **Deployment:** Infrastructure as Code anwenden
5. 🔐 **Secrets:** GitHub Secrets konfigurieren
6. 🧪 **Tests:** Deployment testen
7. 📚 **Dokumentation:** Status-Datei erstellen

## 🔧 Manuelle Einrichtung

### Schritt 1: GCP Projekt vorbereiten

```bash
# Neues Projekt erstellen (falls nötig)
gcloud projects create bringee-project --name="Bringee Project"
gcloud config set project bringee-project

# Billing aktivieren
gcloud billing projects link bringee-project --billing-account=YOUR_BILLING_ACCOUNT
```

### Schritt 2: Terraform State Bucket

```bash
# Bucket für Terraform State erstellen
BUCKET_NAME="bringee-terraform-state-$(date +%s)"
gsutil mb -p YOUR_PROJECT_ID -c STANDARD -l us-central1 gs://$BUCKET_NAME

# Bucket Name in terraform/main.tf aktualisieren
sed -i "s/bringee-terraform-state-bucket-unique/$BUCKET_NAME/" terraform/main.tf
```

### Schritt 3: Terraform konfigurieren

```bash
cd terraform

# terraform.tfvars erstellen
cat > terraform.tfvars << EOF
gcp_project_id = "YOUR_PROJECT_ID"
gcp_region     = "us-central1"
github_repository = "YOUR_GITHUB_USERNAME/bringee"
EOF

# Terraform initialisieren und anwenden
terraform init
terraform plan
terraform apply
```

### Schritt 4: GitHub Secrets konfigurieren

1. **Zu Ihrem GitHub Repository navigieren**
2. **Settings > Secrets and variables > Actions**
3. **Folgende Secrets hinzufügen:**

```
GCP_PROJECT_ID: YOUR_PROJECT_ID
GITHUB_ACTIONS_SA_EMAIL: [Aus Terraform Output]
WORKLOAD_IDENTITY_PROVIDER: [Aus Terraform Output]
```

### Schritt 5: Pipeline testen

```bash
# Commit und Push
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

## 🔄 Pipeline-Workflow

### GitHub Actions Workflow

Der Workflow (`/.github/workflows/ci-cd.yml`) führt folgende Schritte aus:

1. **Security Scan**
   - Trivy Vulnerability Scanner
   - Code und Docker Image Scanning
   - GitHub Security Tab Integration

2. **Test & Build**
   - Go Tests mit Coverage
   - Binary Build für Linux
   - Test Results Upload

3. **Docker Build & Push**
   - Multi-platform Build mit Buildx
   - Cache-Optimierung
   - Image Scanning
   - Push zu Artifact Registry

4. **Cloud Run Deployment**
   - Zero-downtime Deployment
   - Health Checks
   - Environment Variables
   - Auto-scaling

5. **Frontend Deployment** (optional)
   - Flutter Web Build
   - Firebase Hosting

6. **Notifications**
   - Deployment Status
   - PR Comments
   - GitHub Deployments API

### Workflow Trigger

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'staging'
        type: choice
        options: [staging, production]
```

## 🔒 Sicherheitsfeatures

### Workload Identity Federation

```hcl
# Terraform: terraform/iam.tf
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
```

### Minimale IAM-Berechtigungen

```hcl
# GitHub Actions Service Account
- roles/artifactregistry.writer
- roles/run.admin
- roles/iam.serviceAccountUser
- roles/storage.objectViewer

# Cloud Run Service Account
- roles/logging.logWriter
- roles/monitoring.metricWriter
```

## 📊 Monitoring & Logging

### Cloud Run Monitoring

```hcl
# Terraform: terraform/cloud-run.tf
resource "google_monitoring_alert_policy" "cloud_run_errors" {
  display_name = "Cloud Run Error Rate Alert"
  combiner     = "OR"
  conditions {
    display_name = "Error rate is high"
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_count\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 0.05
    }
  }
}
```

### Logging

```hcl
resource "google_logging_project_sink" "cloud_run_logs" {
  name        = "cloud-run-logs-sink"
  destination = "logging.googleapis.com/projects/${var.gcp_project_id}/locations/${var.gcp_region}/buckets/cloud-run-logs"
  filter      = "resource.type = cloud_run_revision"
}
```

## 🐛 Troubleshooting

### Häufige Probleme

#### 1. Terraform State Bucket nicht gefunden
```bash
# Bucket manuell erstellen
gsutil mb -p YOUR_PROJECT_ID gs://YOUR_BUCKET_NAME

# Bucket Name in terraform/main.tf aktualisieren
sed -i "s/bringee-terraform-state-bucket-unique/YOUR_BUCKET_NAME/" terraform/main.tf
```

#### 2. GitHub Actions Authentifizierung fehlschlägt
```bash
# Workload Identity Provider überprüfen
gcloud iam workload-identity-pools providers describe github-actions-provider \
  --location=global \
  --workload-identity-pool=github-actions-pool

# Service Account Berechtigungen prüfen
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:github-actions-runner"
```

#### 3. Docker Build fehlschlägt
```bash
# Dockerfile-Pfade überprüfen
ls -la backend/services/*/Dockerfile

# Docker Build lokal testen
docker build -t test-image backend/services/user-service/
```

#### 4. Cloud Run Deployment fehlschlägt
```bash
# Service Account Berechtigungen prüfen
gcloud run services describe user-service --region=us-central1

# Logs überprüfen
gcloud logging read "resource.type=cloud_run_revision" --limit=50
```

### Logs überprüfen

```bash
# Cloud Run Logs
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# GitHub Actions Logs
# Gehen Sie zu GitHub > Actions > Workflow > Job > Step

# Terraform Logs
terraform plan -detailed-exitcode
terraform apply -auto-approve
```

## 📈 Erweiterte Konfiguration

### Umgebungen hinzufügen

```yaml
# .github/workflows/ci-cd.yml
environment: ${{ github.event.inputs.environment || 'staging' }}

# Terraform: terraform/cloud-run.tf
env {
  name  = "ENVIRONMENT"
  value = "production"
}
```

### Services hinzufügen

1. **Neuen Service in terraform/cloud-run.tf hinzufügen:**
```hcl
resource "google_cloud_run_service" "new_service" {
  name     = "new-service"
  location = var.gcp_region
  # ... Konfiguration
}
```

2. **GitHub Actions Workflow erweitern:**
```yaml
strategy:
  matrix:
    service: [user-service, shipment-service, new-service]
```

### Monitoring erweitern

```hcl
# Custom Metrics
resource "google_monitoring_custom_service" "bringee_services" {
  service_id = "bringee-services"
  display_name = "Bringee Services"
}

# Alerting Policies
resource "google_monitoring_alert_policy" "custom_alert" {
  display_name = "Custom Service Alert"
  # ... Konfiguration
}
```

## 🔄 Deployment-Strategien

### Blue-Green Deployment

```yaml
# GitHub Actions
- name: Deploy Blue Environment
  run: |
    gcloud run deploy user-service-blue \
      --image $IMAGE_TAG \
      --region $REGION

- name: Switch Traffic
  run: |
    gcloud run services update-traffic user-service \
      --to-revisions=user-service-blue=100
```

### Canary Deployment

```yaml
# Traffic Splitting
- name: Deploy Canary
  run: |
    gcloud run services update-traffic user-service \
      --to-revisions=user-service-canary=10,user-service-stable=90
```

## 📚 Nützliche Befehle

### GCP Befehle

```bash
# Service Status prüfen
gcloud run services list --region=us-central1

# Logs anzeigen
gcloud logging read "resource.type=cloud_run_revision" --limit=10

# Service Account prüfen
gcloud iam service-accounts list

# Workload Identity prüfen
gcloud iam workload-identity-pools list --location=global
```

### Terraform Befehle

```bash
# Status prüfen
terraform plan

# Änderungen anwenden
terraform apply

# Outputs anzeigen
terraform output

# State prüfen
terraform show
```

### GitHub CLI Befehle

```bash
# Secrets setzen
gh secret set GCP_PROJECT_ID --repo owner/repo --body "project-id"

# Workflow ausführen
gh workflow run ci-cd.yml --field environment=production

# Runs anzeigen
gh run list --workflow=ci-cd.yml
```

## 🎉 Nächste Schritte

Nach erfolgreicher Einrichtung:

1. **Frontend Deployment:** Flutter App zu Firebase Hosting deployen
2. **Database Setup:** Cloud SQL oder Firestore konfigurieren
3. **CDN Setup:** Cloud CDN für bessere Performance
4. **SSL Certificates:** Automatische SSL-Zertifikate
5. **Backup Strategy:** Automatische Backups konfigurieren
6. **Cost Optimization:** Resource Limits und Budget Alerts

## 📞 Support

Bei Problemen:

1. **Logs überprüfen:** GitHub Actions und Cloud Run Logs
2. **Berechtigungen prüfen:** IAM und Service Accounts
3. **Infrastruktur validieren:** Terraform State und GCP Resources
4. **Secrets überprüfen:** GitHub Secrets und GCP Service Accounts

---

**Happy Deploying! 🚀**

Diese Pipeline bietet eine robuste, sichere und skalierbare Lösung für automatische Deployments zwischen GitHub und Google Cloud Platform.