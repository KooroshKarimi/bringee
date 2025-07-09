#!/bin/bash

# Setup script for Bringee GCP infrastructure
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setting up Bringee GCP Infrastructure${NC}"

# Check if required tools are installed
check_requirements() {
    echo -e "${YELLOW}Checking requirements...${NC}"
    
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}❌ gcloud CLI is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All requirements met${NC}"
}

# Get project configuration
get_project_config() {
    echo -e "${YELLOW}Please provide your GCP project configuration:${NC}"
    
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
    
    echo -e "${GREEN}✅ Configuration saved to terraform/terraform.tfvars${NC}"
}

# Create GCS bucket for Terraform state
create_terraform_bucket() {
    echo -e "${YELLOW}Creating Terraform state bucket...${NC}"
    
    BUCKET_NAME="bringee-terraform-state-${GCP_PROJECT_ID}"
    
    if gsutil ls -b "gs://${BUCKET_NAME}" &> /dev/null; then
        echo -e "${YELLOW}Bucket already exists${NC}"
    else
        gsutil mb -p "${GCP_PROJECT_ID}" -c STANDARD -l "${GCP_REGION}" "gs://${BUCKET_NAME}"
        echo -e "${GREEN}✅ Terraform state bucket created: ${BUCKET_NAME}${NC}"
    fi
}

# Enable required APIs
enable_apis() {
    echo -e "${YELLOW}Enabling required GCP APIs...${NC}"
    
    APIs=(
        "iam.googleapis.com"
        "cloudresourcemanager.googleapis.com"
        "artifactregistry.googleapis.com"
        "secretmanager.googleapis.com"
        "run.googleapis.com"
        "iamcredentials.googleapis.com"
    )
    
    for api in "${APIs[@]}"; do
        echo "Enabling ${api}..."
        gcloud services enable "${api}" --project="${GCP_PROJECT_ID}"
    done
    
    echo -e "${GREEN}✅ All APIs enabled${NC}"
}

# Initialize and apply Terraform
deploy_infrastructure() {
    echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Plan the deployment
    terraform plan -out=tfplan
    
    # Apply the plan
    terraform apply tfplan
    
    cd ..
    
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
}

# Get outputs for GitHub Secrets
get_github_secrets() {
    echo -e "${YELLOW}Getting configuration for GitHub Secrets...${NC}"
    
    cd terraform
    terraform output -json > ../terraform_output.json
    cd ..
    
    echo -e "${GREEN}✅ Terraform outputs saved to terraform_output.json${NC}"
    echo -e "${YELLOW}Please add the following secrets to your GitHub repository:${NC}"
    echo -e "${GREEN}GCP_PROJECT_ID: ${GCP_PROJECT_ID}${NC}"
    echo -e "${GREEN}GCP_REGION: ${GCP_REGION}${NC}"
}

# Main execution
main() {
    check_requirements
    get_project_config
    create_terraform_bucket
    enable_apis
    deploy_infrastructure
    get_github_secrets
    
    echo -e "${GREEN}🎉 Setup complete!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Add the GitHub secrets to your repository"
    echo -e "2. Push your code to the main branch"
    echo -e "3. Watch the GitHub Actions workflow deploy your services"
}

# Run main function
main "$@"