# GitHub-GCP Connection für automatisches Deployment

## 🎯 Übersicht

Diese Dokumentation beschreibt die vollständige Einrichtung einer automatischen Deployment-Pipeline zwischen GitHub und Google Cloud Platform (GCP) für das Bringee-Projekt.

## 🔗 Verbindungskomponenten

### 1. GitHub Actions Workflow
- **Datei**: `.github/workflows/ci-cd.yml`
- **Trigger**: Push auf `main` Branch
- **Jobs**:
  - Tests und Build der Backend-Services
  - Docker Images erstellen und zu Artifact Registry pushen
  - Automatisches Deployment zu Cloud Run

### 2. Workload Identity Federation
- **Zweck**: Sichere Authentifizierung zwischen GitHub Actions und GCP
- **Konfiguration**: Automatisch in `terraform/iam.tf`
- **Provider**: `projects/[PROJECT_ID]/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider`

### 3. Google Cloud Services
- **Artifact Registry**: Docker Images Storage
- **Cloud Run**: Container-Deployment
- **IAM**: Service Accounts und Berechtigungen
- **Terraform**: Infrastructure as Code

## 🚀 Schnelle Einrichtung

### Option 1: Automatisches Setup (Empfohlen)

```bash
# 1. Setup-Skript ausführbar machen
chmod +x setup-github-gcp-connection.sh

# 2. Setup ausführen
./setup-github-gcp-connection.sh
```

### Option 2: Manuelle Einrichtung

```bash
# 1. GCP authentifizieren
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# 2. APIs aktivieren
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable iamcredentials.googleapis.com

# 3. Terraform ausführen
cd terraform
terraform init
terraform apply
cd ..

# 4. GitHub Secrets konfigurieren
# Gehen Sie zu GitHub > Repository > Settings > Secrets > Actions
# Fügen Sie hinzu:
# - GCP_PROJECT_ID: [Ihr GCP Project ID]
# - GITHUB_ACTIONS_SA_EMAIL: [Aus Terraform Output]
```

## 🔧 Konfiguration

### GitHub Secrets

Die folgenden Secrets müssen in GitHub konfiguriert werden:

| Secret | Beschreibung | Wert |
|--------|-------------|------|
| `GCP_PROJECT_ID` | Google Cloud Project ID | `your-project-id` |
| `GITHUB_ACTIONS_SA_EMAIL` | Service Account Email | `github-actions-runner@your-project-id.iam.gserviceaccount.com` |

### Workload Identity Provider

Der Workload Identity Provider wird automatisch von Terraform erstellt:

```
projects/[PROJECT_ID]/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider
```

### Service Accounts

1. **GitHub Actions Service Account**:
   - Name: `github-actions-runner`
   - Berechtigungen: Artifact Registry Writer, Cloud Run Admin

2. **Cloud Run Service Account**:
   - Name: `cloud-run-sa`
   - Berechtigungen: Logging Writer, Monitoring Writer

## 🔄 Deployment-Pipeline

### 1. Trigger
- Push auf `main` Branch
- Pull Request auf `main` Branch (nur Tests)

### 2. Tests
```yaml
test-and-build-backend:
  - Go Tests für user-service und shipment-service
  - Build der Services
```

### 3. Docker Build & Push
```yaml
build-and-push-docker:
  - Authentifizierung mit GCP via Workload Identity
  - Docker Images erstellen
  - Push zu Artifact Registry
```

### 4. Deployment
```yaml
deploy-to-cloud-run:
  - Cloud Run Services aktualisieren
  - Neue Images deployen
  - Traffic auf neue Revision umleiten
```

## 🧪 Testing

### Verbindung testen

```bash
# Überprüfung der GitHub-GCP-Verbindung
./verify-github-gcp-connection.sh
```

### Deployment testen

```bash
# Commit und Push zum Testen
git add .
git commit -m "Test automatic deployment"
git push origin main
```

### Services testen

```bash
# Service URLs abrufen
cd terraform
terraform output user_service_url
terraform output shipment_service_url
cd ..

# Services testen
curl [USER_SERVICE_URL]/health
curl [SHIPMENT_SERVICE_URL]/health
```

## 📊 Monitoring

### GitHub Actions
- **URL**: `https://github.com/[REPO]/actions`
- **Monitoring**: Workflow Runs, Job Logs, Artifacts

