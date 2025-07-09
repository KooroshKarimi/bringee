<<<<<<< HEAD
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
gsutil mb -p YOUR_PROJECT_ID -c STANDARD -l europe-west3 gs://bringee-terraform-state-YOUR_UNIQUE_ID
```

### Schritt 3: Terraform konfigurieren

1. **terraform.tfvars erstellen:**
```bash
cd terraform
cat > terraform.tfvars << EOF
gcp_project_id = "YOUR_PROJECT_ID"
gcp_region     = "europe-west3"
github_repository = "YOUR_GITHUB_USERNAME/bringee"
EOF
```

2. **Terraform initialisieren und anwenden:**
```bash
=======
# 🚀 Bringee - Automatisches Deployment mit Google Cloud

Diese Anleitung zeigt Ihnen, wie Sie Ihr Bringee-Projekt mit Google Cloud verbinden, um automatische Deployments zu ermöglichen.

## 📋 Voraussetzungen

1. **Google Cloud Project** mit aktivierter Abrechnung
2. **GitHub Repository** mit Ihrem Bringee-Projekt
3. **Google Cloud SDK** installiert und authentifiziert
4. **Terraform** installiert (optional, für Infrastructure as Code)

## 🔧 Schritt-für-Schritt Einrichtung

### 1. Google Cloud SDK einrichten

```bash
# Google Cloud SDK installieren (falls noch nicht geschehen)
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Authentifizierung
gcloud auth login
gcloud auth application-default login
```

### 2. GCP-Projekt konfigurieren

```bash
# Projekt-ID setzen (ersetzen Sie YOUR_PROJECT_ID)
gcloud config set project YOUR_PROJECT_ID

# Erforderliche APIs aktivieren
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 3. Automatische Einrichtung mit Setup-Skript

```bash
# Setup-Skript ausführbar machen
chmod +x scripts/setup-gcp.sh

# Setup ausführen (ersetzen Sie YOUR_PROJECT_ID)
./scripts/setup-gcp.sh YOUR_PROJECT_ID
```

### 4. Terraform-Konfiguration

```bash
# Terraform-Konfigurationsdatei erstellen
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# terraform.tfvars bearbeiten
nano terraform/terraform.tfvars
```

Fügen Sie Ihre Werte in `terraform/terraform.tfvars` ein:

```hcl
gcp_project_id = "your-gcp-project-id"
github_repository = "your-username/bringee"
gcp_region = "us-central1"
environment = "dev"
```

### 5. Infrastructure mit Terraform deployen

```bash
cd terraform
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
terraform init
terraform plan
terraform apply
```

<<<<<<< HEAD
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
=======
### 6. GitHub Secrets konfigurieren

Gehen Sie zu Ihrem GitHub Repository → Settings → Secrets and variables → Actions und fügen Sie folgende Secrets hinzu:

- **GCP_PROJECT_ID**: Ihre Google Cloud Project ID

### 7. GitHub Repository konfigurieren

Stellen Sie sicher, dass Ihr Repository die folgenden Dateien enthält:

- `.github/workflows/ci-cd.yml` (bereits vorhanden)
- `terraform/` Verzeichnis mit allen Terraform-Dateien
- `scripts/setup-gcp.sh` (Setup-Skript)

## 🔄 Automatisches Deployment

Nach der Einrichtung wird bei jedem Push auf den `main` Branch automatisch:

1. **Tests ausgeführt** für alle Backend-Services
2. **Docker Images gebaut** und zu Artifact Registry gepusht
3. **Cloud Run Services deployed** mit den neuesten Images
4. **Terraform Infrastructure** aktualisiert (falls Änderungen)
5. **Flutter Frontend** gebaut und deployed (falls Firebase konfiguriert)

## 📊 Monitoring und Logs

### Cloud Run Services überwachen

```bash
# Service-URLs anzeigen
gcloud run services list --region=us-central1

# Logs anzeigen
gcloud logging read "resource.type=cloud_run_revision" --limit=50
```

### GitHub Actions Logs

- Gehen Sie zu Ihrem GitHub Repository
- Klicken Sie auf "Actions" Tab
- Wählen Sie den neuesten Workflow aus

## 🛠️ Troubleshooting

### Häufige Probleme

1. **Authentifizierungsfehler**
   ```bash
   gcloud auth application-default login
   gcloud auth login
   ```

2. **Workload Identity Federation Fehler**
   - Stellen Sie sicher, dass das Setup-Skript erfolgreich ausgeführt wurde
   - Überprüfen Sie die GitHub Secrets

3. **Terraform State Fehler**
   ```bash
   cd terraform
   terraform init -reconfigure
   ```

4. **Docker Build Fehler**
   - Überprüfen Sie, ob Dockerfiles in den Service-Verzeichnissen vorhanden sind
   - Stellen Sie sicher, dass alle Dependencies korrekt installiert sind

### Debugging

```bash
# GCP-Projekt-Status überprüfen
gcloud config list

# Service Accounts auflisten
gcloud iam service-accounts list

# Workload Identity Pools überprüfen
gcloud iam workload-identity-pools list --location=global
```

## 🔐 Sicherheit

### Workload Identity Federation

Das Setup verwendet Workload Identity Federation für sichere Authentifizierung:

- Keine langfristigen Credentials in GitHub Secrets
- Automatische Token-Rotation
- Repository-spezifische Zugriffskontrolle

### IAM-Rollen

Die Service Accounts haben minimal notwendige Berechtigungen:

- `roles/artifactregistry.writer` - Docker Images pushen
- `roles/run.admin` - Cloud Run Services verwalten
- `roles/iam.serviceAccountUser` - Als andere Service Accounts agieren

## 📈 Skalierung

### Cloud Run Autoscaling

Die Services sind mit automatischer Skalierung konfiguriert:

- **Min Instances**: 0 (kostenoptimiert)
- **Max Instances**: 10 (Performance)
- **CPU**: 1 vCPU
- **Memory**: 512MB

### Kostenoptimierung

```bash
# Kosten überwachen
gcloud billing budgets list

# Unused Resources finden
gcloud compute instances list --filter="status=TERMINATED"
```

## 🚀 Nächste Schritte

1. **Monitoring einrichten** mit Google Cloud Monitoring
2. **Alerting konfigurieren** für kritische Metriken
3. **Backup-Strategie** für Datenbanken implementieren
4. **CDN einrichten** für bessere Performance
5. **SSL-Zertifikate** für Custom Domains konfigurieren
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df

## 📞 Support

Bei Problemen:
<<<<<<< HEAD
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
=======

1. Überprüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Google Cloud Console
3. Überprüfen Sie die Terraform Outputs
4. Konsultieren Sie die Google Cloud Dokumentation

---

**Viel Erfolg mit Ihrem automatischen Deployment! 🎉**
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
