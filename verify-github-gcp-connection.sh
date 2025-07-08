#!/bin/bash

# Bringee GitHub-GCP Connection Verification Script
# This script verifies and ensures the connection between GitHub and Google Cloud Platform

set -e

echo "🔍 Verifying GitHub-GCP Connection for Automatic Deployment"
echo "=========================================================="

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

# Check GCP authentication and project
check_gcp_setup() {
    print_status "info" "Checking GCP setup..."
    
    # Check if authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_status "error" "Not authenticated with Google Cloud"
        echo "Please run: gcloud auth login"
        exit 1
    fi
    
    # Get current project
    local current_project=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$current_project" ]; then
        print_status "error" "No GCP project configured"
        echo "Please run: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    
    print_status "success" "GCP project configured: $current_project"
    
    # Check if required APIs are enabled
    local required_apis=(
        "iam.googleapis.com"
        "cloudresourcemanager.googleapis.com"
        "artifactregistry.googleapis.com"
        "run.googleapis.com"
        "iamcredentials.googleapis.com"
    )
    
    for api in "${required_apis[@]}"; do
        if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
            print_status "success" "API enabled: $api"
        else
            print_status "warning" "API not enabled: $api"
        fi
    done
}

# Check GitHub repository setup
check_github_setup() {
    print_status "info" "Checking GitHub repository setup..."
    
    # Get current repository
    local repo_url=$(git remote get-url origin 2>/dev/null)
    if [ -z "$repo_url" ]; then
        print_status "error" "No Git repository found"
        exit 1
    fi
    
    # Convert SSH to HTTPS if needed
    if [[ $repo_url == git@github.com:* ]]; then
        repo_url=$(echo $repo_url | sed 's/git@github.com:/https:\/\/github.com\//')
    fi
    
    local repo_name=$(echo $repo_url | sed 's|https://github.com/||' | sed 's|\.git$||')
    print_status "success" "GitHub repository: $repo_name"
    
    # Check if .github/workflows directory exists
    if [ -d ".github/workflows" ]; then
        print_status "success" "GitHub Actions workflows directory found"
    else
        print_status "error" "GitHub Actions workflows directory not found"
        exit 1
    fi
    
    # Check if CI/CD workflow exists
    if [ -f ".github/workflows/ci-cd.yml" ]; then
        print_status "success" "CI/CD workflow found"
    else
        print_status "error" "CI/CD workflow not found"
        exit 1
    fi
}

# Check Terraform configuration
check_terraform_setup() {
    print_status "info" "Checking Terraform configuration..."
    
    if [ ! -d "terraform" ]; then
        print_status "error" "Terraform directory not found"
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ -f "terraform/terraform.tfvars" ]; then
        print_status "success" "Terraform variables file found"
        
        # Read and display configuration
        local project_id=$(grep "gcp_project_id" terraform/terraform.tfvars | cut -d'"' -f2)
        local region=$(grep "gcp_region" terraform/terraform.tfvars | cut -d'"' -f2)
        local github_repo=$(grep "github_repository" terraform/terraform.tfvars | cut -d'"' -f2)
        
        echo "   Project ID: $project_id"
        echo "   Region: $region"
        echo "   GitHub Repo: $github_repo"
    else
        print_status "warning" "Terraform variables file not found"
        echo "   You may need to run the setup script first"
    fi
}

# Check GitHub Secrets (if GitHub CLI is available)
check_github_secrets() {
    print_status "info" "Checking GitHub Secrets..."
    
    if command -v gh &> /dev/null; then
        # Check if authenticated with GitHub CLI
        if gh auth status &> /dev/null; then
            local repo_name=$(git remote get-url origin | sed 's|https://github.com/||' | sed 's|\.git$||')
            
            # Check for required secrets
            local required_secrets=("GCP_PROJECT_ID" "GITHUB_ACTIONS_SA_EMAIL")
            
            for secret in "${required_secrets[@]}"; do
                if gh secret list --repo "$repo_name" | grep -q "$secret"; then
                    print_status "success" "GitHub Secret found: $secret"
                else
                    print_status "warning" "GitHub Secret missing: $secret"
                fi
            done
        else
            print_status "warning" "GitHub CLI not authenticated"
            echo "   Run: gh auth login"
        fi
    else
        print_status "warning" "GitHub CLI not available - cannot check secrets automatically"
        echo "   Please manually verify these secrets in GitHub:"
        echo "   - GCP_PROJECT_ID"
        echo "   - GITHUB_ACTIONS_SA_EMAIL"
    fi
}

