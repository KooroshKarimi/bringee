# Bringee GCP Deployment Guide

Diese Anleitung führt dich durch die Einrichtung einer vollständigen CI/CD-Pipeline für dein Bringee-Projekt mit Google Cloud Platform (GCP).

## 🎯 Übersicht

Die Pipeline automatisiert folgende Schritte:
1. **Tests**: Automatische Tests bei jedem Push
2. **Build**: Docker-Images erstellen
3. **Push**: Images zu Google Artifact Registry pushen
4. **Deploy**: Automatisches Deployment zu Cloud Run (Region: europe-west3)

---

## 📋 Voraussetzungen

- **Google Cloud Projekt** mit aktivierter Abrechnung
- **GitHub Repository** mit deinem Bringee-Projekt
- **Google Cloud SDK** installiert und authentifiziert
- **Terraform** installiert (für Infrastructure as Code)

---

## 🔧 Schritt-für-Schritt Einrichtung

### 1. Google Cloud SDK installieren und einrichten

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

### 3. GCP-Projekt und APIs vorbereiten

```bash
# Projekt-ID setzen (ersetze YOUR_PROJECT_ID)
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

### 4. Automatische Einrichtung mit Setup-Skript (empfohlen)

```bash
chmod +x scripts/setup-gcp.sh
./scripts/setup-gcp.sh YOUR_PROJECT_ID
```

Das Skript führt dich durch alle notwendigen Schritte (APIs, Service Accounts, Terraform-Init, etc.).

---

## 🔨 Manuelle Einrichtung (optional)

### 1. Terraform-Konfiguration

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
nano terraform/terraform.tfvars
```

Trage deine Werte ein:

```hcl
gcp_project_id = "your-gcp-project-id"
github_repository = "your-username/bringee"
gcp_region = "europe-west3"
environment = "dev"
```

### 2. Terraform ausführen

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

---

## 🔑 GitHub Secrets konfigurieren

1. Gehe zu deinem GitHub Repository
2. Navigiere zu **Settings > Secrets and variables > Actions**
3. Füge folgende Secrets hinzu:

```
GCP_PROJECT_ID: your-gcp-project-id
GCP_SA_KEY: (Service Account Key als JSON, aus GCP IAM)
```

---

## 🔄 Pipeline testen

1. Commit und Push:
```bash
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```
2. Prüfe den Status im GitHub Actions Tab.

---

## ℹ️ Hinweise

- Die Workload Identity Federation ist in der Terraform-Konfiguration vorbereitet, aber für die meisten Setups reicht der Service Account Key.
- Die Region ist überall auf `europe-west3` (Frankfurt) eingestellt.
- Bei Problemen siehe README oder Troubleshooting-Abschnitt.
