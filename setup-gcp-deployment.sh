#!/bin/bash

# Bringee GCP Deployment Setup Script
# Enhanced version with better error handling, validation, and security

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🚀 Setting up Bringee GCP Deployment Pipeline"
echo "=============================================="

# Check if required tools are installed
check_requirements() {
    log_info "Checking requirements..."
    
    local missing_tools=()
    
    if ! command -v gcloud &> /dev/null; then
        missing_tools+=("Google Cloud SDK")
    fi
    
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("Terraform")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("Docker")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools:"
        echo "  Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
        echo "  Terraform: https://developer.hashicorp.com/terraform/downloads"
        echo "  Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    log_success "All requirements met"
}

# Validate GCP authentication
validate_gcp_auth() {
    log_info "Validating GCP authentication..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_error "Not authenticated with Google Cloud. Please run:"
        echo "  gcloud auth login"
        echo "  gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    
    log_success "GCP authentication validated"
}

# Get user input with validation
get_user_input() {
    echo ""
    log_info "Please provide the following information:"
    
    # Get GCP Project ID
    while true; do
        read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
        if [ -n "$GCP_PROJECT_ID" ]; then
            # Validate project exists
            if gcloud projects describe "$GCP_PROJECT_ID" &>/dev/null; then
                break
            else
                log_error "Project '$GCP_PROJECT_ID' not found or not accessible"
            fi
        fi
    done
    
    # Get GCP Region
    read -p "Enter your GCP Region (default: us-central1): " GCP_REGION
    GCP_REGION=${GCP_REGION:-us-central1}
    
    # Validate region
    if ! gcloud compute regions list --filter="name=$GCP_REGION" --format="value(name)" | grep -q "$GCP_REGION"; then
        log_error "Region '$GCP_REGION' is not valid"
        exit 1
    fi
    
    # Get GitHub repository
    while true; do
        read -p "Enter your GitHub repository (format: owner/repo): " GITHUB_REPO
        if [[ $GITHUB_REPO =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
            break
        else
            log_error "Invalid repository format. Use format: owner/repo"
        fi
    done
    
    # Get environment
    read -p "Enter deployment environment (staging/production, default: staging): " DEPLOYMENT_ENV
    DEPLOYMENT_ENV=${DEPLOYMENT_ENV:-staging}
    
    echo ""
    log_info "Configuration Summary:"
    echo "  GCP Project ID: $GCP_PROJECT_ID"
    echo "  GCP Region: $GCP_REGION"
    echo "  GitHub Repo: $GITHUB_REPO"
    echo "  Environment: $DEPLOYMENT_ENV"
    echo ""
    
    read -p "Is this correct? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_warning "Setup cancelled."
        exit 1
    fi
}

# Create Terraform state bucket with unique name
create_terraform_bucket() {
    log_info "Creating Terraform state bucket..."
    
    # Generate unique bucket name
    BUCKET_NAME="bringee-terraform-state-$(date +%s)-$(openssl rand -hex 4)"
    
    if gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$BUCKET_NAME" 2>/dev/null; then
        log_success "Terraform state bucket created: gs://$BUCKET_NAME"
        
        # Update terraform/main.tf with the bucket name
        sed -i "s/bringee-terraform-state-bucket-unique/$BUCKET_NAME/" terraform/main.tf
    else
        log_error "Failed to create bucket. Please create it manually:"
        echo "  gsutil mb -p $GCP_PROJECT_ID -c STANDARD -l $GCP_REGION gs://$BUCKET_NAME"
        exit 1
    fi
}

# Enable required GCP APIs
enable_gcp_apis() {
    log_info "Enabling required GCP APIs..."
    
    local apis=(
        "iam.googleapis.com"
        "cloudresourcemanager.googleapis.com"
        "artifactregistry.googleapis.com"
        "secretmanager.googleapis.com"
        "run.googleapis.com"
        "iamcredentials.googleapis.com"
        "logging.googleapis.com"
        "monitoring.googleapis.com"
        "cloudbuild.googleapis.com"
        "containerregistry.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        if gcloud services enable "$api" --project="$GCP_PROJECT_ID" --quiet; then
            log_success "Enabled $api"
        else
            log_warning "Failed to enable $api (may already be enabled)"
        fi
    done
}

# Initialize and apply Terraform
deploy_infrastructure() {
    log_info "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Create terraform.tfvars
    cat > terraform.tfvars << EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "$GITHUB_REPO"
EOF
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Plan Terraform changes
    log_info "Planning Terraform changes..."
    terraform plan -out=tfplan
    
    # Apply Terraform changes
    log_info "Applying Terraform changes..."
    terraform apply tfplan
    
    # Get outputs
    GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email 2>/dev/null || echo "")
    CLOUD_RUN_SA_EMAIL=$(terraform output -raw cloud_run_sa_email 2>/dev/null || echo "")
    WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw workload_identity_provider 2>/dev/null || echo "")
    USER_SERVICE_URL=$(terraform output -raw user_service_url 2>/dev/null || echo "")
    SHIPMENT_SERVICE_URL=$(terraform output -raw shipment_service_url 2>/dev/null || echo "")
    
    cd ..
    
    log_success "Infrastructure deployed successfully"
}

# Setup GitHub secrets
setup_github_secrets() {
    echo ""
    log_info "GitHub Secrets Setup"
    echo "======================"
    echo ""
    
    # Check if GitHub CLI is available
    if command -v gh &> /dev/null; then
        log_info "GitHub CLI detected. Attempting to set secrets automatically..."
        
        # Check if user is authenticated with GitHub CLI
        if gh auth status &>/dev/null; then
            # Set secrets using GitHub CLI
            echo "$GCP_PROJECT_ID" | gh secret set GCP_PROJECT_ID --repo "$GITHUB_REPO" --body-file -
            echo "$GITHUB_ACTIONS_SA_EMAIL" | gh secret set GITHUB_ACTIONS_SA_EMAIL --repo "$GITHUB_REPO" --body-file -
            echo "$WORKLOAD_IDENTITY_PROVIDER" | gh secret set WORKLOAD_IDENTITY_PROVIDER --repo "$GITHUB_REPO" --body-file -
            
            log_success "GitHub secrets set automatically using GitHub CLI"
        else
            log_warning "GitHub CLI not authenticated. Please run: gh auth login"
            show_manual_secrets_instructions
        fi
    else
        show_manual_secrets_instructions
    fi
}

# Show manual secrets setup instructions
show_manual_secrets_instructions() {
    log_info "Please set GitHub secrets manually:"
    echo ""
    echo "1. Go to your GitHub repository: https://github.com/$GITHUB_REPO"
    echo "2. Go to Settings > Secrets and variables > Actions"
    echo "3. Add the following secrets:"
    echo ""
    echo "   GCP_PROJECT_ID: $GCP_PROJECT_ID"
    echo "   GITHUB_ACTIONS_SA_EMAIL: $GITHUB_ACTIONS_SA_EMAIL"
    echo "   WORKLOAD_IDENTITY_PROVIDER: $WORKLOAD_IDENTITY_PROVIDER"
    echo ""
    echo "4. For Firebase deployment (optional):"
    echo "   FIREBASE_PROJECT_ID: [Your Firebase Project ID]"
    echo "   FIREBASE_SERVICE_ACCOUNT: [Your Firebase Service Account JSON]"
    echo ""
    
    read -p "Press Enter when you've added the secrets..."
}

# Test the deployment
test_deployment() {
    log_info "Testing deployment..."
    
    local test_results=()
    
    if [ -n "$USER_SERVICE_URL" ]; then
        log_info "Testing User Service: $USER_SERVICE_URL"
        if curl -s -f "$USER_SERVICE_URL/health" >/dev/null; then
            log_success "User service is responding"
            test_results+=("✅ User Service: OK")
        else
            log_warning "User service not responding"
            test_results+=("⚠️  User Service: Not responding")
        fi
    fi
    
    if [ -n "$SHIPMENT_SERVICE_URL" ]; then
        log_info "Testing Shipment Service: $SHIPMENT_SERVICE_URL"
        if curl -s -f "$SHIPMENT_SERVICE_URL/health" >/dev/null; then
            log_success "Shipment service is responding"
            test_results+=("✅ Shipment Service: OK")
        else
            log_warning "Shipment service not responding"
            test_results+=("⚠️  Shipment Service: Not responding")
        fi
    fi
    
    echo ""
    log_info "Test Results:"
    for result in "${test_results[@]}"; do
        echo "  $result"
    done
}

# Create deployment documentation
create_documentation() {
    log_info "Creating deployment documentation..."
    
    cat > DEPLOYMENT_STATUS.md << EOF
# Bringee Deployment Status

## Configuration
- **GCP Project ID:** $GCP_PROJECT_ID
- **GCP Region:** $GCP_REGION
- **GitHub Repository:** $GITHUB_REPO
- **Environment:** $DEPLOYMENT_ENV
- **Deployment Date:** $(date)

## Service URLs
$(if [ -n "$USER_SERVICE_URL" ]; then echo "- **User Service:** $USER_SERVICE_URL"; fi)
$(if [ -n "$SHIPMENT_SERVICE_URL" ]; then echo "- **Shipment Service:** $SHIPMENT_SERVICE_URL"; fi)

## GitHub Secrets Required
- \`GCP_PROJECT_ID\`: $GCP_PROJECT_ID
- \`GITHUB_ACTIONS_SA_EMAIL\`: $GITHUB_ACTIONS_SA_EMAIL
- \`WORKLOAD_IDENTITY_PROVIDER\`: $WORKLOAD_IDENTITY_PROVIDER

## Next Steps
1. Push a commit to the main branch to trigger the first deployment
2. Monitor the deployment in GitHub Actions
3. Check service health endpoints
4. Set up monitoring and alerting

## Troubleshooting
- Check GitHub Actions logs for deployment issues
- Verify GCP service account permissions
- Ensure all required APIs are enabled
EOF
    
    log_success "Documentation created: DEPLOYMENT_STATUS.md"
}

# Main execution
main() {
    check_requirements
    validate_gcp_auth
    get_user_input
    create_terraform_bucket
    enable_gcp_apis
    deploy_infrastructure
    setup_github_secrets
    test_deployment
    create_documentation
    
    echo ""
    log_success "Setup complete!"
    echo "================"
    echo ""
    log_info "Your CI/CD pipeline is now configured:"
    echo "• Push to main/develop branches will trigger automatic deployment"
    echo "• Docker images will be built and pushed to Artifact Registry"
    echo "• Services will be automatically deployed to Cloud Run"
    echo "• Security scanning and vulnerability checks are enabled"
    echo "• Health checks and monitoring are configured"
    echo ""
    
    if [ -n "$USER_SERVICE_URL" ]; then
        echo "• User Service: $USER_SERVICE_URL"
    fi
    if [ -n "$SHIPMENT_SERVICE_URL" ]; then
        echo "• Shipment Service: $SHIPMENT_SERVICE_URL"
    fi
    
    echo ""
    log_info "Next steps:"
    echo "1. Make sure your GitHub secrets are configured"
    echo "2. Push a commit to the main branch to test the pipeline"
    echo "3. Monitor the deployment in GitHub Actions"
    echo "4. Check the DEPLOYMENT_STATUS.md file for details"
    echo ""
    log_info "Happy deploying! 🚀"
}

# Run the script
main "$@"