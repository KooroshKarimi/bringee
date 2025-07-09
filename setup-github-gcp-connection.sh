#!/bin/bash

# Bringee GitHub-GCP Connection Setup Script
# This script ensures the connection between GitHub and Google Cloud Platform for automatic deployment

set -e

echo "🔗 Setting up GitHub-GCP Connection for Automatic Deployment"
echo "==========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Check if required tools are installed
check_requirements() {
    print_status "info" "Checking requirements..."
    
    local missing_tools=()
    
    if ! command -v gcloud &> /dev/null; then
        missing_tools+=("Google Cloud SDK")
    fi
    
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("Terraform")
    fi
    
    if ! command -v gh &> /dev/null; then
        print_status "warning" "GitHub CLI not found (optional but recommended)"
        echo "   Install with: https://cli.github.com/"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_status "error" "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "   - $tool"
        done
        echo ""
        echo "Please install missing tools:"
        echo "  Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
        echo "  Terraform: https://developer.hashicorp.com/terraform/downloads"
        exit 1
    fi
    
    print_status "success" "All required tools are installed"
}

# Get user input
get_user_input() {
    echo ""
    print_status "info" "Please provide the following information:"
    
    # Get GCP Project ID
    local current_project=$(gcloud config get-value project 2>/dev/null)
    if [ -n "$current_project" ]; then
        read -p "Enter your GCP Project ID (current: $current_project): " GCP_PROJECT_ID
        GCP_PROJECT_ID=${GCP_PROJECT_ID:-$current_project}
    else
        read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
    fi
    
    # Get GCP Region
    read -p "Enter your GCP Region (default: europe-west3): " GCP_REGION
GCP_REGION=${GCP_REGION:-europe-west3}
    
    # Get GitHub repository
    local repo_url=$(git remote get-url origin 2>/dev/null)
    if [ -n "$repo_url" ]; then
        local repo_name=$(echo $repo_url | sed 's|https://github.com/||' | sed 's|git@github.com:||' | sed 's|\.git$||')
        read -p "Enter your GitHub repository (current: $repo_name): " GITHUB_REPO
        GITHUB_REPO=${GITHUB_REPO:-$repo_name}
    else
        read -p "Enter your GitHub repository (format: owner/repo): " GITHUB_REPO
    fi
    
    echo ""
    print_status "info" "Configuration:"
    echo "  GCP Project ID: $GCP_PROJECT_ID"
    echo "  GCP Region: $GCP_REGION"
    echo "  GitHub Repo: $GITHUB_REPO"
    echo ""
    
    read -p "Is this correct? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_status "error" "Setup cancelled."
        exit 1
    fi
}

# Authenticate with GCP
authenticate_gcp() {
    print_status "info" "Authenticating with Google Cloud..."
    
    # Check if already authenticated
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_status "success" "Already authenticated with Google Cloud"
    else
        print_status "info" "Please authenticate with Google Cloud..."
        gcloud auth login
    fi
    
    # Set the project
    gcloud config set project "$GCP_PROJECT_ID"
    print_status "success" "GCP project set to: $GCP_PROJECT_ID"
}

# Enable required APIs
enable_apis() {
    print_status "info" "Enabling required Google Cloud APIs..."
    
    local required_apis=(
        "iam.googleapis.com"
        "cloudresourcemanager.googleapis.com"
        "artifactregistry.googleapis.com"
        "run.googleapis.com"
        "iamcredentials.googleapis.com"
        "logging.googleapis.com"
        "monitoring.googleapis.com"
    )
    
    for api in "${required_apis[@]}"; do
        if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
            print_status "success" "API already enabled: $api"
        else
            print_status "info" "Enabling API: $api"
            gcloud services enable "$api"
            print_status "success" "API enabled: $api"
        fi
    done
}

# Create Terraform state bucket
create_terraform_bucket() {
    print_status "info" "Creating Terraform state bucket..."
    
    local bucket_name="bringee-terraform-state-$(date +%s)"
    
    if gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$bucket_name" 2>/dev/null; then
        print_status "success" "Terraform state bucket created: gs://$bucket_name"
        
        # Update terraform/main.tf with the bucket name
        if [ -f "terraform/main.tf" ]; then
            sed -i "s/bringee-terraform-state-bucket-unique/$bucket_name/" terraform/main.tf
            print_status "success" "Updated terraform/main.tf with bucket name"
        fi
    else
        print_status "warning" "Bucket creation failed. You may need to create it manually."
        read -p "Enter a unique bucket name for Terraform state: " bucket_name
        gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$bucket_name"
        print_status "success" "Terraform state bucket created: gs://$bucket_name"
        
        # Update terraform/main.tf with the bucket name
        if [ -f "terraform/main.tf" ]; then
            sed -i "s/bringee-terraform-state-bucket-unique/$bucket_name/" terraform/main.tf
            print_status "success" "Updated terraform/main.tf with bucket name"
        fi
    fi
}

# Initialize and apply Terraform
deploy_infrastructure() {
    print_status "info" "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Create terraform.tfvars
    cat > terraform.tfvars << EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "$GITHUB_REPO"
EOF
    
    print_status "success" "Created terraform.tfvars"
    
    # Initialize Terraform
    print_status "info" "Initializing Terraform..."
    terraform init
    
    # Plan and apply
    print_status "info" "Planning Terraform changes..."
    terraform plan -out=tfplan
    
    print_status "info" "Applying Terraform changes..."
    terraform apply tfplan
    
    # Get outputs
    GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email 2>/dev/null || echo "")
    USER_SERVICE_URL=$(terraform output -raw user_service_url 2>/dev/null || echo "")
    SHIPMENT_SERVICE_URL=$(terraform output -raw shipment_service_url 2>/dev/null || echo "")
    
    cd ..
    
    print_status "success" "Infrastructure deployed successfully"
}

