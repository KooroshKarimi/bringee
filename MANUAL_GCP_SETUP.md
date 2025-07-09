# Manuelle GCP Setup-Anleitung für Bringee

## 🎯 Ziel
Diese Anleitung hilft Ihnen dabei, die GitHub-GCP-Verbindung manuell einzurichten, um automatische Deployments zu ermöglichen.

## 📋 Voraussetzungen

1. **Google Cloud Projekt** mit aktiviertem Billing
2. **GitHub Repository**: `KooroshKarimi/bringee`
3. **Google Cloud Console** Zugang
4. **GitHub Repository** Zugang

## 🚀 Schritt-für-Schritt Anleitung

### Schritt 1: Google Cloud APIs aktivieren

1. Gehen Sie zur [Google Cloud Console](https://console.cloud.google.com/)
2. Wählen Sie Ihr Projekt aus
3. Gehen Sie zu **APIs & Services** > **Library**
4. Aktivieren Sie folgende APIs:
   - `IAM Service Account Credentials API`
   - `Cloud Resource Manager API`
   - `Artifact Registry API`
   - `Cloud Run API`
   - `IAM API`
   - `Logging API`
   - `Monitoring API`

### Schritt 2: Terraform State Bucket erstellen

1. Gehen Sie zu **Cloud Storage** > **Buckets**
2. Klicken Sie auf **CREATE BUCKET**
3. Geben Sie einen eindeutigen Namen ein: `bringee-terraform-state-[TIMESTAMP]`
4. Wählen Sie **Region**: `europe-west3`
5. Wählen Sie **Storage class**: `Standard`
6. Klicken Sie auf **CREATE**

### Schritt 3: Terraform-Konfiguration anpassen

1. Öffnen Sie `terraform/main.tf`
2. Ersetzen Sie `bringee-terraform-state-bucket-unique` mit Ihrem Bucket-Namen
3. Erstellen Sie `terraform/terraform.tfvars`:

```hcl
gcp_project_id = "IHR_PROJECT_ID"
gcp_region     = "europe-west3"
github_repository = "KooroshKarimi/bringee"
```

### Schritt 4: Terraform lokal ausführen

```bash
# Terraform installieren (falls nicht vorhanden)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Terraform initialisieren und ausführen
cd terraform
terraform init
terraform plan
terraform apply
```

### Schritt 5: GitHub Secrets konfigurieren

1. Gehen Sie zu [GitHub Repository](https://github.com/KooroshKarimi/bringee)
2. Gehen Sie zu **Settings** > **Secrets and variables** > **Actions**
3. Fügen Sie folgende Secrets hinzu:

| Secret Name | Wert |
|-------------|------|
| `GCP_PROJECT_ID` | Ihre GCP Project ID |
| `GITHUB_ACTIONS_SA_EMAIL` | `github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com` |

### Schritt 6: Workload Identity Provider konfigurieren

1. Gehen Sie zur [Google Cloud Console](https://console.cloud.google.com/)
2. Gehen Sie zu **IAM & Admin** > **Workload Identity Federation**
3. Klicken Sie auf **CREATE POOL**
4. Name: `github-actions-pool`
5. Klicken Sie auf **CREATE PROVIDER**
6. Name: `github-actions-provider`
7. Issuer: `https://token.actions.githubusercontent.com`
8. Attribute mapping:
   - `google.subject`: `assertion.sub`
   - `attribute.actor`: `assertion.actor`
   - `attribute.repository`: `assertion.repository`
9. Klicken Sie auf **SAVE**

### Schritt 7: Service Account konfigurieren

1. Gehen Sie zu **IAM & Admin** > **Service Accounts**
2. Erstellen Sie einen Service Account: `github-actions-runner`
3. Fügen Sie folgende Rollen hinzu:
   - `Artifact Registry Writer`
   - `Cloud Run Admin`
   - `Service Account User`
   - `Logs Writer`

### Schritt 8: Workload Identity Binding erstellen

```bash
# Ersetzen Sie [PROJECT_ID] mit Ihrer Project ID
gcloud iam service-accounts add-iam-policy-binding \
  github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/[PROJECT_ID]/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/KooroshKarimi/bringee"
```

### Schritt 9: Test-Deployment ausführen

```bash
# Änderungen committen und pushen
git add .
git commit -m "Setup GCP deployment pipeline"
git push origin main
```

## 🔍 Verifizierung

### GitHub Actions überprüfen

1. Gehen Sie zu [GitHub Actions](https://github.com/KooroshKarimi/bringee/actions)
2. Überprüfen Sie, ob der Workflow erfolgreich läuft
3. Schauen Sie sich die Logs an, falls Fehler auftreten

### Cloud Run Services überprüfen

1. Gehen Sie zur [Google Cloud Console](https://console.cloud.google.com/)
2. Gehen Sie zu **Cloud Run**
3. Überprüfen Sie, ob die Services deployed sind:
   - `user-service`
   - `shipment-service`

### Service URLs testen

```bash
# Service URLs abrufen
cd terraform
terraform output user_service_url
terraform output shipment_service_url

# Services testen
curl [USER_SERVICE_URL]/health
curl [SHIPMENT_SERVICE_URL]/health
```

## 🐛 Troubleshooting

### Häufige Probleme

1. **Authentifizierung fehlschlägt**
   - Überprüfen Sie die Workload Identity Konfiguration
   - Stellen Sie sicher, dass die GitHub Secrets korrekt gesetzt sind

2. **Docker Build fehlschlägt**
   - Überprüfen Sie die Dockerfile-Pfade
   - Stellen Sie sicher, dass alle Dependencies vorhanden sind

3. **Cloud Run Deployment fehlschlägt**
   - Überprüfen Sie die Service Account Berechtigungen
   - Stellen Sie sicher, dass Images in Artifact Registry vorhanden sind

### Debugging

```bash
# Terraform Status prüfen
cd terraform
terraform plan

# Cloud Run Services auflisten
gcloud run services list --region=europe-west3

# Logs anzeigen
gcloud run services logs read user-service --region=europe-west3
```

## 📞 Support

Bei Problemen:
1. Prüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Cloud Run Logs
3. Überprüfen Sie die Terraform-Ausgabe
4. Stellen Sie sicher, dass alle Secrets korrekt gesetzt sind

## 🎉 Erfolg!

Nach erfolgreicher Einrichtung haben Sie:

✅ **Automatisches Deployment** bei jedem Push auf main  
✅ **Sichere Authentifizierung** via Workload Identity Federation  
✅ **Infrastructure as Code** mit Terraform  
✅ **Container-Deployment** zu Cloud Run  
✅ **Docker Image Management** in Artifact Registry  
✅ **Monitoring und Logging** in Google Cloud Console  

Ihre GitHub-GCP-Verbindung ist jetzt bereit für automatisches Deployment! 🚀