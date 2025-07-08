# ⚡ Schnellstart - Bringee automatisches Deployment

## 🚀 In 5 Minuten zu automatischem Deployment

### 1. Google Cloud SDK installieren
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud auth login
```

### 2. Setup ausführen
```bash
chmod +x scripts/setup-gcp.sh
./scripts/setup-gcp.sh YOUR_GCP_PROJECT_ID
```

### 3. Terraform konfigurieren
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Bearbeiten Sie terraform.tfvars mit Ihren Werten
```

### 4. Infrastructure deployen
```bash
cd terraform
terraform init
terraform apply
```

### 5. GitHub Secrets hinzufügen
- Gehen Sie zu GitHub Repository → Settings → Secrets
- Fügen Sie `GCP_PROJECT_ID` mit Ihrer Project ID hinzu

### 6. Testen
```bash
git add .
git commit -m "Setup automatic deployment"
git push origin main
```

**Fertig!** 🎉 Ihr Projekt wird jetzt automatisch bei jedem Push deployed.

---

📖 **Detaillierte Anleitung**: Siehe [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)