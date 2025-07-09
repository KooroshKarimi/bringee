# 🌐 GitHub ↔ Google Cloud Verbindung über Web-Interfaces

Diese Anleitung zeigt Ihnen, wie Sie GitHub und Google Cloud **nur über Web-Interfaces** verbinden, ohne lokal etwas zu installieren.

## 📋 Voraussetzungen

- ✅ Google Cloud Projekt mit aktivierter Abrechnung
- ✅ GitHub Repository mit Ihrem Bringee-Projekt
- ✅ Zugriff auf Google Cloud Console
- ✅ Zugriff auf GitHub Repository Settings

## 🔧 Schritt-für-Schritt Einrichtung

### **Schritt 1: Google Cloud Console - APIs aktivieren**

1. **Gehen Sie zu [Google Cloud Console](https://console.cloud.google.com/)**
2. **Wählen Sie Ihr Projekt aus**
3. **Gehen Sie zu: APIs & Services → Library**
4. **Aktivieren Sie diese APIs:**
   - `Cloud Run API`
   - `Artifact Registry API`
   - `Cloud Build API`
   - `IAM Service Account Credentials API`

### **Schritt 2: Workload Identity Federation einrichten**

1. **Gehen Sie zu: IAM & Admin → Workload Identity Federation**
2. **Klicken Sie auf "CREATE POOL"**
3. **Konfiguration:**
   ```
   Pool ID: github-actions-pool
   Display name: GitHub Actions Pool
   Description: Pool for GitHub Actions runners
   ```
4. **Klicken Sie auf "CREATE PROVIDER"**
5. **Konfiguration:**
   ```
   Provider ID: github-actions-provider
   Display name: GitHub Actions Provider
   Issuer URI: https://token.actions.githubusercontent.com
   ```
6. **Attribute mapping hinzufügen:**
   ```
   google.subject = assertion.sub
   attribute.actor = assertion.actor
   attribute.repository = assertion.repository
   ```

### **Schritt 3: Service Account erstellen**

1. **Gehen Sie zu: IAM & Admin → Service Accounts**
2. **Klicken Sie auf "CREATE SERVICE ACCOUNT"**
3. **Konfiguration:**
   ```
   Service account name: github-actions-runner
   Display name: GitHub Actions Runner
   Description: Service account for GitHub Actions deployments
   ```
4. **Klicken Sie auf "CREATE AND CONTINUE"**
5. **Rollen hinzufügen:**
   - `Artifact Registry Writer`
   - `Cloud Run Admin`
   - `Service Account User`
   - `Cloud Build Service Account`
6. **Klicken Sie auf "DONE"**

### **Schritt 4: Workload Identity Binding**

1. **Klicken Sie auf den Service Account** `github-actions-runner@YOUR_PROJECT_ID.iam.gserviceaccount.com`
2. **Gehen Sie zum Tab "PERMISSIONS"**
3. **Klicken Sie auf "GRANT ACCESS"**
4. **Fügen Sie hinzu:**
   ```
   New principals: principalSet://iam.googleapis.com/projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/YOUR_GITHUB_USERNAME/bringee
   Role: Workload Identity User
   ```

### **Schritt 5: Artifact Registry Repository erstellen**

1. **Gehen Sie zu: Artifact Registry → Repositories**
2. **Klicken Sie auf "CREATE REPOSITORY"**
3. **Konfiguration:**
   ```
   Repository ID: bringee-artifacts
   Format: Docker
   Location: us-central1
   Description: Docker repository for Bringee microservices
   ```

### **Schritt 6: GitHub Secrets hinzufügen**

1. **Gehen Sie zu Ihrem GitHub Repository**
2. **Settings → Secrets and variables → Actions**
3. **Klicken Sie auf "New repository secret"**
4. **Fügen Sie diese 3 Secrets hinzu:**

   **Secret 1:**
   ```
   Name: GCP_PROJECT_ID
   Value: YOUR_GCP_PROJECT_ID
   ```

   **Secret 2:**
   ```
   Name: WORKLOAD_IDENTITY_PROVIDER
   Value: projects/YOUR_PROJECT_ID/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider
   ```

   **Secret 3:**
   ```
   Name: SERVICE_ACCOUNT
   Value: github-actions-runner@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

### **Schritt 7: GitHub Actions Workflow aktualisieren**

1. **Ersetzen Sie die Datei `.github/workflows/ci-cd.yml` mit `.github/workflows/ci-cd-simple.yml`**
2. **Oder kopieren Sie den Inhalt von `ci-cd-simple.yml` in `ci-cd.yml`**

### **Schritt 8: Testen**

1. **Gehen Sie zu Ihrem GitHub Repository**
2. **Erstellen Sie einen Test-Commit:**
   ```bash
   git add .
   git commit -m "Test automatic deployment"
   git push origin main
   ```
3. **Gehen Sie zu: Actions Tab**
4. **Überprüfen Sie, ob der Workflow erfolgreich läuft**

## 🔍 Überprüfung der Verbindung

### **GitHub Actions Logs überprüfen:**

1. **Gehen Sie zu GitHub Repository → Actions**
2. **Klicken Sie auf den neuesten Workflow**
3. **Überprüfen Sie die Logs für Fehler**

### **Google Cloud Console überprüfen:**

1. **Gehen Sie zu: Cloud Run**
2. **Überprüfen Sie, ob Services erstellt wurden**
3. **Gehen Sie zu: Artifact Registry**
4. **Überprüfen Sie, ob Docker Images gepusht wurden**

## 🛠️ Troubleshooting

### **Häufige Fehler:**

1. **"Permission denied"**
   - Überprüfen Sie die Service Account Rollen
   - Stellen Sie sicher, dass Workload Identity korrekt konfiguriert ist

2. **"Repository not found"**
   - Überprüfen Sie die Artifact Registry Repository ID
   - Stellen Sie sicher, dass das Repository in us-central1 erstellt wurde

3. **"Authentication failed"**
   - Überprüfen Sie die GitHub Secrets
   - Stellen Sie sicher, dass die Workload Identity Provider URL korrekt ist

### **Debugging:**

1. **GitHub Actions Logs:** Repository → Actions → Workflow → Job → Step
2. **Google Cloud Logs:** Cloud Console → Logging → Queries
3. **Service Account Test:** IAM & Admin → Service Accounts → Permissions

## ✅ Erfolgsanzeichen

Wenn alles korrekt eingerichtet ist, sollten Sie sehen:

- ✅ **GitHub Actions** läuft erfolgreich
- ✅ **Docker Images** werden zu Artifact Registry gepusht
- ✅ **Cloud Run Services** werden automatisch deployed
- ✅ **Service URLs** sind verfügbar in Cloud Run

## 🎉 Fertig!

Nach der Einrichtung wird bei jedem Push auf `main` automatisch:

1. **Tests ausgeführt**
2. **Docker Images gebaut und gepusht**
3. **Cloud Run Services deployed**
4. **Frontend gebaut und deployed** (falls konfiguriert)

**Ihr automatisches Deployment ist jetzt aktiv!** 🚀