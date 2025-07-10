# 🚀 Phase 0 - Quick Start Guide

## ⚡ Schnelle Einrichtung von Phase 0 auf Google Cloud

### Voraussetzungen
- ✅ Google Cloud Projekt erstellt
- ✅ Google Cloud SDK installiert
- ✅ Terraform installiert
- ✅ Docker installiert
- ✅ Go installiert

### 1. Konfiguration setzen
```bash
# Projekt-Konfiguration
export GCP_PROJECT_ID="ihr-projekt-id"
export GCP_REGION="europe-west3"
export GITHUB_REPO="ihr-username/bringee"

# Beispiel:
export GCP_PROJECT_ID="bringee-project-123456"
export GCP_REGION="europe-west3"
export GITHUB_REPO="koorosh/bringee"
```

### 2. Google Cloud authentifizieren
```bash
# Anmelden
gcloud auth login

# Projekt setzen
gcloud config set project $GCP_PROJECT_ID
```

### 3. Phase 0 Setup ausführen
```bash
# Setup-Skript ausführen
./setup-phase0-gcp.sh
```

### 4. GitHub Secrets konfigurieren

**Gehen Sie zu:** https://github.com/ihr-username/bringee/settings/secrets/actions

**Fügen Sie diese Secrets hinzu:**

| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | `ihr-projekt-id` |
| `GITHUB_ACTIONS_SA_EMAIL` | `github-actions@ihr-projekt-id.iam.gserviceaccount.com` |

### 5. Testen
```bash
# Services testen
curl https://user-service-xxxxx-ew.a.run.app/
curl https://shipment-service-xxxxx-ew.a.run.app/

# Health checks
curl https://user-service-xxxxx-ew.a.run.app/health
curl https://shipment-service-xxxxx-ew.a.run.app/health
```

### 6. CI/CD Pipeline testen
```bash
# Commit pushen
git add .
git commit -m "Test Phase 0 deployment"
git push origin main
```

**Überwachen Sie:** https://github.com/ihr-username/bringee/actions

## ✅ Erfolgsindikatoren

- [ ] Terraform Infrastructure deployed
- [ ] Docker Images in Artifact Registry
- [ ] Cloud Run Services laufen
- [ ] Health Checks erfolgreich
- [ ] GitHub Actions Workflow funktioniert

## 🔗 Nützliche Links

- **Google Cloud Console:** https://console.cloud.google.com/
- **Cloud Run:** https://console.cloud.google.com/run
- **Artifact Registry:** https://console.cloud.google.com/artifacts
- **GitHub Actions:** https://github.com/ihr-username/bringee/actions

## 🆘 Bei Problemen

1. **Logs überprüfen:** Google Cloud Console > Logs
2. **Terraform Status:** `cd terraform && terraform plan`
3. **Service Account:** IAM & Admin > Service Accounts
4. **GitHub Secrets:** Repository > Settings > Secrets

---

**🎉 Phase 0 ist erfolgreich, wenn alle Services deployed sind und die CI/CD Pipeline funktioniert!**