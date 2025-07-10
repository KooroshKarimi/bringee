# 🚀 Phase 0 - GitHub Secrets Setup für Google Cloud

Diese Anleitung zeigt, wie Sie die GitHub Secrets konfigurieren, die für das automatische Deployment von Phase 0 in Google Cloud Platform benötigt werden.

## 📋 Übersicht

Phase 0 verwendet **Workload Identity Federation** für eine sichere Authentifizierung zwischen GitHub Actions und Google Cloud. Dies ist die empfohlene Methode, da sie keine langfristigen Service Account Keys speichert.

## 🔧 Schritt-für-Schritt Setup

### Schritt 1: Google Cloud Projekt vorbereiten

1. **Google Cloud Console öffnen**
   - Gehen Sie zu: https://console.cloud.google.com/
   - Wählen Sie Ihr Projekt aus (z.B. `bringee-project`)

2. **Benötigte APIs aktivieren**
   ```bash
   gcloud services enable \
     iam.googleapis.com \
     cloudresourcemanager.googleapis.com \
     artifactregistry.googleapis.com \
     secretmanager.googleapis.com \
     run.googleapis.com \
     iamcredentials.googleapis.com \
     logging.googleapis.com \
     monitoring.googleapis.com
   ```

### Schritt 2: Terraform Infrastructure deployen

1. **Setup-Skript ausführen**
   ```bash
   # Konfiguration setzen
   export GCP_PROJECT_ID="ihr-projekt-id"
   export GCP_REGION="europe-west3"
   export GITHUB_REPO="ihr-username/bringee"
   
   # Setup-Skript ausführen
   ./setup-phase0-gcp.sh
   ```

2. **Das Skript erstellt automatisch:**
   - ✅ GCS Bucket für Terraform State
   - ✅ Artifact Registry Repository
   - ✅ IAM Service Account für GitHub Actions
   - ✅ Workload Identity Federation
   - ✅ Cloud Run Services
   - ✅ Alle notwendigen IAM-Rollen

### Schritt 3: GitHub Secrets konfigurieren

1. **GitHub Repository öffnen**
   - Gehen Sie zu: https://github.com/ihr-username/bringee
   - Klicken Sie auf "Settings"

2. **Secrets & Variables > Actions**
   - Klicken Sie auf "Secrets and variables" > "Actions"
   - Klicken Sie auf "New repository secret"

3. **Benötigte Secrets hinzufügen:**

#### Secret 1: GCP_PROJECT_ID
- **Name:** `GCP_PROJECT_ID`
- **Value:** Ihre Google Cloud Project ID (z.B. `bringee-project-123456`)

#### Secret 2: GITHUB_ACTIONS_SA_EMAIL
- **Name:** `GITHUB_ACTIONS_SA_EMAIL`
- **Value:** Die E-Mail des Service Accounts (wird von Terraform erstellt)
- **Format:** `github-actions@bringee-project-123456.iam.gserviceaccount.com`

#### Secret 3: WORKLOAD_IDENTITY_PROVIDER (Optional)
- **Name:** `WORKLOAD_IDENTITY_PROVIDER`
- **Value:** `projects/ihr-projekt-id/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider`

### Schritt 4: Alternative - Service Account Key (nicht empfohlen)

Falls Sie Workload Identity nicht verwenden möchten:

1. **Service Account Key erstellen**
   ```bash
   # In Google Cloud Console:
   # 1. IAM & Admin > Service Accounts
   # 2. github-actions Service Account auswählen
   # 3. Keys > Add Key > Create new key
   # 4. JSON auswählen und herunterladen
   ```

2. **GCP_SA_KEY Secret hinzufügen**
   - **Name:** `GCP_SA_KEY`
   - **Value:** Der komplette Inhalt der heruntergeladenen JSON-Datei

## 🧪 Testing der Konfiguration

### 1. Manueller Test
```bash
# Services testen
curl https://user-service-xxxxx-ew.a.run.app/
curl https://shipment-service-xxxxx-ew.a.run.app/

# Health checks
curl https://user-service-xxxxx-ew.a.run.app/health
curl https://shipment-service-xxxxx-ew.a.run.app/health
```

### 2. GitHub Actions Test
1. **Commit pushen**
   ```bash
   git add .
   git commit -m "Test Phase 0 deployment"
   git push origin main
   ```

2. **GitHub Actions überwachen**
   - Gehen Sie zu: https://github.com/ihr-username/bringee/actions
   - Überwachen Sie den "Bringee CI/CD" Workflow

## 🔍 Troubleshooting

### Fehler: "Permission denied"
```bash
# Überprüfen Sie die IAM-Rollen
gcloud projects get-iam-policy ihr-projekt-id \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:github-actions"
```

### Fehler: "Workload Identity not found"
```bash
# Workload Identity Provider überprüfen
gcloud iam workload-identity-pools providers describe github-actions-provider \
  --location=global \
  --workload-identity-pool=github-actions-pool
```

### Fehler: "Artifact Registry not found"
```bash
# Artifact Registry überprüfen
gcloud artifacts repositories list --location=europe-west3
```

### Fehler: "Service Account not found"
```bash
# Service Account überprüfen
gcloud iam service-accounts list --filter="email:github-actions"
```

## 📊 Monitoring

### 1. Google Cloud Console
- **Cloud Run:** https://console.cloud.google.com/run
- **Artifact Registry:** https://console.cloud.google.com/artifacts
- **Logs:** https://console.cloud.google.com/logs

### 2. GitHub Actions
- **Workflow Runs:** https://github.com/ihr-username/bringee/actions
- **Repository Secrets:** https://github.com/ihr-username/bringee/settings/secrets/actions

## 🎯 Phase 0 Status Checklist

- [ ] Google Cloud Projekt erstellt
- [ ] Terraform Infrastructure deployed
- [ ] GitHub Secrets konfiguriert
- [ ] GitHub Actions Workflow funktioniert
- [ ] Backend Services deployed
- [ ] Health Checks erfolgreich
- [ ] CI/CD Pipeline getestet

## 🚀 Nächste Schritte

Nach erfolgreicher Phase 0 Konfiguration:

1. **Phase 1 beginnen** - Backend Services erweitern
2. **Frontend entwickeln** - Flutter App implementieren
3. **Datenbank integrieren** - Cloud SQL oder Firestore
4. **Monitoring einrichten** - Cloud Monitoring und Logging
5. **Security Hardening** - VPC, Firewall, IAM

## 📞 Support

Bei Problemen:

1. **Logs überprüfen:** Google Cloud Console > Logs
2. **GitHub Actions:** Repository > Actions > Workflow Runs
3. **Terraform:** `terraform plan` und `terraform apply` erneut ausführen
4. **Service Account:** IAM & Admin > Service Accounts überprüfen

---

**✅ Phase 0 ist erfolgreich konfiguriert, wenn alle Services deployed sind und die GitHub Actions Pipeline funktioniert!**