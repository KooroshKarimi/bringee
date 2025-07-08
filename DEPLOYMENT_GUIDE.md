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
terraform init
terraform plan
terraform apply
```

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

## 📞 Support

Bei Problemen:

1. Überprüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Google Cloud Console
3. Überprüfen Sie die Terraform Outputs
4. Konsultieren Sie die Google Cloud Dokumentation

---

**Viel Erfolg mit Ihrem automatischen Deployment! 🎉**