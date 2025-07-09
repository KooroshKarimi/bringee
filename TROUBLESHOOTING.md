# Troubleshooting Guide - Bringee CI/CD Pipeline

## 🔍 Häufige Fehler und Lösungen

### 1. Workload Identity Federation Fehler

**Fehler:**
```
Error: google-github-actions/auth failed with: gitHub Actions did not inject $ACTIONS_ID_TOKEN_REQUEST_TOKEN or $ACTIONS_ID_TOKEN_REQUEST_URL into this job.
```

**Lösung:**
1. **Workflow-Berechtigungen hinzufügen** (bereits behoben):
```yaml
permissions:
  contents: read
  id-token: write
```

2. **GitHub Secrets überprüfen:**
   - `GCP_PROJECT_ID` muss korrekt gesetzt sein
   - `GITHUB_ACTIONS_SA_EMAIL` muss korrekt gesetzt sein

3. **Repository-Einstellungen überprüfen:**
   - Gehen Sie zu Repository Settings > Actions > General
   - Stellen Sie sicher, dass "Actions permissions" auf "Allow all actions and reusable workflows" gesetzt ist

### 2. Terraform State Bucket Fehler

**Fehler:**
```
Error: Failed to get existing workspaces: googleapi: Error 403: Access denied.
```

**Lösung:**
```bash
# Bucket manuell erstellen
gsutil mb -p YOUR_PROJECT_ID gs://bringee-terraform-state-YOUR_UNIQUE_ID

# Bucket-Namen in terraform/main.tf aktualisieren
sed -i "s/bringee-terraform-state-bucket-unique/YOUR_BUCKET_NAME/" terraform/main.tf
```

### 3. Docker Build Fehler

**Fehler:**
```
Error: failed to solve: failed to compute cache key: failed to calculate checksum of ref
```

**Lösung:**
1. **Dockerfile-Pfade überprüfen:**
```bash
# Stellen Sie sicher, dass die Dockerfiles existieren
ls -la backend/services/user-service/Dockerfile
ls -la backend/services/shipment-service/Dockerfile
```

2. **Dockerfile erstellen (falls nicht vorhanden):**
```dockerfile
# backend/services/user-service/Dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o server .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]
```

### 4. Cloud Run Deployment Fehler

**Fehler:**
```
Error: (gcloud.run.deploy) PERMISSION_DENIED: The caller does not have permission
```

**Lösung:**
1. **Service Account Berechtigungen überprüfen:**
```bash
# Terraform erneut ausführen
cd terraform
terraform apply
```

2. **Manuell Berechtigungen setzen:**
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions-runner@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.admin"
```

### 5. GitHub Actions Secrets Fehler

**Fehler:**
```
Error: google-github-actions/auth failed with: Invalid value for field 'service_account'
```

**Lösung:**
1. **Secrets überprüfen:**
```bash
# Terraform Output anzeigen
cd terraform
terraform output github_actions_sa_email
```

2. **Secrets manuell setzen:**
   - Gehen Sie zu GitHub Repository > Settings > Secrets and variables > Actions
   - `GCP_PROJECT_ID`: Ihr GCP Projekt ID
   - `GITHUB_ACTIONS_SA_EMAIL`: Aus Terraform Output

### 6. Artifact Registry Fehler

**Fehler:**
```
Error: (gcloud.auth.configure-docker) PERMISSION_DENIED: The caller does not have permission
```

**Lösung:**
```bash
# Manuell authentifizieren
gcloud auth login
gcloud auth configure-docker europe-west3-docker.pkg.dev
```

## 🔧 Debugging-Schritte

### 1. GitHub Actions Logs überprüfen
```bash
# Gehen Sie zu GitHub > Actions > Workflow Run > Job > Step
# Klicken Sie auf "View logs" für detaillierte Fehlerinformationen
```

### 2. Cloud Run Logs überprüfen
```bash
# Cloud Run Logs anzeigen
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# Spezifische Service Logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=user-service" --limit=20
```

### 3. Terraform Status überprüfen
```bash
cd terraform
terraform plan
terraform state list
```

### 4. GCP IAM überprüfen
```bash
# Service Account Berechtigungen anzeigen
gcloud projects get-iam-policy YOUR_PROJECT_ID \
    --flatten="bindings[].members" \
    --format='table(bindings.role)' \
    --filter="bindings.members:github-actions-runner@YOUR_PROJECT_ID.iam.gserviceaccount.com"
```

## 🚨 Notfall-Lösungen

### Pipeline komplett zurücksetzen
```bash
# 1. Terraform zerstören
cd terraform
terraform destroy

# 2. GitHub Secrets löschen
# Gehen Sie zu GitHub > Settings > Secrets and variables > Actions
# Löschen Sie alle Secrets

# 3. Setup-Skript erneut ausführen
./setup-gcp-deployment.sh
```

### Manuelles Deployment
```bash
# 1. Authentifizieren
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# 2. Docker Image bauen und pushen
docker build -t europe-west3-docker.pkg.dev/YOUR_PROJECT_ID/bringee-artifacts/user-service:latest \
  --file backend/services/user-service/Dockerfile backend/services/user-service
docker push europe-west3-docker.pkg.dev/YOUR_PROJECT_ID/bringee-artifacts/user-service:latest

# 3. Cloud Run deployen
gcloud run deploy user-service \
  --image europe-west3-docker.pkg.dev/YOUR_PROJECT_ID/bringee-artifacts/user-service:latest \
  --region europe-west3 \
  --platform managed \
  --allow-unauthenticated
```

## 📞 Support

### Logs sammeln für Support
```bash
# GitHub Actions Logs
# Gehen Sie zu GitHub > Actions > Workflow Run > Download logs

# Cloud Run Logs
gcloud logging read "resource.type=cloud_run_revision" --limit=100 > cloud-run-logs.txt

# Terraform State
cd terraform
terraform show > terraform-state.txt
```

### Häufige Support-Fragen

1. **"Warum funktioniert Workload Identity nicht?"**
   - Überprüfen Sie die GitHub Repository-Einstellungen
   - Stellen Sie sicher, dass die Workflow-Berechtigungen korrekt sind

2. **"Warum kann ich nicht zu Cloud Run deployen?"**
   - Überprüfen Sie die Service Account Berechtigungen
   - Stellen Sie sicher, dass Cloud Run API aktiviert ist

3. **"Warum schlägt der Docker Build fehl?"**
   - Überprüfen Sie die Dockerfile-Pfade
   - Stellen Sie sicher, dass alle Abhängigkeiten vorhanden sind

## 🔄 Automatische Fehlerbehebung

### Setup-Skript mit Fehlerbehebung
```bash
# Setup-Skript mit erweiterten Checks ausführen
./setup-gcp-deployment.sh --debug
```

### Terraform mit Debug-Output
```bash
cd terraform
TF_LOG=DEBUG terraform apply
```