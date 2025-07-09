# 🚀 Schnelle GCP Setup-Checkliste für Bringee

## ✅ Was Sie benötigen

- [ ] Google Cloud Projekt mit aktiviertem Billing
- [ ] Zugang zur Google Cloud Console
- [ ] Zugang zum GitHub Repository: `KooroshKarimi/bringee`

## 🔧 Schnelle Einrichtung (5 Minuten)

### 1. Google Cloud APIs aktivieren
Gehen Sie zu [Google Cloud Console](https://console.cloud.google.com/) und aktivieren Sie:
- [ ] IAM Service Account Credentials API
- [ ] Cloud Resource Manager API  
- [ ] Artifact Registry API
- [ ] Cloud Run API
- [ ] IAM API

### 2. Terraform State Bucket erstellen
- [ ] Cloud Storage > Buckets > CREATE BUCKET
- [ ] Name: `bringee-terraform-state-[TIMESTAMP]`
- [ ] Region: `europe-west3`

### 3. GitHub Secrets hinzufügen
Gehen Sie zu [GitHub Repository Settings](https://github.com/KooroshKarimi/bringee/settings/secrets/actions) und fügen Sie hinzu:

| Secret Name | Wert |
|-------------|------|
| `GCP_PROJECT_ID` | Ihre GCP Project ID |
| `GITHUB_ACTIONS_SA_EMAIL` | `github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com` |

### 4. Workload Identity einrichten
```bash
# Service Account erstellen
gcloud iam service-accounts create github-actions-runner \
  --display-name="GitHub Actions Runner"

# Rollen hinzufügen
gcloud projects add-iam-policy-binding [PROJECT_ID] \
  --member="serviceAccount:github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding [PROJECT_ID] \
  --member="serviceAccount:github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Workload Identity Pool erstellen
gcloud iam workload-identity-pools create github-actions-pool \
  --location=global \
  --display-name="GitHub Actions Pool"

# Workload Identity Provider erstellen
gcloud iam workload-identity-pools providers create-oidc github-actions-provider \
  --workload-identity-pool=github-actions-pool \
  --issuer-uri=https://token.actions.githubusercontent.com \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --location=global

# Service Account Binding
gcloud iam service-accounts add-iam-policy-binding \
  github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/[PROJECT_ID]/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/KooroshKarimi/bringee"
```

### 5. Test-Deployment ausführen
```bash
# Änderungen committen und pushen
git add .
git commit -m "Setup GCP deployment pipeline"
git push origin main
```

## 🔍 Verifizierung

### GitHub Actions überprüfen
- [ ] Gehen Sie zu [GitHub Actions](https://github.com/KooroshKarimi/bringee/actions)
- [ ] Überprüfen Sie, ob der Workflow erfolgreich läuft

### Cloud Run Services überprüfen
- [ ] Gehen Sie zu [Cloud Run](https://console.cloud.google.com/run)
- [ ] Überprüfen Sie, ob die Services deployed sind:
  - [ ] `user-service`
  - [ ] `shipment-service`

## 🐛 Häufige Probleme

### Authentifizierung fehlschlägt
- [ ] Überprüfen Sie die GitHub Secrets
- [ ] Stellen Sie sicher, dass Workload Identity korrekt konfiguriert ist

### Docker Build fehlschlägt
- [ ] Überprüfen Sie die Dockerfile-Pfade
- [ ] Stellen Sie sicher, dass alle Dependencies vorhanden sind

### Cloud Run Deployment fehlschlägt
- [ ] Überprüfen Sie die Service Account Berechtigungen
- [ ] Stellen Sie sicher, dass Images in Artifact Registry vorhanden sind

## 📞 Hilfe

Bei Problemen:
1. Prüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Cloud Run Logs
3. Überprüfen Sie die Terraform-Ausgabe

## 🎉 Erfolg!

Nach erfolgreicher Einrichtung haben Sie:
- ✅ Automatisches Deployment bei jedem Push auf main
- ✅ Sichere Authentifizierung via Workload Identity Federation
- ✅ Container-Deployment zu Cloud Run
- ✅ Docker Image Management in Artifact Registry

Ihre GitHub-GCP-Verbindung ist jetzt bereit! 🚀