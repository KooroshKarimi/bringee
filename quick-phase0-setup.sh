#!/bin/bash

# Quick Phase 0 Setup Script für Google Cloud
# Automatisiert das Deployment von Phase 0

set -e

echo "🚀 Quick Phase 0 Setup für Google Cloud"
echo "========================================"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktionen
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Überprüfe Requirements
check_requirements() {
    log_info "Überprüfe Requirements..."
    
    # Überprüfe gcloud
    if ! command -v gcloud &> /dev/null; then
        log_error "Google Cloud SDK ist nicht installiert."
        log_info "Installiere Google Cloud SDK..."
        
        # Installiere gcloud
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL
        gcloud auth login
    else
        log_info "✅ Google Cloud SDK ist installiert"
    fi
    
    # Überprüfe terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform ist nicht installiert."
        log_info "Installiere Terraform..."
        
        # Installiere Terraform
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform
    else
        log_info "✅ Terraform ist installiert"
    fi
    
    # Überprüfe docker
    if ! command -v docker &> /dev/null; then
        log_warn "Docker ist nicht installiert. Wird für lokale Tests benötigt."
    else
        log_info "✅ Docker ist installiert"
    fi
}

# Hole User Input
get_user_input() {
    echo ""
    log_info "Bitte gib die folgenden Informationen ein:"
    
    read -p "GCP Project ID: " GCP_PROJECT_ID
    read -p "GCP Region (default: europe-west3): " GCP_REGION
    GCP_REGION=${GCP_REGION:-europe-west3}
    
    read -p "GitHub Repository (Format: owner/repo): " GITHUB_REPO
    
    echo ""
    log_info "Konfiguration:"
    echo "  GCP Project ID: $GCP_PROJECT_ID"
    echo "  GCP Region: $GCP_REGION"
    echo "  GitHub Repo: $GITHUB_REPO"
    echo ""
    
    read -p "Ist das korrekt? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_error "Setup abgebrochen."
        exit 1
    fi
}

# Konfiguriere gcloud
setup_gcloud() {
    log_info "Konfiguriere Google Cloud..."
    
    # Setze Project
    gcloud config set project "$GCP_PROJECT_ID"
    
    # Aktiviere APIs
    gcloud services enable \
        iam.googleapis.com \
        cloudresourcemanager.googleapis.com \
        artifactregistry.googleapis.com \
        secretmanager.googleapis.com \
        run.googleapis.com \
        iamcredentials.googleapis.com \
        logging.googleapis.com \
        monitoring.googleapis.com
    
    log_info "✅ Google Cloud konfiguriert"
}

# Erstelle Terraform State Bucket
create_terraform_bucket() {
    log_info "Erstelle Terraform State Bucket..."
    
    BUCKET_NAME="bringee-terraform-state-$(date +%s)"
    
    gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$BUCKET_NAME" || {
        log_warn "Bucket-Erstellung fehlgeschlagen. Verwende manuellen Namen."
        read -p "Gib einen eindeutigen Bucket-Namen ein: " BUCKET_NAME
        gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$BUCKET_NAME"
    }
    
    log_info "✅ Terraform State Bucket erstellt: gs://$BUCKET_NAME"
    
    # Aktualisiere terraform/main.tf
    sed -i "s/bringee-terraform-state-bucket-unique/$BUCKET_NAME/" terraform/main.tf
}

# Konfiguriere Terraform
setup_terraform() {
    log_info "Konfiguriere Terraform..."
    
    # Erstelle terraform.tfvars
    cat > terraform/terraform.tfvars << EOF
gcp_project_id    = "$GCP_PROJECT_ID"
gcp_region        = "$GCP_REGION"
github_repository = "$GITHUB_REPO"
environment       = "dev"
EOF
    
    log_info "✅ Terraform konfiguriert"
}

