#!/bin/bash

# Quick Phase 0 Deployment Script
# Deploys Phase 0 to Google Cloud using GitHub Actions

set -e

echo "🚀 Quick Phase 0 Deployment - Bringee"
echo "======================================"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Überprüfe Git Repository
check_git_repo() {
    echo "📋 Überprüfe Git Repository..."
    
    if [ ! -d ".git" ]; then
        print_error "Kein Git Repository gefunden"
        exit 1
    fi
    
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -z "$REMOTE_URL" ]; then
        print_error "Kein GitHub Remote konfiguriert"
        echo "Führen Sie aus: git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
        exit 1
    fi
    
    print_success "Git Repository konfiguriert: $REMOTE_URL"
}

# Überprüfe Phase 0 Komponenten
check_phase0_components() {
    echo ""
    echo "🔧 Überprüfe Phase 0 Komponenten..."
    
    # Überprüfe Backend Services
    if [ -f "backend/services/user-service/main.go" ] && [ -f "backend/services/shipment-service/main.go" ]; then
        print_success "Backend Services vorhanden"
    else
        print_error "Backend Services fehlen"
        exit 1
    fi
    
    # Überprüfe Terraform
    if [ -f "terraform/main.tf" ] && [ -f "terraform/cloud-run.tf" ]; then
        print_success "Terraform Konfiguration vorhanden"
    else
        print_error "Terraform Konfiguration fehlt"
        exit 1
    fi
    
    # Überprüfe GitHub Actions
    if [ -f ".github/workflows/ci-cd.yml" ]; then
        print_success "GitHub Actions Workflow vorhanden"
    else
        print_error "GitHub Actions Workflow fehlt"
        exit 1
    fi
}

# Erstelle GitHub Secrets Anleitung
create_github_secrets_guide() {
    echo ""
    echo "🔐 GitHub Secrets Setup"
    echo "======================"
    echo ""
    
    # Extrahiere Repository Name
    REPO_NAME=$(basename -s .git $(git config --get remote.origin.url))
    REPO_OWNER=$(git config --get remote.origin.url | sed -n 's/.*github.com[:/]\([^/]*\)\/.*/\1/p')
    
    print_info "Repository: $REPO_OWNER/$REPO_NAME"
    echo ""
    echo "1. Gehen Sie zu: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
    echo ""
    echo "2. Fügen Sie folgende Secrets hinzu:"
    echo ""
    echo "   GCP_PROJECT_ID:"
    echo "   - Name: GCP_PROJECT_ID"
    echo "   - Value: Ihre GCP Project ID (z.B. bringee-project-123456)"
    echo ""
    echo "   GITHUB_ACTIONS_SA_EMAIL:"
    echo "   - Name: GITHUB_ACTIONS_SA_EMAIL"
    echo "   - Value: Wird nach dem ersten Terraform Run erstellt"
    echo ""
    echo "3. Für Workload Identity Provider:"
    echo "   - projects/YOUR_PROJECT_ID/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider"
    echo ""
    
    read -p "Drücken Sie Enter, wenn Sie die Secrets hinzugefügt haben..."
}

