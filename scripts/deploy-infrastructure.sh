#!/bin/bash

# Deploy Infrastructure Script
set -e

echo "🚀 Deploying Bringee Infrastructure"

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Get project configuration
echo "📋 Please provide your GCP project configuration:"
read -p "GCP Project ID: " GCP_PROJECT_ID
read -p "GCP Region (default: us-central1): " GCP_REGION
GCP_REGION=${GCP_REGION:-us-central1}
read -p "GitHub Repository (format: owner/repo): " GITHUB_REPOSITORY

# Create terraform.tfvars
cat > terraform/terraform.tfvars << EOF
gcp_project_id    = "${GCP_PROJECT_ID}"
gcp_region        = "${GCP_REGION}"
github_repository = "${GITHUB_REPOSITORY}"
environment       = "dev"
EOF

echo "✅ Configuration saved to terraform/terraform.tfvars"

# Deploy infrastructure
echo "🏗️ Deploying infrastructure with Terraform..."
cd terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -out=tfplan

# Apply the plan
terraform apply tfplan

cd ..

echo "✅ Infrastructure deployed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Add these GitHub Secrets to your repository:"
echo "   - GCP_PROJECT_ID: ${GCP_PROJECT_ID}"
echo "   - GCP_REGION: ${GCP_REGION}"
echo ""
echo "2. Push your code to trigger the CI/CD pipeline:"
echo "   git add ."
echo "   git commit -m 'Setup infrastructure'"
echo "   git push origin main"