# Deploy Infrastructure
deploy_infrastructure() {
    log_info "Deploye Infrastructure mit Terraform..."
    
    cd terraform
    
    # Initialisiere Terraform
    terraform init
    
    # Plan und Apply
    terraform plan -out=tfplan
    terraform apply tfplan
    
    # Hole Outputs
    GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email 2>/dev/null || echo "")
    USER_SERVICE_URL=$(terraform output -raw user_service_url 2>/dev/null || echo "")
    SHIPMENT_SERVICE_URL=$(terraform output -raw shipment_service_url 2>/dev/null || echo "")
    
    cd ..
    
    log_info "✅ Infrastructure deployed"
}

# Teste Services
test_services() {
    log_info "Teste Services..."
    
    if [ -n "$USER_SERVICE_URL" ]; then
        log_info "Teste User Service: $USER_SERVICE_URL"
        curl -s "$USER_SERVICE_URL/health" || log_warn "User Service antwortet nicht"
    fi
    
    if [ -n "$SHIPMENT_SERVICE_URL" ]; then
        log_info "Teste Shipment Service: $SHIPMENT_SERVICE_URL"
        curl -s "$SHIPMENT_SERVICE_URL/health" || log_warn "Shipment Service antwortet nicht"
    fi
}

# Zeige GitHub Secrets Setup
show_github_secrets() {
    echo ""
    log_info "GitHub Secrets Setup"
    echo "======================"
    echo ""
    echo "Gehe zu deinem GitHub Repository: https://github.com/$GITHUB_REPO"
    echo "Settings → Secrets and variables → Actions"
    echo ""
    echo "Füge diese Secrets hinzu:"
    echo ""
    echo "GCP_PROJECT_ID: $GCP_PROJECT_ID"
    echo "GITHUB_ACTIONS_SA_EMAIL: $GITHUB_ACTIONS_SA_EMAIL"
    echo ""
    echo "Workload Identity Provider:"
    echo "projects/$GCP_PROJECT_ID/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider"
    echo ""
    
    read -p "Drücke Enter, wenn du die Secrets hinzugefügt hast..."
}

# Teste lokale Services
test_local_services() {
    log_info "Teste lokale Services..."
    
    # Teste User Service
    cd backend/services/user-service
    go test -v ./... || log_warn "User Service Tests fehlgeschlagen"
    cd ../../..
    
    # Teste Shipment Service
    cd backend/services/shipment-service
    go test -v ./... || log_warn "Shipment Service Tests fehlgeschlagen"
    cd ../../..
    
    log_info "✅ Lokale Tests abgeschlossen"
}

# Main Execution
main() {
    check_requirements
    get_user_input
    setup_gcloud
    create_terraform_bucket
    setup_terraform
    deploy_infrastructure
    test_local_services
    test_services
    show_github_secrets
    
    echo ""
    log_info "🎉 Phase 0 Setup abgeschlossen!"
    echo "================================"
    echo ""
    echo "Deine CI/CD Pipeline ist jetzt konfiguriert:"
    echo "• Push zum main Branch triggert automatisches Deployment"
    echo "• Docker Images werden automatisch gebaut und gepusht"
    echo "• Services werden automatisch auf Cloud Run deployed"
    echo ""
    echo "Service URLs:"
    [ -n "$USER_SERVICE_URL" ] && echo "• User Service: $USER_SERVICE_URL"
    [ -n "$SHIPMENT_SERVICE_URL" ] && echo "• Shipment Service: $SHIPMENT_SERVICE_URL"
    echo ""
    echo "Nächste Schritte:"
    echo "1. Stelle sicher, dass deine GitHub Secrets konfiguriert sind"
    echo "2. Push einen Commit zum main Branch um die Pipeline zu testen"
    echo "3. Überwache das Deployment in GitHub Actions"
    echo ""
    echo "Teste die Pipeline mit:"
    echo "git add . && git commit -m 'Test Phase 0' && git push origin main"
}

# Führe das Skript aus
main "$@"