# Setup GitHub secrets
setup_github_secrets() {
    print_status "info" "Setting up GitHub Secrets..."
    
    # Check if GitHub CLI is available
    if command -v gh &> /dev/null; then
        print_status "info" "GitHub CLI detected. Attempting to set secrets automatically..."
        
        # Check if authenticated with GitHub CLI
        if gh auth status &> /dev/null; then
            # Set secrets using GitHub CLI
            echo "$GCP_PROJECT_ID" | gh secret set GCP_PROJECT_ID --repo "$GITHUB_REPO"
            echo "$GITHUB_ACTIONS_SA_EMAIL" | gh secret set GITHUB_ACTIONS_SA_EMAIL --repo "$GITHUB_REPO"
            
            print_status "success" "GitHub secrets set automatically using GitHub CLI"
        else
            print_status "warning" "GitHub CLI not authenticated"
            echo "Please run: gh auth login"
            manual_secret_setup
        fi
    else
        manual_secret_setup
    fi
}

# Manual secret setup instructions
manual_secret_setup() {
    print_status "info" "Please set GitHub secrets manually:"
    echo ""
    echo "1. Go to your GitHub repository: https://github.com/$GITHUB_REPO"
    echo "2. Go to Settings > Secrets and variables > Actions"
    echo "3. Add the following secrets:"
    echo ""
    echo "   GCP_PROJECT_ID: $GCP_PROJECT_ID"
    echo "   GITHUB_ACTIONS_SA_EMAIL: $GITHUB_ACTIONS_SA_EMAIL"
    echo ""
    echo "4. For the Workload Identity Provider, use:"
    echo "   projects/$GCP_PROJECT_ID/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider"
    echo ""
    
    read -p "Press Enter when you've added the secrets..."
}

# Test the connection
test_connection() {
    print_status "info" "Testing the GitHub-GCP connection..."
    
    # Test Workload Identity
    if gcloud iam workload-identity-pools list --location=global --project="$GCP_PROJECT_ID" | grep -q "github-actions-pool"; then
        print_status "success" "Workload Identity Pool exists"
    else
        print_status "error" "Workload Identity Pool not found"
    fi
    
    # Test Artifact Registry
    if gcloud artifacts repositories list --location="$GCP_REGION" --project="$GCP_PROJECT_ID" | grep -q "bringee-artifacts"; then
        print_status "success" "Artifact Registry repository exists"
    else
        print_status "error" "Artifact Registry repository not found"
    fi
    
    # Test Cloud Run services
    if gcloud run services list --region="$GCP_REGION" | grep -q "user-service"; then
        print_status "success" "Cloud Run user-service exists"
    else
        print_status "warning" "Cloud Run user-service not found (will be created on first deployment)"
    fi
    
    if gcloud run services list --region="$GCP_REGION" | grep -q "shipment-service"; then
        print_status "success" "Cloud Run shipment-service exists"
    else
        print_status "warning" "Cloud Run shipment-service not found (will be created on first deployment)"
    fi
}

# Test automatic deployment
test_automatic_deployment() {
    print_status "info" "Testing automatic deployment capability..."
    
    # Check if the workflow is properly configured
    if [ -f ".github/workflows/ci-cd.yml" ]; then
        if grep -q "workload_identity_provider" .github/workflows/ci-cd.yml; then
            print_status "success" "Workload Identity Federation configured in workflow"
        else
            print_status "error" "Workload Identity Federation not configured in workflow"
        fi
        
        if grep -q "GCP_PROJECT_ID" .github/workflows/ci-cd.yml; then
            print_status "success" "GCP Project ID configured in workflow"
        else
            print_status "error" "GCP Project ID not configured in workflow"
        fi
        
        if grep -q "deploy-to-cloud-run" .github/workflows/ci-cd.yml; then
            print_status "success" "Cloud Run deployment job configured"
        else
            print_status "error" "Cloud Run deployment job not configured"
        fi
    else
        print_status "error" "CI/CD workflow not found"
    fi
}

# Provide next steps
provide_next_steps() {
    echo ""
    print_status "success" "Setup complete!"
    echo ""
    echo "🎉 Your GitHub-GCP connection is now configured for automatic deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Push a commit to the main branch to trigger deployment:"
    echo "   git add ."
    echo "   git commit -m 'Setup automatic deployment'"
    echo "   git push origin main"
    echo ""
    echo "2. Monitor the deployment:"
    echo "   - GitHub Actions: https://github.com/$GITHUB_REPO/actions"
    echo "   - Cloud Run: https://console.cloud.google.com/run"
    echo ""
    echo "3. Test your services:"
    if [ -n "$USER_SERVICE_URL" ]; then
        echo "   - User Service: $USER_SERVICE_URL"
    fi
    if [ -n "$SHIPMENT_SERVICE_URL" ]; then
        echo "   - Shipment Service: $SHIPMENT_SERVICE_URL"
    fi
    echo ""
    echo "4. Verify the connection:"
    echo "   ./verify-github-gcp-connection.sh"
    echo ""
}

# Main execution
main() {
    check_requirements
    get_user_input
    authenticate_gcp
    enable_apis
    create_terraform_bucket
    deploy_infrastructure
    setup_github_secrets
    test_connection
    test_automatic_deployment
    provide_next_steps
}

# Run the script
main "$@"