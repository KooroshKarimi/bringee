#!/bin/bash

<<<<<<< HEAD
# Setup script for Bringee GCP infrastructure
=======
# Bringee GCP Setup Script
# This script helps set up Google Cloud for automatic deployment

>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

<<<<<<< HEAD
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
    read -p "GCP Region (default: europe-west3): " GCP_REGION
    GCP_REGION=${GCP_REGION:-europe-west3}
    
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
=======
echo -e "${GREEN}🚀 Bringee GCP Setup Script${NC}"
echo "=================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Google Cloud SDK is not installed. Please install it first:${NC}"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${YELLOW}⚠️  You are not authenticated with Google Cloud. Please run:${NC}"
    echo "gcloud auth login"
    exit 1
fi

# Get project ID
if [ -z "$1" ]; then
    echo -e "${YELLOW}Please provide your GCP Project ID as an argument:${NC}"
    echo "Usage: ./setup-gcp.sh YOUR_PROJECT_ID"
    exit 1
fi

PROJECT_ID=$1
echo -e "${GREEN}✅ Using GCP Project ID: ${PROJECT_ID}${NC}"

# Set the project
echo -e "${YELLOW}🔧 Setting GCP project...${NC}"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${YELLOW}🔧 Enabling required APIs...${NC}"
APIS=(
    "iam.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "artifactregistry.googleapis.com"
    "secretmanager.googleapis.com"
    "run.googleapis.com"
    "iamcredentials.googleapis.com"
    "cloudbuild.googleapis.com"
)

for api in "${APIS[@]}"; do
    echo "Enabling $api..."
    gcloud services enable $api --project=$PROJECT_ID
done

# Create GCS bucket for Terraform state (if it doesn't exist)
BUCKET_NAME="bringee-terraform-state-bucket-unique"
echo -e "${YELLOW}🔧 Creating Terraform state bucket...${NC}"
gsutil mb -p $PROJECT_ID -c STANDARD -l us-central1 gs://$BUCKET_NAME 2>/dev/null || echo "Bucket already exists or creation failed"

# Create service account for GitHub Actions
echo -e "${YELLOW}🔧 Creating service account for GitHub Actions...${NC}"
gcloud iam service-accounts create github-actions-runner \
    --display-name="GitHub Actions Runner" \
    --description="Service account for GitHub Actions deployments" \
    --project=$PROJECT_ID 2>/dev/null || echo "Service account already exists"

# Grant necessary roles to the service account
echo -e "${YELLOW}🔧 Granting roles to service account...${NC}"
ROLES=(
    "roles/artifactregistry.writer"
    "roles/run.admin"
    "roles/iam.serviceAccountUser"
    "roles/cloudbuild.builds.builder"
)

for role in "${ROLES[@]}"; do
    echo "Granting $role..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:github-actions-runner@$PROJECT_ID.iam.gserviceaccount.com" \
        --role=$role
done

# Create Workload Identity Pool
echo -e "${YELLOW}🔧 Creating Workload Identity Pool...${NC}"
gcloud iam workload-identity-pools create github-actions-pool \
    --location=global \
    --display-name="GitHub Actions Pool" \
    --description="Pool for GitHub Actions runners" \
    --project=$PROJECT_ID 2>/dev/null || echo "Pool already exists"

# Create Workload Identity Provider
echo -e "${YELLOW}🔧 Creating Workload Identity Provider...${NC}"
gcloud iam workload-identity-pools providers create-oidc github-actions-provider \
    --workload-identity-pool=github-actions-pool \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --location=global \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --project=$PROJECT_ID 2>/dev/null || echo "Provider already exists"

# Get the Workload Identity Provider resource name
WORKLOAD_IDENTITY_PROVIDER=$(gcloud iam workload-identity-pools providers describe github-actions-provider \
    --workload-identity-pool=github-actions-pool \
    --location=global \
    --project=$PROJECT_ID \
    --format="value(name)")

# Allow the service account to be impersonated
echo -e "${YELLOW}🔧 Configuring Workload Identity Federation...${NC}"
gcloud iam service-accounts add-iam-policy-binding github-actions-runner@$PROJECT_ID.iam.gserviceaccount.com \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/*"

echo -e "${GREEN}✅ GCP setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Add these secrets to your GitHub repository:"
echo "   - GCP_PROJECT_ID: $PROJECT_ID"
echo ""
echo "2. Update your terraform.tfvars file with:"
echo "   gcp_project_id = \"$PROJECT_ID\""
echo "   github_repository = \"your-username/bringee\""
echo ""
echo "3. Run Terraform to deploy the infrastructure:"
echo "   cd terraform"
echo "   terraform init"
echo "   terraform apply"
echo ""
echo -e "${GREEN}🎉 Your Bringee project is now ready for automatic deployment!${NC}"
>>>>>>> cursor/verbinde-github-mit-google-cloud-c6df