### Google Cloud Console
- **Cloud Run**: `https://console.cloud.google.com/run`
- **Artifact Registry**: `https://console.cloud.google.com/artifacts`
- **Logs**: `https://console.cloud.google.com/logs`

### Logs überprüfen

```bash
# Cloud Run Logs
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# GitHub Actions Logs
# Gehen Sie zu GitHub > Actions > Workflow > Job > Step
```

## 🔒 Sicherheit

### Workload Identity Federation
- ✅ Keine statischen Credentials
- ✅ Temporäre Tokens
- ✅ Repository-spezifische Berechtigungen
- ✅ Automatische Rotation

### IAM Best Practices
- ✅ Minimal Privilege Principle
- ✅ Service Accounts für spezifische Zwecke
- ✅ Keine User-Accounts für Automatisierung

### Netzwerk-Sicherheit
- ✅ HTTPS für alle Services
- ✅ Cloud Run mit Authentifizierung (optional)
- ✅ Private Artifact Registry (konfigurierbar)

## 🐛 Troubleshooting

### Häufige Probleme

#### 1. Authentifizierung fehlschlägt
```bash
# Überprüfen Sie die Workload Identity Konfiguration
gcloud iam workload-identity-pools list --location=global

# Überprüfen Sie die GitHub Secrets
gh secret list --repo [REPO]
```

#### 2. Docker Build fehlschlägt
```bash
# Überprüfen Sie die Dockerfile-Pfade
ls -la backend/services/*/Dockerfile

# Testen Sie das Docker Build lokal
docker build -t test backend/services/user-service/
```

#### 3. Cloud Run Deployment fehlschlägt
```bash
# Überprüfen Sie die Service Account Berechtigungen
gcloud projects get-iam-policy [PROJECT_ID] --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:github-actions-runner"
```

#### 4. Terraform State Probleme
```bash
# Überprüfen Sie den Terraform State Bucket
gsutil ls gs://[BUCKET_NAME]

# Terraform neu initialisieren
cd terraform
terraform init -reconfigure
```

### Debugging

#### GitHub Actions Debugging
```yaml
# In .github/workflows/ci-cd.yml hinzufügen:
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

#### GCP Debugging
```bash
# Cloud Run Logs in Echtzeit
gcloud logging tail "resource.type=cloud_run_revision"

# IAM Policy überprüfen
gcloud projects get-iam-policy [PROJECT_ID]
```

## 📈 Erweiterungen

### Neue Services hinzufügen

1. **Terraform erweitern** (`terraform/cloud-run.tf`):
```hcl
resource "google_cloud_run_service" "new_service" {
  name     = "new-service"
  location = var.gcp_region
  # ... Konfiguration
}
```

2. **GitHub Actions erweitern** (`.github/workflows/ci-cd.yml`):
```yaml
strategy:
  matrix:
    service: [user-service, shipment-service, new-service]
```

3. **Dockerfile erstellen**:
```dockerfile
# backend/services/new-service/Dockerfile
FROM golang:1.22-alpine
# ... Konfiguration
```

### Umgebung anpassen

#### Region ändern
```bash
# In terraform/terraform.tfvars
gcp_region = "europe-west1"
```

#### Ressourcen anpassen
```hcl
# In terraform/cloud-run.tf
resources {
  limits = {
    cpu    = "2000m"
    memory = "1Gi"
  }
}
```

#### Autoscaling konfigurieren
```yaml
# In .github/workflows/ci-cd.yml
--max-instances 20
--min-instances 1
```

## 📞 Support

### Nützliche Befehle

```bash
# Status überprüfen
./verify-github-gcp-connection.sh

# Setup ausführen
./setup-github-gcp-connection.sh

# Terraform Status
cd terraform && terraform plan

# GCP Services auflisten
gcloud run services list
gcloud artifacts repositories list
```

### Dokumentation
- [GitHub Actions](https://docs.github.com/en/actions)
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 🎉 Erfolg!

Nach erfolgreicher Einrichtung haben Sie:

✅ **Automatisches Deployment** bei jedem Push auf main  
✅ **Sichere Authentifizierung** via Workload Identity Federation  
✅ **Infrastructure as Code** mit Terraform  
✅ **Container-Deployment** zu Cloud Run  
✅ **Docker Image Management** in Artifact Registry  
✅ **Monitoring und Logging** in Google Cloud Console  

Ihre GitHub-GCP-Verbindung ist jetzt bereit für automatisches Deployment! 🚀