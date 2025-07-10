# 🚀 Phase 0 Google Cloud Setup - Vollständige Anleitung

## 📋 Übersicht

Phase 0 ist bereits sehr gut implementiert, aber hier ist eine vollständige Anleitung, um sicherzustellen, dass alles auf Google Cloud läuft.

## ✅ Aktueller Status

### Was bereits funktioniert:
- ✅ GitHub Actions Workflow konfiguriert
- ✅ Backend Services (user-service, shipment-service) implementiert
- ✅ Docker Images konfiguriert
- ✅ Terraform Infrastructure as Code
- ✅ Cloud Run Deployment konfiguriert
- ✅ Workload Identity Federation vorbereitet

### Was noch zu tun ist:
- 🔄 GitHub Secrets konfigurieren
- 🔄 Terraform State Bucket erstellen
- 🔄 Infrastructure deployen
- 🔄 Pipeline testen

## 🛠️ Schritt-für-Schritt Setup

### 1. Google Cloud SDK installieren

```bash
# Ubuntu/Debian
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Oder über apt
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli
```

### 2. Bei Google Cloud anmelden

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 3. Terraform State Bucket erstellen

```bash
# Ersetze YOUR_PROJECT_ID mit deiner Project ID
gsutil mb -p YOUR_PROJECT_ID -c STANDARD -l europe-west3 gs://bringee-terraform-state-$(date +%s)
```

### 4. Terraform konfigurieren

```bash
# Kopiere die Beispiel-Konfiguration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Bearbeite die Konfiguration
nano terraform/terraform.tfvars
```

**Inhalt von `terraform/terraform.tfvars`:**
```hcl
gcp_project_id    = "your-gcp-project-id"         # Deine GCP Project ID
gcp_region        = "europe-west3"                # GCP Region
github_repository = "your-github-username/bringee" # GitHub Repository
environment       = "dev"                         # Umgebung
```

### 5. Infrastructure deployen

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 6. GitHub Secrets konfigurieren

Gehe zu deinem GitHub Repository → Settings → Secrets and variables → Actions

**Füge diese Secrets hinzu:**

#### Secret 1: GCP_PROJECT_ID
- **Name:** `GCP_PROJECT_ID`
- **Value:** Deine GCP Project ID (z.B. `bringee-project-123456`)

#### Secret 2: GITHUB_ACTIONS_SA_EMAIL
- **Name:** `GITHUB_ACTIONS_SA_EMAIL`
- **Value:** Die E-Mail des Service Accounts (wird von Terraform erstellt)

**Oder verwende das Setup-Skript:**
```bash
chmod +x setup-gcp-deployment.sh
./setup-gcp-deployment.sh
```

### 7. Pipeline testen

```bash
# Füge eine Test-Datei hinzu
echo "# Test Deployment" > test-deployment.md

# Commit und Push
git add .
git commit -m "Test Phase 0 deployment"
git push origin main
```

## 🔍 Troubleshooting

### Problem: "Permission denied"
```bash
# Überprüfe die IAM-Rollen
gcloud projects get-iam-policy YOUR_PROJECT_ID

# Stelle sicher, dass der Service Account diese Rollen hat:
# - Cloud Run Admin
# - Storage Admin
# - Artifact Registry Admin
# - Service Account User
```

### Problem: "Artifact Registry not found"
```bash
# Erstelle das Artifact Registry manuell
gcloud artifacts repositories create bringee-artifacts \
  --repository-format=docker \
  --location=europe-west3 \
  --description="Bringee Docker Images"
```

### Problem: "Terraform state bucket not found"
```bash
# Erstelle den Bucket manuell
gsutil mb -p YOUR_PROJECT_ID -c STANDARD -l europe-west3 gs://bringee-terraform-state-unique
```

### Problem: "GitHub Actions not triggered"
1. Überprüfe, ob der Workflow in `.github/workflows/ci-cd.yml` existiert
2. Stelle sicher, dass du auf den `main` Branch pushst
3. Überprüfe die GitHub Actions Logs

## 🧪 Testing

### Teste die Services lokal:

```bash
# User Service
cd backend/services/user-service
go run main.go

# In einem anderen Terminal
curl http://localhost:8080
curl http://localhost:8080/health
```

### Teste die Docker Images:

```bash
# Build und Test
cd backend/services/user-service
docker build -t user-service .
docker run -p 8080:8080 user-service

# Test
curl http://localhost:8080
```

## 📊 Monitoring

### Cloud Run Services überprüfen:
```bash
gcloud run services list --region=europe-west3
```

### Logs anzeigen:
```bash
gcloud logging read "resource.type=cloud_run_revision" --limit=10
```

### Artifact Registry überprüfen:
```bash
gcloud artifacts repositories list --location=europe-west3
```

## 🎯 Erfolgskriterien

Phase 0 ist erfolgreich, wenn:

1. ✅ GitHub Actions Workflow läuft ohne Fehler
2. ✅ Docker Images werden automatisch gebaut und gepusht
3. ✅ Cloud Run Services werden automatisch deployed
4. ✅ Services sind über HTTPS erreichbar
5. ✅ Health Checks funktionieren
6. ✅ Logs sind verfügbar

## 🚀 Nächste Schritte

Nach erfolgreichem Phase 0 Setup:

1. **Phase 1:** Backend Services erweitern (Datenbank, APIs)
2. **Phase 2:** Frontend entwickeln (Flutter App)
3. **Phase 3:** Integration und Testing
4. **Phase 4:** Production Deployment

## 📞 Support

Bei Problemen:
1. Überprüfe die GitHub Actions Logs
2. Überprüfe die Cloud Run Logs
3. Überprüfe die Terraform Outputs
4. Konsultiere die Troubleshooting-Dokumentation

---

**Phase 0 ist das Fundament für das gesamte Bringee-Projekt. Ein erfolgreiches Setup ermöglicht automatische Deployments für alle zukünftigen Entwicklungen.**