# ✅ Einfache Checkliste - GitHub ↔ Google Cloud Verbindung

Basierend auf Ihrem anderen Projekt - hier sind die **exakten Schritte**:

## 🔧 Google Cloud Console Setup

### **1. APIs aktivieren**
- [ ] Gehen Sie zu: **APIs & Services → Library**
- [ ] Aktivieren Sie:
  - `Cloud Run API`
  - `Artifact Registry API`
  - `Cloud Build API`
  - `IAM Service Account Credentials API`

### **2. Workload Identity Federation**
- [ ] Gehen Sie zu: **IAM & Admin → Workload Identity Federation**
- [ ] **CREATE POOL:**
  - Pool ID: `github-actions-pool`
  - Display name: `GitHub Actions Pool`
- [ ] **CREATE PROVIDER:**
  - Provider ID: `github-actions-provider`
  - Issuer URI: `https://token.actions.githubusercontent.com`
  - Attribute mapping:
    ```
    google.subject = assertion.sub
    attribute.actor = assertion.actor
    attribute.repository = assertion.repository
    ```

### **3. Service Account erstellen**
- [ ] Gehen Sie zu: **IAM & Admin → Service Accounts**
- [ ] **CREATE SERVICE ACCOUNT:**
  - Service account name: `github-actions-runner`
  - Display name: `GitHub Actions Runner`
- [ ] **Rollen hinzufügen:**
  - `Artifact Registry Writer`
  - `Cloud Run Admin`
  - `Service Account User`
  - `Cloud Build Service Account`

### **4. Workload Identity Binding**
- [ ] Klicken Sie auf den Service Account
- [ ] Tab **PERMISSIONS**
- [ ] **GRANT ACCESS**
- [ ] New principals: `principalSet://iam.googleapis.com/projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/YOUR_GITHUB_USERNAME/bringee`
- [ ] Role: `Workload Identity User`

### **5. Artifact Registry Repository**
- [ ] Gehen Sie zu: **Artifact Registry → Repositories**
- [ ] **CREATE REPOSITORY:**
  - Repository ID: `bringee-artifacts`
  - Format: `Docker`
  - Location: `us-central1`

## 🔧 GitHub Repository Setup

### **6. GitHub Secrets hinzufügen**
- [ ] Gehen Sie zu: **Settings → Secrets and variables → Actions**
- [ ] **New repository secret:**

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

### **7. Workflow-Datei verwenden**
- [ ] Verwenden Sie die Datei: `.github/workflows/ci-cd-simple.yml`
- [ ] Oder kopieren Sie den Inhalt in `.github/workflows/ci-cd.yml`

## 🧪 Testen

### **8. Test-Deployment**
- [ ] Push auf `main` Branch
- [ ] Gehen Sie zu: **Actions Tab**
- [ ] Überprüfen Sie, ob der Workflow erfolgreich läuft

### **9. Überprüfung**
- [ ] **Google Cloud Console → Cloud Run** (Services sollten erstellt sein)
- [ ] **Google Cloud Console → Artifact Registry** (Docker Images sollten gepusht sein)
- [ ] **GitHub → Actions** (Workflow sollte erfolgreich sein)

## ✅ Erfolgsanzeichen

Wenn alles funktioniert, sehen Sie:
- ✅ GitHub Actions läuft erfolgreich
- ✅ Docker Images werden zu Artifact Registry gepusht
- ✅ Cloud Run Services werden automatisch deployed
- ✅ Service URLs sind verfügbar

## 🎉 Fertig!

**Nach der Einrichtung wird bei jedem Push auf `main` automatisch deployed!**

---

**Hinweis:** Ersetzen Sie `YOUR_GCP_PROJECT_ID`, `YOUR_PROJECT_NUMBER` und `YOUR_GITHUB_USERNAME` mit Ihren tatsächlichen Werten.