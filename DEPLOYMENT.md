# Bringee - Automatische Deployment-Konfiguration

Diese Anleitung erklärt, wie Sie Ihr Bringee-Projekt mit Google Cloud verbinden, um automatische Deployments zu ermöglichen.

## 🏗️ Architektur

Das System verwendet:
- **GitHub Actions** für CI/CD
- **Google Cloud Run** für Container-Deployments
- **Artifact Registry** für Docker-Images
- **Workload Identity Federation** für sichere Authentifizierung
- **Terraform** für Infrastructure as Code

## 📋 Voraussetzungen

1. **Google Cloud Projekt** mit aktiviertem Billing
2. **GitHub Repository** mit dem Bringee-Code
3. **gcloud CLI** installiert und authentifiziert
4. **Terraform** installiert

## 🚀 Schnellstart

### 1. Setup-Skript ausführen

```bash
./scripts/setup-gcp.sh
```

Das Skript wird Sie durch folgende Schritte führen:
- Projekt-Konfiguration eingeben
- Terraform State Bucket erstellen
- GCP APIs aktivieren
- Infrastruktur deployen

### 2. GitHub Secrets konfigurieren

Fügen Sie folgende Secrets zu Ihrem GitHub Repository hinzu:

| Secret Name | Beschreibung |
|-------------|--------------|
| `GCP_PROJECT_ID` | Ihre GCP Project ID |
| `GCP_REGION` | GCP Region (z.B. us-central1) |

### 3. Code pushen

```bash
git add .
git commit -m "Setup automatic deployment"
git push origin main
```

## 🔧 Manuelle Konfiguration

### Terraform-Konfiguration

1. **Variablen konfigurieren:**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Bearbeiten Sie die Datei mit Ihren Werten
   ```

2. **Infrastruktur deployen:**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

### GitHub Actions Workflow

Der Workflow in `.github/workflows/ci-cd.yml` führt folgende Schritte aus:

1. **Tests:** Führt Tests für alle Backend-Services aus
2. **Build:** Erstellt Docker-Images
3. **Push:** Lädt Images in Artifact Registry hoch
4. **Deploy:** Deployt Services zu Cloud Run

## 📁 Projektstruktur

```
bringee/
├── .github/workflows/ci-cd.yml    # GitHub Actions Workflow
├── terraform/                     # Infrastructure as Code
│   ├── main.tf                   # Hauptkonfiguration
│   ├── iam.tf                    # IAM & Workload Identity
│   ├── cloud-run.tf              # Cloud Run Services
│   ├── variables.tf              # Terraform Variablen
│   └── terraform.tfvars.example  # Beispiel-Konfiguration
├── scripts/setup-gcp.sh          # Setup-Skript
└── backend/services/              # Backend-Services
    ├── user-service/
    └── shipment-service/
```

## 🔐 Sicherheit

### Workload Identity Federation

Das System verwendet Workload Identity Federation für sichere Authentifizierung:

- **Keine statischen Credentials** in GitHub Secrets
- **Automatische Token-Rotation**
- **Least Privilege Access**

### Service Accounts

- `github-actions-runner`: Für GitHub Actions
- `user-service-sa`: Für User Service
- `shipment-service-sa`: Für Shipment Service

## 🚀 Deployment-Prozess

1. **Code Push** → GitHub Actions Trigger
2. **Tests** → Backend-Services testen
3. **Build** → Docker-Images erstellen
4. **Push** → Images zu Artifact Registry
5. **Deploy** → Cloud Run Services aktualisieren

## 📊 Monitoring

### Cloud Run URLs

Nach dem Deployment erhalten Sie URLs für:
- User Service: `https://user-service-xxx-uc.a.run.app`
- Shipment Service: `https://shipment-service-xxx-uc.a.run.app`

### Logs

- **GitHub Actions:** In GitHub Repository → Actions
- **Cloud Run:** In Google Cloud Console → Cloud Run → Logs

## 🔧 Troubleshooting

### Häufige Probleme

1. **Workload Identity Fehler:**
   ```bash
   # Terraform neu anwenden
   cd terraform
   terraform apply
   ```

2. **Docker Build Fehler:**
   - Prüfen Sie Dockerfile-Pfade
   - Stellen Sie sicher, dass alle Dependencies vorhanden sind

3. **Cloud Run Deployment Fehler:**
   - Prüfen Sie Service Account Berechtigungen
   - Stellen Sie sicher, dass Images in Artifact Registry vorhanden sind

### Debugging

```bash
# Terraform Status prüfen
cd terraform
terraform plan

# Cloud Run Services auflisten
gcloud run services list --region=us-central1

# Logs anzeigen
gcloud run services logs read user-service --region=us-central1
```

## 📈 Skalierung

### Automatische Skalierung

Cloud Run bietet automatische Skalierung:
- **Min Instances:** 0 (spart Kosten)
- **Max Instances:** 10 (begrenzt Kosten)
- **CPU:** 1 vCPU
- **Memory:** 512Mi

### Manuelle Anpassung

Bearbeiten Sie `terraform/cloud-run.tf` für:
- Mehr Ressourcen
- Andere Skalierungsparameter
- Zusätzliche Umgebungsvariablen

## 💰 Kostenoptimierung

- **Cloud Run:** Pay-per-use, keine Kosten bei Inaktivität
- **Artifact Registry:** Günstige Speicherkosten
- **Terraform State:** Minimale GCS-Kosten

## 🔄 Updates

### Neue Version deployen

```bash
git add .
git commit -m "Update services"
git push origin main
```

### Rollback

```bash
# Zu vorheriger Version zurückkehren
git revert HEAD
git push origin main
```

## 📞 Support

Bei Problemen:
1. Prüfen Sie die GitHub Actions Logs
2. Schauen Sie in die Cloud Run Logs
3. Überprüfen Sie die Terraform-Ausgabe
4. Stellen Sie sicher, dass alle Secrets korrekt gesetzt sind