# Erstelle manuelles Deployment Skript
create_manual_deployment_script() {
    echo ""
    echo "🔨 Erstelle manuelles Deployment Skript..."
    
    cat > manual-deploy.sh << 'EOF'
#!/bin/bash

# Manuelles Deployment Skript für Phase 0
# Führen Sie dieses Skript aus, wenn GitHub Actions nicht funktioniert

set -e

echo "🚀 Manuelles Phase 0 Deployment"
echo "================================"

# Konfiguration
GCP_PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
GCP_REGION=${GCP_REGION:-"europe-west3"}

echo "Konfiguration:"
echo "  GCP Project ID: $GCP_PROJECT_ID"
echo "  GCP Region: $GCP_REGION"
echo ""

# Überprüfe gcloud
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI ist nicht installiert"
    echo "Installieren Sie es: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Authentifizierung
echo "🔐 Authentifizierung..."
gcloud auth login
gcloud config set project "$GCP_PROJECT_ID"

# Terraform Deployment
echo "🏗️  Terraform Deployment..."
cd terraform

# Erstelle terraform.tfvars
cat > terraform.tfvars << TFEOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git/\1\/\2/')"
TFEOF

terraform init
terraform plan -out=tfplan
terraform apply tfplan

cd ..

# Docker Build und Push
echo "🐳 Docker Build und Push..."

# User Service
cd backend/services/user-service
docker build -t europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest .
docker push europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest
cd ../../..

# Shipment Service
cd backend/services/shipment-service
docker build -t europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest .
docker push europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest
cd ../../..

# Cloud Run Deployment
echo "☁️  Cloud Run Deployment..."

gcloud run deploy user-service \
    --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest \
    --region $GCP_REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080

gcloud run deploy shipment-service \
    --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest \
    --region $GCP_REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080

echo ""
echo "🎉 Deployment abgeschlossen!"
echo "============================"
echo ""
echo "Service URLs:"
gcloud run services describe user-service --region=$GCP_REGION --format="value(status.url)"
gcloud run services describe shipment-service --region=$GCP_REGION --format="value(status.url)"
EOF

    chmod +x manual-deploy.sh
    print_success "Manuelles Deployment Skript erstellt: manual-deploy.sh"
}

# Erstelle Test Commit
create_test_commit() {
    echo ""
    echo "📝 Erstelle Test Commit..."
    
    # Erstelle eine kleine Änderung
    echo "# Phase 0 Test - $(date)" >> test-phase0.md
    
    git add test-phase0.md
    git commit -m "test: Phase 0 deployment test"
    
    print_success "Test Commit erstellt"
}

# Push zum main Branch
push_to_main() {
    echo ""
    echo "🚀 Push zum main Branch..."
    
    CURRENT_BRANCH=$(git branch --show-current)
    
    if [ "$CURRENT_BRANCH" != "main" ]; then
        print_warning "Aktueller Branch ist nicht 'main': $CURRENT_BRANCH"
        read -p "Möchten Sie zu main wechseln? (y/N): " switch_branch
        
        if [[ $switch_branch =~ ^[Yy]$ ]]; then
            git checkout main
        else
            print_info "Push wird auf Branch '$CURRENT_BRANCH' durchgeführt"
        fi
    fi
    
    git push origin HEAD
    
    print_success "Code gepusht - GitHub Actions werden ausgelöst"
}

# Zeige nächste Schritte
show_next_steps() {
    echo ""
    echo "🎯 Nächste Schritte"
    echo "==================="
    echo ""
    echo "1. 📊 Überwachen Sie die GitHub Actions:"
    echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git/\1\/\2/')/actions"
    echo ""
    echo "2. 🔍 Überprüfen Sie die Deployment Logs"
    echo ""
    echo "3. 🧪 Testen Sie die Services nach dem Deployment:"
    echo "   - User Service: wird nach Deployment angezeigt"
    echo "   - Shipment Service: wird nach Deployment angezeigt"
    echo ""
    echo "4. 🔧 Falls GitHub Actions fehlschlagen:"
    echo "   - Überprüfen Sie die GitHub Secrets"
    echo "   - Führen Sie manual-deploy.sh aus"
    echo ""
    echo "5. 📚 Dokumentation:"
    echo "   - PHASE_0_STATUS.md - Detaillierter Status"
    echo "   - GITHUB_SECRETS_SETUP.md - GitHub Secrets"
    echo "   - TROUBLESHOOTING.md - Fehlerbehebung"
}

# Hauptfunktion
main() {
    check_git_repo
    check_phase0_components
    create_github_secrets_guide
    create_manual_deployment_script
    create_test_commit
    push_to_main
    show_next_steps
}

# Skript ausführen
main "$@"