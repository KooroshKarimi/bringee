# Einfache Einrichtung mit Service Account Keys

Diese Anleitung zeigt, wie Sie die automatische Deployment-Pipeline mit Service Account Keys einrichten können (einfacher als Workload Identity Federation).

## 🔧 Schritt 1: Service Account erstellen

1. **Gehen Sie zur Google Cloud Console:**
   - https://console.cloud.google.com
   - Wählen Sie Ihr Projekt aus

2. **Service Account erstellen:**
   - Gehen Sie zu "IAM & Admin" → "Service Accounts"
   - Klicken Sie auf "Create Service Account"
   - Name: `github-actions-runner`
   - Beschreibung: `Service Account for GitHub Actions`

3. **Berechtigungen zuweisen:**
   - Klicken Sie auf "Continue"
   - Fügen Sie diese Rollen hinzu:
     - `Artifact Registry Writer`
     - `Cloud Run Admin`
     - `Service Account User`
   - Klicken Sie auf "Done"

## 🔧 Schritt 2: Service Account Key erstellen

1. **Key erstellen:**
   - Klicken Sie auf den Service Account `github-actions-runner`
   - Gehen Sie zum Tab "Keys"
   - Klicken Sie auf "Add Key" → "Create new key"
   - Wählen Sie "JSON"
   - Klicken Sie auf "Create"

2. **Key herunterladen:**
   - Die JSON-Datei wird automatisch heruntergeladen
   - Öffnen Sie die Datei und kopieren Sie den gesamten Inhalt

## 🔧 Schritt 3: GitHub Secrets konfigurieren

1. **Gehen Sie zu Ihrem GitHub Repository:**
   - Settings → Secrets and variables → Actions

2. **Fügen Sie diese Secrets hinzu:**

| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | Ihre GCP Project ID (z.B. `my-project-123`) |
| `GCP_SA_KEY` | Der gesamte Inhalt der JSON-Key-Datei |

## 🔧 Schritt 4: Workflow aktivieren

1. **Workflow umbenennen:**
   ```bash
   git mv .github/workflows/ci-cd.yml .github/workflows/ci-cd-backup.yml
   git mv .github/workflows/ci-cd-simple.yml .github/workflows/ci-cd.yml
   ```

2. **Code pushen:**
   ```bash
   git add .
   git commit -m "Switch to simple authentication"
   git push origin main
   ```

## 🔧 Schritt 5: APIs aktivieren

Führen Sie diese Befehle in der Google Cloud Console (Cloud Shell) aus:

```bash
# Setzen Sie Ihre Projekt-ID
export PROJECT_ID="IHRE_PROJECT_ID"

# APIs aktivieren
gcloud services enable \
  --project="${PROJECT_ID}" \
  artifactregistry.googleapis.com \
  run.googleapis.com \
  cloudresourcemanager.googleapis.com

# Artifact Registry Repository erstellen
gcloud artifacts repositories create "bringee-artifacts" \
  --project="${PROJECT_ID}" \
  --location="us-central1" \
  --repository-format="DOCKER"

# Service Accounts für Cloud Run erstellen
gcloud iam service-accounts create "user-service-sa" \
  --project="${PROJECT_ID}" \
  --display-name="User Service SA"

gcloud iam service-accounts create "shipment-service-sa" \
  --project="${PROJECT_ID}" \
  --display-name="Shipment Service SA"
```

## 🔧 Schritt 6: Testen

1. **Code pushen:**
   ```bash
   git add .
   git commit -m "Test simple authentication"
   git push origin main
   ```

2. **GitHub Actions überprüfen:**
   - Gehen Sie zu Ihrem Repository
   - Klicken Sie auf "Actions"
   - Überprüfen Sie den Workflow-Lauf

## 🔧 Troubleshooting

### Fehler: "permission denied"
- Stellen Sie sicher, dass alle IAM-Berechtigungen korrekt zugewiesen wurden
- Überprüfen Sie, dass der Service Account Key korrekt in GitHub Secrets gespeichert ist

### Fehler: "repository not found"
- Stellen Sie sicher, dass das Artifact Registry Repository erstellt wurde
- Überprüfen Sie die Repository-Namen und -Standorte

### Fehler: "service account not found"
- Stellen Sie sicher, dass die Service Accounts für Cloud Run erstellt wurden
- Überprüfen Sie die Service Account Namen

## 🔐 Sicherheitshinweise

⚠️ **Wichtig:** Service Account Keys sind weniger sicher als Workload Identity Federation:
- Rotieren Sie die Keys regelmäßig
- Verwenden Sie minimale Berechtigungen
- Überwachen Sie die Key-Nutzung

## 📞 Support

Bei Problemen:
1. Überprüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Google Cloud Console Logs
3. Stellen Sie sicher, dass alle Secrets korrekt gesetzt sind