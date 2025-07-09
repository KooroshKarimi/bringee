# 🚀 Bringee GCP Deployment Checklist

## Voraussetzungen
- [ ] Google Cloud Projekt erstellt
- [ ] Google Cloud SDK installiert (`gcloud`)
- [ ] Terraform installiert
- [ ] Docker installiert
- [ ] GitHub Repository mit Code

## Schnellstart (5 Minuten)

### 1. Google Cloud Projekt einrichten
```bash
# Google Cloud SDK installieren (falls nicht vorhanden)
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Authentifizieren
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Terraform Infrastruktur deployen
```bash
# Terraform initialisieren und deployen
cd terraform
terraform init
terraform apply -var="gcp_project_id=YOUR_PROJECT_ID" -var="github_repository=YOUR_USERNAME/bringee"
cd ..
```

### 3. GitHub Secrets konfigurieren
1. Gehen Sie zu Ihrem GitHub Repository
2. Settings > Secrets and variables > Actions
3. Fügen Sie diese Secrets hinzu:
   - `GCP_PROJECT_ID`: Ihre GCP Project ID
   - `GCP_SA_KEY`: Service Account JSON Key

### 4. Deployment testen
```bash
# Push zum main branch
git add .
git commit -m "Initial deployment"
git push origin main
```

## Manuelles Deployment (Alternative)

Falls die CI/CD Pipeline nicht funktioniert:

```bash
# Deployment-Skript ausführen
chmod +x deploy-to-gcp.sh
./deploy-to-gcp.sh
```

## Überprüfung

Nach dem Deployment sollten Sie folgende Services haben:

### Backend Services
- [ ] User Service: `https://user-service-xxx-ew.a.run.app`
- [ ] Shipment Service: `https://shipment-service-xxx-ew.a.run.app`

### Frontend
- [ ] Flutter Web App: `https://YOUR_PROJECT_ID.web.app`

## Troubleshooting

### Fehler: "Permission denied"
```bash
# Service Account Rollen überprüfen
gcloud projects get-iam-policy YOUR_PROJECT_ID
```

### Fehler: "Project not found"
```bash
# Projekt auflisten
gcloud projects list
```

### Fehler: "Artifact Registry not found"
```bash
# Terraform erneut ausführen
cd terraform
terraform apply
cd ..
```

## Nützliche Befehle

```bash
# Services auflisten
gcloud run services list

# Logs anzeigen
gcloud run services logs read user-service

# Service URL abrufen
gcloud run services describe user-service --format="value(status.url)"
```

## Support

Bei Problemen:
1. Überprüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Google Cloud Console
3. Überprüfen Sie die Service Logs
4. Konsultieren Sie die Troubleshooting-Dokumentation