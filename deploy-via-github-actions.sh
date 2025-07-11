#!/bin/bash

# Deployment über GitHub Actions
# Dieses Skript pusht den Code zu GitHub und löst das Deployment aus

set -e

echo "🚀 Deployment über GitHub Actions - Bringee"
echo "=========================================="

# Konfiguration
GCP_PROJECT_ID=${GCP_PROJECT_ID:-"bringee-project"}
GCP_REGION=${GCP_REGION:-"europe-west3"}

echo "Konfiguration:"
echo "  GCP Project ID: $GCP_PROJECT_ID"
echo "  GCP Region: $GCP_REGION"
echo ""

# Überprüfe Git Repository
if [ ! -d ".git" ]; then
    echo "❌ Kein Git Repository gefunden"
    exit 1
fi

REMOTE_URL=$(git remote get-url origin)
echo "✅ Git Repository: $REMOTE_URL"

# Überprüfe ob wir auf dem main Branch sind
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Sie sind auf Branch: $CURRENT_BRANCH"
    echo "Wechseln Sie zu main: git checkout main"
    exit 1
fi

echo "✅ Auf main Branch"

# Überprüfe ob es uncommitted Changes gibt
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 Uncommitted Changes gefunden:"
    git status --short
    echo ""
    echo "Committing changes..."
    git add .
    git commit -m "Deployment: Update configuration for GCP deployment"
fi

# Push zu GitHub
echo "📤 Push zu GitHub..."
git push origin main

echo ""
echo "✅ Code wurde zu GitHub gepusht"
echo ""
echo "🔐 GitHub Secrets Setup erforderlich:"
echo "===================================="
echo ""
echo "1. Gehen Sie zu: https://github.com/KooroshKarimi/bringee/settings/secrets/actions"
echo ""
echo "2. Fügen Sie folgende Secrets hinzu:"
echo ""
echo "   GCP_PROJECT_ID:"
echo "   - Name: GCP_PROJECT_ID"
echo "   - Value: $GCP_PROJECT_ID"
echo ""
echo "   GCP_SA_KEY:"
echo "   - Name: GCP_SA_KEY"
echo "   - Value: Ihr Google Cloud Service Account Key (JSON)"
echo ""
echo "3. Um einen Service Account Key zu erstellen:"
echo "   - Gehen Sie zu: https://console.cloud.google.com/iam-admin/serviceaccounts"
echo "   - Erstellen Sie einen Service Account mit folgenden Rollen:"
echo "     * Cloud Run Admin"
echo "     * Storage Admin"
echo "     * Artifact Registry Admin"
echo "     * IAM Service Account User"
echo "   - Erstellen Sie einen JSON Key und kopieren Sie den Inhalt"
echo ""
echo "4. Nach dem Hinzufügen der Secrets wird das Deployment automatisch ausgelöst"
echo ""
echo "📊 Überwachen Sie das Deployment:"
echo "https://github.com/KooroshKarimi/bringee/actions"