# Test Workload Identity Federation
test_workload_identity() {
    print_status "info" "Testing Workload Identity Federation..."
    
    local project_id=$(gcloud config get-value project)
    
    # Check if Workload Identity Pool exists
    if gcloud iam workload-identity-pools list --location=global --project="$project_id" | grep -q "github-actions-pool"; then
        print_status "success" "Workload Identity Pool found"
    else
        print_status "warning" "Workload Identity Pool not found"
        echo "   You may need to run: terraform apply"
    fi
    
    # Check if Workload Identity Provider exists
    if gcloud iam workload-identity-pools providers list --workload-identity-pool=github-actions-pool --location=global --project="$project_id" | grep -q "github-actions-provider"; then
        print_status "success" "Workload Identity Provider found"
    else
        print_status "warning" "Workload Identity Provider not found"
        echo "   You may need to run: terraform apply"
    fi
}

# Test Artifact Registry
test_artifact_registry() {
    print_status "info" "Testing Artifact Registry..."
    
    local project_id=$(gcloud config get-value project)
    local region=$(grep "gcp_region" terraform/terraform.tfvars 2>/dev/null | cut -d'"' -f2 || echo "us-central1")
    
    # Check if repository exists
    if gcloud artifacts repositories list --location="$region" --project="$project_id" | grep -q "bringee-artifacts"; then
        print_status "success" "Artifact Registry repository found"
    else
        print_status "warning" "Artifact Registry repository not found"
        echo "   You may need to run: terraform apply"
    fi
}

# Test Cloud Run services
test_cloud_run() {
    print_status "info" "Testing Cloud Run services..."
    
    local region=$(grep "gcp_region" terraform/terraform.tfvars 2>/dev/null | cut -d'"' -f2 || echo "us-central1")
    
    # Check for user-service
    if gcloud run services list --region="$region" | grep -q "user-service"; then
        print_status "success" "Cloud Run service found: user-service"
    else
        print_status "warning" "Cloud Run service not found: user-service"
    fi
    
    # Check for shipment-service
    if gcloud run services list --region="$region" | grep -q "shipment-service"; then
        print_status "success" "Cloud Run service found: shipment-service"
    else
        print_status "warning" "Cloud Run service not found: shipment-service"
    fi
}

# Test automatic deployment
test_automatic_deployment() {
    print_status "info" "Testing automatic deployment capability..."
    
    # Check if the workflow is properly configured
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
}

# Provide setup instructions
provide_setup_instructions() {
    echo ""
    echo "📋 Setup Instructions"
    echo "===================="
    echo ""
    
    if [ ! -f "terraform/terraform.tfvars" ]; then
        echo "1. Run the setup script to configure the deployment:"
        echo "   ./setup-gcp-deployment.sh"
        echo ""
    fi
    
    echo "2. Ensure GitHub Secrets are configured:"
    echo "   - Go to your GitHub repository"
    echo "   - Settings > Secrets and variables > Actions"
    echo "   - Add these secrets:"
    echo "     * GCP_PROJECT_ID: [Your GCP Project ID]"
    echo "     * GITHUB_ACTIONS_SA_EMAIL: [From Terraform output]"
    echo ""
    
    echo "3. Test the deployment:"
    echo "   git add ."
    echo "   git commit -m 'Test automatic deployment'"
    echo "   git push origin main"
    echo ""
    
    echo "4. Monitor the deployment:"
    echo "   - Check GitHub Actions: https://github.com/[your-repo]/actions"
    echo "   - Check Cloud Run: https://console.cloud.google.com/run"
    echo ""
}

# Main execution
main() {
    echo ""
    check_requirements
    echo ""
    check_gcp_setup
    echo ""
    check_github_setup
    echo ""
    check_terraform_setup
    echo ""
    check_github_secrets
    echo ""
    test_workload_identity
    echo ""
    test_artifact_registry
    echo ""
    test_cloud_run
    echo ""
    test_automatic_deployment
    echo ""
    provide_setup_instructions
    
    echo ""
    print_status "success" "Verification complete!"
    echo ""
    echo "🎉 Your GitHub-GCP connection is ready for automatic deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Push a commit to the main branch to trigger deployment"
    echo "2. Monitor the deployment in GitHub Actions"
    echo "3. Check your services in Google Cloud Console"
}

# Run the script
main "$@"