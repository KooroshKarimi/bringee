#!/bin/bash

# Bringee GCP Deployment Setup Script
# This script sets up the complete CI/CD pipeline with Google Cloud Platform

set -e

echo "🚀 Setting up Bringee GCP Deployment Pipeline"
echo "=============================================="

# Check if required tools are installed
check_requirements() {
    echo "📋 Checking requirements..."
    
    if ! command -v gcloud &> /dev/null; then
        echo "❌ Google Cloud SDK is not installed. Please install it first:"
        echo "   https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed. Please install it first:"
        echo "   https://developer.hashicorp.com/terraform/downloads"
        exit 1
    fi
    
    echo "✅ All requirements met"
}

# Get user input
get_user_input() {
    echo ""
    echo "📝 Please provide the following information:"
    
    read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
    read -p "Enter your GCP Region (default: europe-west3): " GCP_REGION
GCP_REGION=${GCP_REGION:-europe-west3}
    
    read -p "Enter your GitHub repository (format: owner/repo): " GITHUB_REPO
    
    echo ""
    echo "Configuration:"
    echo "  GCP Project ID: $GCP_PROJECT_ID"
    echo "  GCP Region: $GCP_REGION"
    echo "  GitHub Repo: $GITHUB_REPO"
    echo ""
    
    read -p "Is this correct? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
}

# Create Terraform state bucket
create_terraform_bucket() {
    echo "🪣 Creating Terraform state bucket..."
    
    BUCKET_NAME="bringee-terraform-state-$(date +%s)"
    
    gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$BUCKET_NAME" || {
        echo "⚠️  Bucket creation failed. You may need to create it manually or use a different name."
        read -p "Enter a unique bucket name for Terraform state: " BUCKET_NAME
        gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$BUCKET_NAME"
    }
    
    echo "✅ Terraform state bucket created: gs://$BUCKET_NAME"
    
    # Update terraform/main.tf with the bucket name
    sed -i "s/bringee-terraform-state-bucket-unique/$BUCKET_NAME/" terraform/main.tf
}

# Initialize and apply Terraform
deploy_infrastructure() {
    echo "🏗️  Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Create terraform.tfvars
    cat > terraform.tfvars << EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "$GITHUB_REPO"
EOF
    
    # Initialize Terraform
    terraform init
    
    # Plan and apply
    terraform plan -out=tfplan
    terraform apply tfplan
    
    # Get outputs
    GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email 2>/dev/null || echo "")
    USER_SERVICE_URL=$(terraform output -raw user_service_url 2>/dev/null || echo "")
    SHIPMENT_SERVICE_URL=$(terraform output -raw shipment_service_url 2>/dev/null || echo "")
    
    cd ..
}

# Setup GitHub secrets
setup_github_secrets() {
    echo ""
    echo "🔐 GitHub Secrets Setup"
    echo "======================"
    echo ""
    
    # Check if GitHub CLI is available
    if command -v gh &> /dev/null; then
        echo "GitHub CLI detected. Attempting to set secrets automatically..."
        
        # Set secrets using GitHub CLI
        echo "$GCP_PROJECT_ID" | gh secret set GCP_PROJECT_ID --repo "$GITHUB_REPO"
        echo "$GITHUB_ACTIONS_SA_EMAIL" | gh secret set GITHUB_ACTIONS_SA_EMAIL --repo "$GITHUB_REPO"
        
        echo "✅ GitHub secrets set automatically using GitHub CLI"
    else
        echo "GitHub CLI not found. Please set secrets manually:"
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
    fi
}

# Test the deployment
test_deployment() {
    echo ""
    echo "🧪 Testing deployment..."
    
    if [ -n "$USER_SERVICE_URL" ]; then
        echo "Testing User Service: $USER_SERVICE_URL"
        curl -s "$USER_SERVICE_URL/health" || echo "User service not responding"
    fi
    
    if [ -n "$SHIPMENT_SERVICE_URL" ]; then
        echo "Testing Shipment Service: $SHIPMENT_SERVICE_URL"
        curl -s "$SHIPMENT_SERVICE_URL/health" || echo "Shipment service not responding"
    fi
}

# Main execution
main() {
    check_requirements
    get_user_input
    create_terraform_bucket
    deploy_infrastructure
    setup_github_secrets
    test_deployment
    
    echo ""
    echo "🎉 Setup complete!"
    echo "================"
    echo ""
    echo "Your CI/CD pipeline is now configured:"
    echo "• Push to main branch will trigger automatic deployment"
    echo "• Docker images will be built and pushed to Artifact Registry"
    echo "• Services will be automatically deployed to Cloud Run"
    echo ""
    echo "Service URLs:"
    [ -n "$USER_SERVICE_URL" ] && echo "• User Service: $USER_SERVICE_URL"
    [ -n "$SHIPMENT_SERVICE_URL" ] && echo "• Shipment Service: $SHIPMENT_SERVICE_URL"
    echo ""
    echo "Next steps:"
    echo "1. Make sure your GitHub secrets are configured"
    echo "2. Push a commit to the main branch to test the pipeline"
    echo "3. Monitor the deployment in GitHub Actions"
}

# Run the script
main "$@"