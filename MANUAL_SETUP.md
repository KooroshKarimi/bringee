# Manuelle Einrichtung der Workload Identity Federation

Da der GitHub Actions Workflow einen Fehler mit der Workload Identity Federation zeigt, müssen wir diese manuell einrichten.

## 🔧 Schritt 1: Google Cloud Console

1. **Gehen Sie zur Google Cloud Console:**
   - https://console.cloud.google.com
   - Wählen Sie Ihr Projekt aus

2. **Aktivieren Sie die IAM API:**
   - Gehen Sie zu "APIs & Services" → "Library"
   - Suchen Sie nach "IAM Service Account Credentials API"
   - Klicken Sie auf "Enable"

## 🔧 Schritt 2: Workload Identity Pool erstellen

Führen Sie diese Befehle in der Google Cloud Console (Cloud Shell) aus:

```bash
# Setzen Sie Ihre Projekt-ID
export PROJECT_ID="IHRE_PROJECT_ID"

# Workload Identity Pool erstellen
gcloud iam workload-identity-pools create "github-actions-pool" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Workload Identity Provider erstellen
gcloud iam workload-identity-pools providers create-oidc "github-actions-provider" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions-pool" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --attribute-condition="attribute.repository=='KooroshKarimi/bringee'"
```

## 🔧 Schritt 3: Service Account erstellen

```bash
# Service Account für GitHub Actions erstellen
gcloud iam service-accounts create "github-actions-runner" \
  --project="${PROJECT_ID}" \
  --display-name="GitHub Actions Runner"

# Service Account für User Service erstellen
gcloud iam service-accounts create "user-service-sa" \
  --project="${PROJECT_ID}" \
  --display-name="User Service SA"

# Service Account für Shipment Service erstellen
gcloud iam service-accounts create "shipment-service-sa" \
  --project="${PROJECT_ID}" \
  --display-name="Shipment Service SA"
```

## 🔧 Schritt 4: Berechtigungen zuweisen

```bash
# GitHub Actions Service Account Berechtigungen
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:github-actions-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:github-actions-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:github-actions-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Workload Identity Binding
gcloud iam service-accounts add-iam-policy-binding "github-actions-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_ID}/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/KooroshKarimi/bringee"
```

## 🔧 Schritt 5: Artifact Registry erstellen

```bash
# Artifact Registry Repository erstellen
gcloud artifacts repositories create "bringee-artifacts" \
  --project="${PROJECT_ID}" \
  --location="us-central1" \
  --repository-format="DOCKER"
```

## 🔧 Schritt 6: APIs aktivieren

```bash
# Benötigte APIs aktivieren
gcloud services enable \
  --project="${PROJECT_ID}" \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  run.googleapis.com \
  iamcredentials.googleapis.com
```

## 🔧 Schritt 7: GitHub Secrets konfigurieren

Gehen Sie zu Ihrem GitHub Repository:
1. Settings → Secrets and variables → Actions
2. Fügen Sie diese Secrets hinzu:

| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | Ihre GCP Project ID |
| `GCP_REGION` | us-central1 |

## 🔧 Schritt 8: Testen

Nach der Einrichtung:

1. **Code pushen:**
   ```bash
   git add .
   git commit -m "Test Workload Identity"
   git push origin main
   ```

2. **GitHub Actions überprüfen:**
   - Gehen Sie zu Ihrem Repository
   - Klicken Sie auf "Actions"
   - Überprüfen Sie den Workflow-Lauf

## 🔧 Troubleshooting

### Fehler: "invalid_target"
- Stellen Sie sicher, dass die Workload Identity Pool und Provider korrekt erstellt wurden
- Überprüfen Sie, dass die Repository-Attribute korrekt sind

### Fehler: "permission denied"
- Stellen Sie sicher, dass alle IAM-Berechtigungen korrekt zugewiesen wurden
- Überprüfen Sie die Service Account E-Mails

### Fehler: "API not enabled"
- Aktivieren Sie alle benötigten APIs in der Google Cloud Console

## 📞 Support

Bei Problemen:
1. Überprüfen Sie die Google Cloud Console Logs
2. Schauen Sie in die GitHub Actions Logs
3. Stellen Sie sicher, dass alle Schritte korrekt ausgeführt wurden