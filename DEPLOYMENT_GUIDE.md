# Bringee GCP Deployment Guide

Diese Anleitung führt Sie durch die Einrichtung einer vollständigen CI/CD-Pipeline für Ihr Bringee-Projekt mit Google Cloud Platform.

## 🎯 Übersicht

Die Pipeline automatisiert folgende Schritte:
1. **Tests**: Automatische Tests bei jedem Push
2. **Build**: Docker-Images erstellen
3. **Push**: Images zu Google Artifact Registry pushen
4. **Deploy**: Automatisches Deployment zu Cloud Run

## 📋 Voraussetzungen

### 1. Google Cloud SDK installieren
```bash
# Für Ubuntu/Debian
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli

# Für macOS
brew install google-cloud-sdk

# Authentifizierung
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Terraform installieren
```bash
# Für Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Für macOS
brew install terraform
```

## 🚀 Schnelle Einrichtung

### Option 1: Automatisches Setup (Empfohlen)

1. **Setup-Skript ausführbar machen:**
```bash
chmod +x setup-gcp-deployment.sh
```

2. **Setup ausführen:**
```bash
./setup-gcp-deployment.sh
```

Das Skript führt Sie durch alle notwendigen Schritte.

### Option 2: Manuelle Einrichtung

## 🔧 Manuelle Einrichtung

### Schritt 1: GCP Projekt vorbereiten

1. **Neues GCP Projekt erstellen (falls nötig):**
```bash
gcloud projects create bringee-project --name="Bringee Project"
gcloud config set project bringee-project
```

2. **Billing aktivieren:**
```bash
# Ersetzen Sie YOUR_BILLING_ACCOUNT mit Ihrer Billing Account ID
gcloud billing projects link bringee-project --billing-account=YOUR_BILLING_ACCOUNT
```

### Schritt 2: Terraform State Bucket erstellen

```bash
# Bucket für Terraform State erstellen
gsutil mb -p YOUR_PROJECT_ID -c STANDARD -l us-central1 gs://bringee-terraform-state-YOUR_UNIQUE_ID
```

### Schritt 3: Terraform konfigurieren

1. **terraform.tfvars erstellen:**
```bash
cd terraform
cat > terraform.tfvars << EOF
gcp_project_id = "YOUR_PROJECT_ID"
gcp_region     = "us-central1"
github_repository = "YOUR_GITHUB_USERNAME/bringee"
EOF
```

2. **Terraform initialisieren und anwenden:**
```bash
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
```

### Schritt 5: Workload Identity konfigurieren

Die Workload Identity Federation ist bereits in der Terraform-Konfiguration enthalten. Der Provider wird automatisch erstellt.

## 🔄 Pipeline testen

### 1. Commit und Push
```bash
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

### 2. GitHub Actions überwachen
- Gehen Sie zu Ihrem GitHub Repository
- Klicken Sie auf den "Actions" Tab
- Überwachen Sie den Workflow "Bringee CI/CD"

### 3. Services testen
Nach erfolgreichem Deployment können Sie Ihre Services testen:

```bash
# Service URLs aus Terraform Output abrufen
cd terraform
terraform output user_service_url
terraform output shipment_service_url
```

## 📁 Projektstruktur

```
bringee/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions Pipeline
├── terraform/
│   ├── main.tf               # Hauptkonfiguration
│   ├── iam.tf               # IAM und Workload Identity
│   ├── artifacts.tf         # Artifact Registry
│   └── cloud-run.tf         # Cloud Run Services
├── backend/
│   └── services/
│       ├── user-service/     # User Service
│       └── shipment-service/ # Shipment Service
├── setup-gcp-deployment.sh  # Automatisches Setup
└── DEPLOYMENT_GUIDE.md     # Diese Anleitung
```

## 🔧 Konfiguration anpassen

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

### Umgebung anpassen

- **Region ändern:** `gcp_region` in terraform.tfvars
- **Ressourcen anpassen:** CPU/Memory in cloud-run.tf
- **Autoscaling:** `max-instances` in GitHub Actions

## 🐛 Troubleshooting

### Häufige Probleme

1. **Terraform State Bucket nicht gefunden:**
```bash
# Bucket manuell erstellen
gsutil mb -p YOUR_PROJECT_ID gs://YOUR_BUCKET_NAME
```

2. **GitHub Actions Authentifizierung fehlschlägt:**
- Überprüfen Sie die Workload Identity Konfiguration
- Stellen Sie sicher, dass die GitHub Secrets korrekt gesetzt sind

3. **Docker Build fehlschlägt:**
- Überprüfen Sie die Dockerfile-Pfade
- Stellen Sie sicher, dass die Services die richtige Struktur haben

### Logs überprüfen

```bash
# Cloud Run Logs
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# GitHub Actions Logs
# Gehen Sie zu GitHub > Actions > Workflow > Job > Step
```

## 📊 Monitoring

### Cloud Run Monitoring
- **Logs:** Google Cloud Console > Cloud Run > Service > Logs
- **Metriken:** Google Cloud Console > Cloud Run > Service > Metrics

### GitHub Actions Monitoring
- **Workflow Runs:** GitHub > Actions
- **Artifact Registry:** Google Cloud Console > Artifact Registry

## 🔒 Sicherheit

### Best Practices
- ✅ Workload Identity Federation für sichere Authentifizierung
- ✅ Service Accounts mit minimalen Berechtigungen
- ✅ Private Artifact Registry (kann konfiguriert werden)
- ✅ Cloud Run mit HTTPS und Authentifizierung

### Berechtigungen
Die Pipeline verwendet folgende IAM-Rollen:
- `roles/artifactregistry.writer` - Für Docker Images
- `roles/run.admin` - Für Cloud Run Deployment
- `roles/iam.serviceAccountUser` - Für Service Account Impersonation

## 📞 Support

Bei Problemen:
1. Überprüfen Sie die Logs in GitHub Actions
2. Schauen Sie in die Cloud Run Logs
3. Überprüfen Sie die Terraform Outputs
4. Stellen Sie sicher, dass alle Secrets korrekt konfiguriert sind

## 🎉 Nächste Schritte

Nach erfolgreicher Einrichtung:
1. **Frontend Deployment:** Flutter App zu Firebase Hosting deployen
2. **Database Setup:** Cloud SQL oder Firestore konfigurieren
3. **Monitoring:** Cloud Monitoring und Alerting einrichten
4. **SSL/TLS:** Custom Domains mit SSL-Zertifikaten
5. **CDN:** Cloud CDN für bessere Performance