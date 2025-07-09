#!/bin/bash

# Fix Workload Identity Federation Script
# This script fixes the Workload Identity Federation authentication issue

set -e

echo "🔧 Fixing Workload Identity Federation"
echo "======================================"

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

# Check if we're in the right directory
check_directory() {
    if [ ! -d "terraform" ]; then
        print_status "error" "Terraform directory not found. Please run this script from the project root."
        exit 1
    fi
    
    if [ ! -f "terraform/terraform.tfvars" ]; then
        print_status "error" "terraform.tfvars not found. Please run the setup script first."
        exit 1
    fi
    
    print_status "success" "Project structure verified"
}

# Get current configuration
get_current_config() {
    print_status "info" "Reading current configuration..."
    
    cd terraform
    
    # Read terraform.tfvars
    GCP_PROJECT_ID=$(grep "gcp_project_id" terraform.tfvars | cut -d'"' -f2)
    GCP_REGION=$(grep "gcp_region" terraform.tfvars | cut -d'"' -f2)
    GITHUB_REPO=$(grep "github_repository" terraform.tfvars | cut -d'"' -f2)
    
    cd ..
    
    print_status "success" "Configuration loaded:"
    echo "  Project ID: $GCP_PROJECT_ID"
    echo "  Region: $GCP_REGION"
    echo "  GitHub Repo: $GITHUB_REPO"
}

# Destroy existing Workload Identity resources
destroy_workload_identity() {
    print_status "info" "Destroying existing Workload Identity resources..."
    
    cd terraform
    
    # Destroy only the Workload Identity resources
    terraform destroy -target=google_iam_workload_identity_pool_provider.github_provider \
                     -target=google_iam_workload_identity_pool.github_pool \
                     -target=google_service_account_iam_member.github_actions_impersonation \
                     -auto-approve
    
    cd ..
    
    print_status "success" "Workload Identity resources destroyed"
}

# Recreate Workload Identity resources
recreate_workload_identity() {
    print_status "info" "Recreating Workload Identity resources..."
    
    cd terraform
    
    # Apply the updated configuration
    terraform apply -auto-approve
    
    # Get the new outputs
    GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email 2>/dev/null || echo "")
    WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw workload_identity_provider 2>/dev/null || echo "")
    
    cd ..
    
    print_status "success" "Workload Identity resources recreated"
    echo "  Service Account: $GITHUB_ACTIONS_SA_EMAIL"
    echo "  Provider: $WORKLOAD_IDENTITY_PROVIDER"
}

# Test the Workload Identity configuration
test_workload_identity() {
    print_status "info" "Testing Workload Identity configuration..."
    
    # Check if the pool exists
    if gcloud iam workload-identity-pools list --location=global --project="$GCP_PROJECT_ID" | grep -q "github-actions-pool"; then
        print_status "success" "Workload Identity Pool exists"
    else
        print_status "error" "Workload Identity Pool not found"
        return 1
    fi
    
    # Check if the provider exists
    if gcloud iam workload-identity-pools providers list --workload-identity-pool=github-actions-pool --location=global --project="$GCP_PROJECT_ID" | grep -q "github-actions-provider"; then
        print_status "success" "Workload Identity Provider exists"
    else
        print_status "error" "Workload Identity Provider not found"
        return 1
    fi
    
    # Test the service account permissions
    if gcloud projects get-iam-policy "$GCP_PROJECT_ID" --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:github-actions-runner" | grep -q "roles/iam.workloadIdentityUser"; then
        print_status "success" "Service Account has Workload Identity User role"
    else
        print_status "error" "Service Account missing Workload Identity User role"
        return 1
    fi
}

# Update GitHub Secrets
update_github_secrets() {
    print_status "info" "Updating GitHub Secrets..."
    
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        # Update secrets using GitHub CLI
        echo "$GCP_PROJECT_ID" | gh secret set GCP_PROJECT_ID --repo "$GITHUB_REPO" --force
        echo "$GITHUB_ACTIONS_SA_EMAIL" | gh secret set GITHUB_ACTIONS_SA_EMAIL --repo "$GITHUB_REPO" --force
        
        print_status "success" "GitHub secrets updated automatically"
    else
        print_status "warning" "GitHub CLI not available or not authenticated"
        echo ""
        echo "Please manually update these secrets in GitHub:"
        echo "1. Go to: https://github.com/$GITHUB_REPO/settings/secrets/actions"
        echo "2. Update or add these secrets:"
        echo "   - GCP_PROJECT_ID: $GCP_PROJECT_ID"
        echo "   - GITHUB_ACTIONS_SA_EMAIL: $GITHUB_ACTIONS_SA_EMAIL"
        echo ""
        
        read -p "Press Enter when you've updated the secrets..."
    fi
}

# Test the GitHub Actions workflow
test_github_actions_workflow() {
    print_status "info" "Testing GitHub Actions workflow configuration..."
    
    if [ -f ".github/workflows/ci-cd.yml" ]; then
        # Check if the workflow uses the correct provider
        if grep -q "workload_identity_provider" .github/workflows/ci-cd.yml; then
            print_status "success" "Workload Identity Provider configured in workflow"
        else
            print_status "error" "Workload Identity Provider not configured in workflow"
        fi
        
        if grep -q "GCP_PROJECT_ID" .github/workflows/ci-cd.yml; then
            print_status "success" "GCP Project ID configured in workflow"
        else
            print_status "error" "GCP Project ID not configured in workflow"
        fi
    else
        print_status "error" "CI/CD workflow not found"
    fi
}

# Provide next steps
provide_next_steps() {
    echo ""
    print_status "success" "Workload Identity Federation fixed!"
    echo ""
    echo "🎉 The authentication issue should now be resolved!"
    echo ""
    echo "Next steps:"
    echo "1. Push a commit to trigger a new GitHub Actions run:"
    echo "   git add ."
    echo "   git commit -m 'Fix Workload Identity Federation'"
    echo "   git push origin main"
    echo ""
    echo "2. Monitor the GitHub Actions run:"
    echo "   https://github.com/$GITHUB_REPO/actions"
    echo ""
    echo "3. If you still encounter issues, check:"
    echo "   - GitHub Secrets are correctly set"
    echo "   - Repository name matches exactly: $GITHUB_REPO"
    echo "   - GCP Project ID is correct: $GCP_PROJECT_ID"
    echo ""
}

# Main execution
main() {
    check_directory
    get_current_config
    destroy_workload_identity
    recreate_workload_identity
    test_workload_identity
    update_github_secrets
    test_github_actions_workflow
    provide_next_steps
}

# Run the script
main "$@"