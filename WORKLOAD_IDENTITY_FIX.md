# Workload Identity Federation Fix

## 🚨 Problem

Der Fehler zeigt, dass der Workload Identity Provider nicht korrekt konfiguriert ist:

```
Error: google-github-actions/auth failed with: failed to generate Google Cloud federated token for //iam.googleapis.com/projects/***/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider: {"error":"invalid_target","error_description":"The target service indicated by the \"audience\" parameters is invalid. This might either be because the pool or provider is disabled or deleted or because it doesn't exist."}
```

## 🔧 Lösung

### Option 1: Automatische Behebung (Empfohlen)

```bash
# 1. Fix-Skript ausführbar machen
chmod +x fix-workload-identity.sh

# 2. Fix ausführen
./fix-workload-identity.sh
```

### Option 2: Manuelle Behebung

#### Schritt 1: Terraform-Konfiguration aktualisieren

Die `terraform/iam.tf` Datei wurde bereits korrigiert mit:

```hcl
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.audience"   = "assertion.aud"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    allowed_audiences = ["https://token.actions.githubusercontent.com"]
  }
}
```

#### Schritt 2: Infrastruktur neu bereitstellen

```bash
cd terraform

# Bestehende Workload Identity Ressourcen zerstören
terraform destroy -target=google_iam_workload_identity_pool_provider.github_provider \
                 -target=google_iam_workload_identity_pool.github_pool \
                 -target=google_service_account_iam_member.github_actions_impersonation \
                 -auto-approve

# Neue Konfiguration anwenden
terraform apply -auto-approve

cd ..
```

#### Schritt 3: GitHub Secrets aktualisieren

```bash
# Neue Werte aus Terraform Output abrufen
cd terraform
GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email)
WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw workload_identity_provider)
cd ..

echo "Service Account: $GITHUB_ACTIONS_SA_EMAIL"
echo "Provider: $WORKLOAD_IDENTITY_PROVIDER"
```

Gehen Sie zu GitHub > Repository > Settings > Secrets > Actions und aktualisieren Sie:

- `GCP_PROJECT_ID`: [Ihr GCP Project ID]
- `GITHUB_ACTIONS_SA_EMAIL`: [Aus Terraform Output]

## 🔍 Überprüfung

### 1. Workload Identity Pool testen

```bash
# Pool auflisten
gcloud iam workload-identity-pools list --location=global --project=[PROJECT_ID]

# Provider auflisten
gcloud iam workload-identity-pools providers list \
  --workload-identity-pool=github-actions-pool \
  --location=global \
  --project=[PROJECT_ID]
```

### 2. Service Account Berechtigungen testen

```bash
# IAM Policy überprüfen
gcloud projects get-iam-policy [PROJECT_ID] \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:github-actions-runner"
```

### 3. GitHub Actions Workflow testen

```bash
# Commit und Push zum Testen
git add .
git commit -m "Fix Workload Identity Federation"
git push origin main
```

## 🐛 Häufige Probleme

### Problem 1: "Pool or provider is disabled or deleted"

**Lösung**: Infrastruktur neu bereitstellen
```bash
./fix-workload-identity.sh
```

### Problem 2: "Invalid audience"

**Lösung**: `allowed_audiences` in Terraform-Konfiguration hinzufügen
```hcl
oidc {
  issuer_uri = "https://token.actions.githubusercontent.com"
  allowed_audiences = ["https://token.actions.githubusercontent.com"]
}
```

### Problem 3: "Repository not found"

**Lösung**: Repository-Namen in GitHub Secrets überprüfen
- Format: `owner/repo` (z.B. `username/bringee`)
- Groß-/Kleinschreibung beachten

### Problem 4: "Service Account not found"

**Lösung**: Service Account neu erstellen
```bash
cd terraform
terraform apply -target=google_service_account.github_actions_sa
cd ..
```

## 📋 Checkliste

Nach der Ausführung des Fix-Skripts sollten Sie haben:

- ✅ Workload Identity Pool: `github-actions-pool`
- ✅ Workload Identity Provider: `github-actions-provider`
- ✅ Service Account: `github-actions-runner@[PROJECT_ID].iam.gserviceaccount.com`
- ✅ IAM Binding: `roles/iam.workloadIdentityUser`
- ✅ GitHub Secrets: `GCP_PROJECT_ID` und `GITHUB_ACTIONS_SA_EMAIL`
- ✅ GitHub Actions Workflow: Korrekte Provider-Konfiguration

## 🎯 Nächste Schritte

1. **Fix ausführen**:
   ```bash
   ./fix-workload-identity.sh
   ```

2. **GitHub Actions testen**:
   ```bash
   git add .
   git commit -m "Fix Workload Identity Federation"
   git push origin main
   ```

3. **Monitoring**:
   - GitHub Actions: `https://github.com/[REPO]/actions`
   - Cloud Run: `https://console.cloud.google.com/run`

## 🔗 Nützliche Links

- [Workload Identity Federation Documentation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub Actions GCP Authentication](https://github.com/google-github-actions/auth)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

---

**Hinweis**: Nach der Behebung sollte die GitHub Actions Pipeline erfolgreich durchlaufen und automatisch zu Cloud Run deployen! 🚀