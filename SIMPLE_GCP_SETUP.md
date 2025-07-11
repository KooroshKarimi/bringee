# 🚀 Einfaches Google Cloud Setup für Bringee

## Ohne lokale Installation von gcloud!

### Schritt 1: Google Cloud Projekt erstellen

1. Gehe zu [Google Cloud Console](https://console.cloud.google.com/)
2. Erstelle ein neues Projekt oder wähle ein bestehendes
3. Notiere dir die **Project ID** (z.B. `my-bringee-project-123`)

### Schritt 2: Service Account erstellen

1. In der Google Cloud Console: **IAM & Admin** → **Service Accounts**
2. Klicke **"Create Service Account"**
3. Name: `github-actions-runner`
4. Beschreibung: `Service account for GitHub Actions`
5. Klicke **"Create and Continue"**

#### Berechtigungen hinzufügen:
- **Cloud Run Admin** (`roles/run.admin`)
- **Service Account User** (`roles/iam.serviceAccountUser`)
- **Storage Admin** (`roles/storage.admin`)
- **Artifact Registry Admin** (`roles/artifactregistry.admin`)

6. Klicke **"Done"**

### Schritt 3: Service Account Key erstellen

1. Klicke auf den erstellten Service Account
2. Tab **"Keys"** → **"Add Key"** → **"Create new key"**
3. Wähle **JSON** Format
4. Klicke **"Create"**
5. Die JSON-Datei wird heruntergeladen

### Schritt 4: GitHub Secrets hinzufügen

Gehe zu deinem GitHub Repository: **Settings** → **Secrets and variables** → **Actions**

Füge diese Secrets hinzu:

| Secret Name | Wert |
|-------------|------|
| `GCP_PROJECT_ID` | Deine Project ID (z.B. `my-bringee-project-123`) |
| `GCP_PROJECT_NUMBER` | Deine Project Number (findest du in der Cloud Console) |
| `GCP_SA_KEY` | Der gesamte Inhalt der heruntergeladenen JSON-Datei |

### Schritt 5: Code pushen

```bash
git add .
git commit -m "Setup GCP deployment"
git push origin main
```

### Schritt 6: Deployment überwachen

1. Gehe zu deinem GitHub Repository
2. Tab **"Actions"**
3. Du siehst den laufenden Workflow "Bringee CI/CD"
4. Das Deployment dauert etwa 5-10 Minuten

### Schritt 7: URLs finden

Nach erfolgreichem Deployment findest du die URLs:

1. **Google Cloud Console** → **Cloud Run**
2. Du siehst zwei Services:
   - `user-service`
   - `shipment-service`
3. Klicke auf einen Service für die URL

### 🔧 Troubleshooting

#### Fehler: "Permission denied"
- Prüfe, ob alle Berechtigungen für den Service Account korrekt sind
- Stelle sicher, dass die APIs aktiviert sind

#### Fehler: "Image not found"
- Warte 2-3 Minuten und versuche es erneut
- Prüfe die GitHub Actions Logs

#### APIs aktivieren (falls nötig)
In der Google Cloud Console:
- **APIs & Services** → **Library**
- Suche und aktiviere:
  - Cloud Run API
  - Artifact Registry API
  - Cloud Build API

### 📊 Monitoring

- **GitHub Actions**: Repository → Actions
- **Cloud Run Logs**: Google Cloud Console → Cloud Run → Logs
- **Artifact Registry**: Google Cloud Console → Artifacts

### 💰 Kosten

- **Cloud Run**: Pay-per-use (0€ bei Inaktivität)
- **Artifact Registry**: ~$0.10/GB/Monat
- **Firebase Hosting**: Kostenlos für Standard-Nutzung

---

**Fertig!** 🎉 Deine Bringee-App läuft jetzt automatisch auf Google Cloud!