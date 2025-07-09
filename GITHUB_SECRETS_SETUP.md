# GitHub Secrets Setup für Bringee CI/CD

Diese Anleitung zeigt, wie Sie die GitHub Secrets konfigurieren, die für das automatische Deployment in Google Cloud Platform benötigt werden.

## Benötigte Secrets

### 1. GCP_PROJECT_ID
**Beschreibung:** Die ID Ihres Google Cloud Projekts
**Wert:** z.B. `bringee-project-123456`

### 2. GCP_SA_KEY
**Beschreibung:** Der JSON-Schlüssel für den Service Account, der von GitHub Actions verwendet wird
**Wert:** Der komplette JSON-Inhalt der Service Account Key-Datei

## Schritt-für-Schritt Anleitung

### Schritt 1: Google Cloud Service Account erstellen

1. Gehen Sie zur [Google Cloud Console](https://console.cloud.google.com/)
2. Wählen Sie Ihr Projekt aus
3. Gehen Sie zu "IAM & Admin" > "Service Accounts"
4. Klicken Sie auf "Create Service Account"
5. Geben Sie einen Namen ein (z.B. `github-actions`)
6. Klicken Sie auf "Create and Continue"
7. Fügen Sie die folgenden Rollen hinzu:
   - Cloud Run Admin
   - Storage Admin
   - Artifact Registry Admin
   - Service Account User
8. Klicken Sie auf "Done"

### Schritt 2: Service Account Key erstellen

1. Klicken Sie auf den erstellten Service Account
2. Gehen Sie zum Tab "Keys"
3. Klicken Sie auf "Add Key" > "Create new key"
4. Wählen Sie "JSON" aus
5. Klicken Sie auf "Create"
6. Die JSON-Datei wird automatisch heruntergeladen

### Schritt 3: GitHub Secrets konfigurieren

1. Gehen Sie zu Ihrem GitHub Repository
2. Klicken Sie auf "Settings"
3. Klicken Sie auf "Secrets and variables" > "Actions"
4. Klicken Sie auf "New repository secret"

#### Secret 1: GCP_PROJECT_ID
- **Name:** `GCP_PROJECT_ID`
- **Value:** Ihre GCP Project ID (z.B. `bringee-project-123456`)

#### Secret 2: GCP_SA_KEY
- **Name:** `GCP_SA_KEY`
- **Value:** Der komplette Inhalt der heruntergeladenen JSON-Datei

### Schritt 4: Workload Identity Provider konfigurieren (Optional)

Für eine sicherere Authentifizierung können Sie Workload Identity verwenden:

1. Führen Sie das Terraform-Setup aus:
   ```bash
   ./setup-gcp-deployment.sh
   ```

2. Das Skript erstellt automatisch einen Workload Identity Provider

3. Verwenden Sie dann diese Secrets:
   - `GCP_PROJECT_ID`: Ihre GCP Project ID
   - `GITHUB_ACTIONS_SA_EMAIL`: Die E-Mail des Service Accounts (wird von Terraform erstellt)

## Verwendung

Nach der Konfiguration der Secrets:

1. Pushen Sie einen Commit zum `main` Branch
2. Die GitHub Actions werden automatisch ausgelöst
3. Die Services werden automatisch deployed

## Troubleshooting

### Fehler: "Permission denied"
- Überprüfen Sie, ob der Service Account die richtigen Rollen hat
- Stellen Sie sicher, dass die GCP_SA_KEY korrekt kopiert wurde

### Fehler: "Project not found"
- Überprüfen Sie, ob die GCP_PROJECT_ID korrekt ist
- Stellen Sie sicher, dass das Projekt existiert und Sie Zugriff haben

### Fehler: "Artifact Registry not found"
- Das Terraform-Setup muss zuerst ausgeführt werden
- Führen Sie `./setup-gcp-deployment.sh` aus

## Nützliche Links

- [Google Cloud IAM Documentation](https://cloud.google.com/iam/docs)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)