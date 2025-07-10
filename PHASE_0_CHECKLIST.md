# ✅ Phase 0 Checklist - Google Cloud Deployment

## 🎯 Ziel: Phase 0 vollständig auf Google Cloud zum Laufen bringen

### 📋 Voraussetzungen

- [ ] Google Cloud SDK installiert
- [ ] Terraform installiert
- [ ] Docker installiert (optional für lokale Tests)
- [ ] GitHub Repository konfiguriert
- [ ] GCP Project erstellt und Abrechnung aktiviert

### 🛠️ Setup Schritte

#### 1. Google Cloud Konfiguration
- [ ] Bei Google Cloud angemeldet (`gcloud auth login`)
- [ ] Projekt ausgewählt (`gcloud config set project YOUR_PROJECT_ID`)
- [ ] APIs aktiviert (IAM, Cloud Run, Artifact Registry, etc.)

#### 2. Terraform Setup
- [ ] Terraform State Bucket erstellt
- [ ] `terraform.tfvars` konfiguriert
- [ ] Infrastructure deployed (`terraform apply`)

#### 3. GitHub Secrets
- [ ] `GCP_PROJECT_ID` hinzugefügt
- [ ] `GITHUB_ACTIONS_SA_EMAIL` hinzugefügt
- [ ] Workload Identity Provider konfiguriert

#### 4. Pipeline Test
- [ ] Commit zum main Branch gepusht
- [ ] GitHub Actions Workflow gestartet
- [ ] Docker Images erfolgreich gebaut
- [ ] Services erfolgreich deployed

### 🧪 Testing

#### Lokale Tests
- [ ] User Service läuft lokal (`go run main.go`)
- [ ] Shipment Service läuft lokal (`go run main.go`)
- [ ] Health Checks funktionieren (`curl /health`)
- [ ] Docker Images bauen erfolgreich

#### Cloud Tests
- [ ] Cloud Run Services sind erreichbar
- [ ] Health Endpoints funktionieren
- [ ] Logs sind verfügbar
- [ ] Artifact Registry Images sind gepusht

### 📊 Monitoring

#### GitHub Actions
- [ ] Workflow läuft ohne Fehler
- [ ] Tests sind erfolgreich
- [ ] Builds sind erfolgreich
- [ ] Deployments sind erfolgreich

#### Google Cloud
- [ ] Cloud Run Services sind aktiv
- [ ] Artifact Registry Images sind vorhanden
- [ ] IAM-Rollen sind korrekt
- [ ] Logs sind verfügbar

### 🚀 Erfolgskriterien

Phase 0 ist erfolgreich, wenn:

1. **✅ Automatisches Deployment**
   - Push zum main Branch triggert automatisches Deployment
   - Docker Images werden automatisch gebaut und gepusht
   - Services werden automatisch auf Cloud Run deployed

2. **✅ Services sind erreichbar**
   - User Service: `https://user-service-xxx-ew.a.run.app`
   - Shipment Service: `https://shipment-service-xxx-ew.a.run.app`
   - Health Checks funktionieren: `/health` Endpoint

3. **✅ Infrastructure as Code**
   - Terraform State ist gespeichert
   - Infrastructure kann reproduziert werden
   - Änderungen werden über Terraform verwaltet

4. **✅ Sicherheit**
   - Workload Identity Federation konfiguriert
   - Keine hartcodierten Secrets
   - IAM-Rollen sind minimal und sicher

5. **✅ Monitoring & Logging**
   - Logs sind in Cloud Logging verfügbar
   - Services sind über Cloud Run Console sichtbar
   - Health Checks sind konfiguriert

### 🔍 Troubleshooting

#### Häufige Probleme:

**Problem: "Permission denied"**
```bash
# Lösung: Überprüfe IAM-Rollen
gcloud projects get-iam-policy YOUR_PROJECT_ID
```

**Problem: "Artifact Registry not found"**
```bash
# Lösung: Erstelle Registry manuell
gcloud artifacts repositories create bringee-artifacts \
  --repository-format=docker \
  --location=europe-west3
```

**Problem: "Terraform state bucket not found"**
```bash
# Lösung: Erstelle Bucket manuell
gsutil mb -p YOUR_PROJECT_ID -c STANDARD -l europe-west3 gs://bringee-terraform-state-unique
```

**Problem: "GitHub Actions not triggered"**
- Überprüfe, ob Workflow in `.github/workflows/ci-cd.yml` existiert
- Stelle sicher, dass du auf main Branch pushst
- Überprüfe GitHub Actions Logs

### 📈 Nächste Schritte

Nach erfolgreichem Phase 0:

1. **Phase 1:** Backend Services erweitern
   - Datenbank-Integration (Cloud SQL/Firestore)
   - Echte Business-Logik implementieren
   - API-Endpunkte hinzufügen

2. **Phase 2:** Frontend entwickeln
   - Flutter App erweitern
   - UI/UX implementieren
   - Backend-Integration

3. **Phase 3:** Integration & Testing
   - End-to-End Tests
   - Performance Testing
   - Security Testing

4. **Phase 4:** Production Deployment
   - Production Environment
   - Monitoring & Alerting
   - Backup & Recovery

### 🎉 Erfolg!

Wenn alle Punkte abgehakt sind, ist Phase 0 erfolgreich abgeschlossen und das Fundament für das Bringee-Projekt ist bereit!

---

**💡 Tipp:** Verwende das `quick-phase0-setup.sh` Skript für automatisches Setup!