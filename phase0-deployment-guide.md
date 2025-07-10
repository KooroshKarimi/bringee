# 🚀 Phase 0 Deployment Guide - Bringee auf Google Cloud

## ✅ Phase 0 Status

Phase 0 ist bereits vollständig implementiert und bereit für das Deployment auf Google Cloud:

- ✅ **Backend Services**: user-service und shipment-service implementiert
- ✅ **Terraform Infrastructure**: Vollständige IaC-Konfiguration
- ✅ **GitHub Actions CI/CD**: Automatisches Deployment Pipeline
- ✅ **Docker Images**: Konfiguriert für Artifact Registry
- ✅ **Cloud Run Services**: Bereit für Deployment

## 🎯 Schnelles Deployment

### Option 1: GitHub Actions (Empfohlen)

1. **GitHub Secrets konfigurieren**:
   - Gehen Sie zu Ihrem GitHub Repository
   - Settings → Secrets and variables → Actions
   - Fügen Sie folgende Secrets hinzu:
     - `GCP_PROJECT_ID`: Ihre GCP Project ID
     - `GITHUB_ACTIONS_SA_EMAIL`: Wird nach erstem Terraform Run erstellt

2. **Push zum main Branch**:
   ```bash
   git add .
   git commit -m "deploy: Phase 0 to Google Cloud"
   git push origin main
   ```

3. **Überwachen Sie die GitHub Actions**:
   - Gehen Sie zu: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
   - Der Workflow wird automatisch ausgelöst

### Option 2: Manuelles Deployment

Falls GitHub Actions nicht funktioniert:

1. **gcloud CLI installieren**:
   ```bash
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   gcloud init
   ```

2. **Manuelles Deployment ausführen**:
   ```bash
   ./manual-deploy.sh
   ```

## 📋 Benötigte GCP Ressourcen

### 1. Google Cloud Projekt
- Projekt ID: `gemini-koorosh-karimi` (bereits konfiguriert)
- Region: `europe-west3` (Frankfurt)

### 2. Aktivierte APIs
- Cloud Run API
- Artifact Registry API
- IAM API
- Secret Manager API
- Cloud Resource Manager API

### 3. Service Accounts
- GitHub Actions Service Account (wird von Terraform erstellt)
- User Service Account
- Shipment Service Account

## 🔧 Deployment Schritte

### Schritt 1: Terraform Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Schritt 2: Docker Images bauen und pushen
```bash
# User Service
cd backend/services/user-service
docker build -t europe-west3-docker.pkg.dev/gemini-koorosh-karimi/bringee-artifacts/user-service:latest .
docker push europe-west3-docker.pkg.dev/gemini-koorosh-karimi/bringee-artifacts/user-service:latest

# Shipment Service
cd ../shipment-service
docker build -t europe-west3-docker.pkg.dev/gemini-koorosh-karimi/bringee-artifacts/shipment-service:latest .
docker push europe-west3-docker.pkg.dev/gemini-koorosh-karimi/bringee-artifacts/shipment-service:latest
```

### Schritt 3: Cloud Run Services deployen
```bash
# User Service
gcloud run deploy user-service \
    --image europe-west3-docker.pkg.dev/gemini-koorosh-karimi/bringee-artifacts/user-service:latest \
    --region europe-west3 \
    --platform managed \
    --allow-unauthenticated \
    --port 8080

# Shipment Service
gcloud run deploy shipment-service \
    --image europe-west3-docker.pkg.dev/gemini-koorosh-karimi/bringee-artifacts/shipment-service:latest \
    --region europe-west3 \
    --platform managed \
    --allow-unauthenticated \
    --port 8080
```

## 🧪 Testing der Services

Nach dem Deployment können Sie die Services testen:

### User Service
```bash
curl https://user-service-xxxxx-ew.a.run.app/
# Erwartete Antwort: "Hello from user-service!"

curl https://user-service-xxxxx-ew.a.run.app/health
# Erwartete Antwort: JSON mit Status und Timestamp
```

### Shipment Service
```bash
curl https://shipment-service-xxxxx-ew.a.run.app/
# Erwartete Antwort: "Hello from shipment-service!"

curl https://shipment-service-xxxxx-ew.a.run.app/health
# Erwartete Antwort: JSON mit Status und Timestamp
```

## 📊 Monitoring und Logs

### Cloud Run Logs
```bash
# User Service Logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=user-service" --limit=10

# Shipment Service Logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=shipment-service" --limit=10
```

### Service URLs abrufen
```bash
# User Service URL
gcloud run services describe user-service --region=europe-west3 --format="value(status.url)"

# Shipment Service URL
gcloud run services describe shipment-service --region=europe-west3 --format="value(status.url)"
```

## 🔍 Troubleshooting

### Häufige Probleme

1. **"Permission denied"**:
   - Überprüfen Sie die Service Account Berechtigungen
   - Stellen Sie sicher, dass die APIs aktiviert sind

2. **"Image not found"**:
   - Überprüfen Sie, ob die Docker Images erfolgreich gepusht wurden
   - Überprüfen Sie die Artifact Registry Konfiguration

3. **"Service not responding"**:
   - Überprüfen Sie die Cloud Run Logs
   - Stellen Sie sicher, dass der Service auf Port 8080 läuft

### Debugging Commands
```bash
# Service Status überprüfen
gcloud run services list --region=europe-west3

# Service Details anzeigen
gcloud run services describe user-service --region=europe-west3

# Logs in Echtzeit
gcloud logging tail "resource.type=cloud_run_revision"
```

## 🎉 Erfolgreiches Deployment

Nach erfolgreichem Deployment haben Sie:

- ✅ **User Service**: Läuft auf Cloud Run
- ✅ **Shipment Service**: Läuft auf Cloud Run
- ✅ **Artifact Registry**: Docker Images gespeichert
- ✅ **CI/CD Pipeline**: Automatisches Deployment
- ✅ **Monitoring**: Logs und Metriken verfügbar

## 🚀 Nächste Schritte

1. **Phase 1 beginnen**: Erweitern Sie die Services um echte Business-Logik
2. **Datenbank hinzufügen**: Cloud SQL oder Firestore integrieren
3. **Frontend entwickeln**: Flutter App mit den Services verbinden
4. **Monitoring erweitern**: Cloud Monitoring und Alerting einrichten

## 📚 Nützliche Links

- [PHASE_0_STATUS.md](./PHASE_0_STATUS.md) - Detaillierter Status
- [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md) - GitHub Secrets
- [MANUAL_GCP_SETUP.md](./MANUAL_GCP_SETUP.md) - Manuelle GCP Einrichtung
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Fehlerbehebung