#!/bin/bash

# Bringee Setup Verification Script
# This script verifies that all components are properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Bringee Setup Verification${NC}"
echo "=================================="

# Check if gcloud is installed and authenticated
echo -e "${YELLOW}1. Checking Google Cloud SDK...${NC}"
if command -v gcloud &> /dev/null; then
    echo -e "${GREEN}✅ Google Cloud SDK is installed${NC}"
    
    # Check authentication
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        echo -e "${GREEN}✅ Authenticated with Google Cloud${NC}"
        gcloud auth list --filter=status:ACTIVE --format="value(account)"
    else
        echo -e "${RED}❌ Not authenticated with Google Cloud${NC}"
        echo "Run: gcloud auth login"
    fi
else
    echo -e "${RED}❌ Google Cloud SDK is not installed${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
fi

# Check if project is set
echo -e "\n${YELLOW}2. Checking GCP Project...${NC}"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -n "$PROJECT_ID" ]; then
    echo -e "${GREEN}✅ GCP Project is set: ${PROJECT_ID}${NC}"
else
    echo -e "${RED}❌ No GCP project is set${NC}"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
fi

# Check required APIs
echo -e "\n${YELLOW}3. Checking required APIs...${NC}"
REQUIRED_APIS=(
    "iam.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "artifactregistry.googleapis.com"
    "secretmanager.googleapis.com"
    "run.googleapis.com"
    "iamcredentials.googleapis.com"
    "cloudbuild.googleapis.com"
)

for api in "${REQUIRED_APIS[@]}"; do
    if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
        echo -e "${GREEN}✅ $api is enabled${NC}"
    else
        echo -e "${RED}❌ $api is not enabled${NC}"
    fi
done

# Check Workload Identity Pool
echo -e "\n${YELLOW}4. Checking Workload Identity Federation...${NC}"
if gcloud iam workload-identity-pools list --location=global --format="value(name)" | grep -q "github-actions-pool"; then
    echo -e "${GREEN}✅ Workload Identity Pool exists${NC}"
else
    echo -e "${RED}❌ Workload Identity Pool not found${NC}"
fi

# Check Service Account
echo -e "\n${YELLOW}5. Checking Service Account...${NC}"
if gcloud iam service-accounts list --format="value(email)" | grep -q "github-actions-runner"; then
    echo -e "${GREEN}✅ GitHub Actions Service Account exists${NC}"
else
    echo -e "${RED}❌ GitHub Actions Service Account not found${NC}"
fi

# Check Artifact Registry
echo -e "\n${YELLOW}6. Checking Artifact Registry...${NC}"
if gcloud artifacts repositories list --location=us-central1 --format="value(name)" | grep -q "bringee-artifacts"; then
    echo -e "${GREEN}✅ Artifact Registry repository exists${NC}"
else
    echo -e "${RED}❌ Artifact Registry repository not found${NC}"
fi

# Check Terraform files
echo -e "\n${YELLOW}7. Checking Terraform configuration...${NC}"
if [ -f "terraform/main.tf" ]; then
    echo -e "${GREEN}✅ Terraform main.tf exists${NC}"
else
    echo -e "${RED}❌ Terraform main.tf not found${NC}"
fi

if [ -f "terraform/terraform.tfvars" ]; then
    echo -e "${GREEN}✅ Terraform variables file exists${NC}"
else
    echo -e "${YELLOW}⚠️  Terraform variables file not found${NC}"
    echo "Run: cp terraform/terraform.tfvars.example terraform/terraform.tfvars"
fi

# Check GitHub Actions workflow
echo -e "\n${YELLOW}8. Checking GitHub Actions workflow...${NC}"
if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo -e "${GREEN}✅ GitHub Actions workflow exists${NC}"
else
    echo -e "${RED}❌ GitHub Actions workflow not found${NC}"
fi

# Check Dockerfiles
echo -e "\n${YELLOW}9. Checking Dockerfiles...${NC}"
if [ -f "backend/services/user-service/Dockerfile" ]; then
    echo -e "${GREEN}✅ User service Dockerfile exists${NC}"
else
    echo -e "${RED}❌ User service Dockerfile not found${NC}"
fi

if [ -f "backend/services/shipment-service/Dockerfile" ]; then
    echo -e "${GREEN}✅ Shipment service Dockerfile exists${NC}"
else
    echo -e "${RED}❌ Shipment service Dockerfile not found${NC}"
fi

# Check Cloud Run services
echo -e "\n${YELLOW}10. Checking Cloud Run services...${NC}"
if gcloud run services list --region=us-central1 --format="value(metadata.name)" | grep -q "user-service"; then
    echo -e "${GREEN}✅ User service exists in Cloud Run${NC}"
else
    echo -e "${YELLOW}⚠️  User service not found in Cloud Run${NC}"
    echo "This is normal if Terraform hasn't been applied yet"
fi

if gcloud run services list --region=us-central1 --format="value(metadata.name)" | grep -q "shipment-service"; then
    echo -e "${GREEN}✅ Shipment service exists in Cloud Run${NC}"
else
    echo -e "${YELLOW}⚠️  Shipment service not found in Cloud Run${NC}"
    echo "This is normal if Terraform hasn't been applied yet"
fi

echo -e "\n${BLUE}📋 Summary${NC}"
echo "=========="
echo "✅ Setup verification completed"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. If any ❌ items were found, run the setup script again"
echo "2. Apply Terraform: cd terraform && terraform apply"
echo "3. Add GitHub secrets: GCP_PROJECT_ID"
echo "4. Test deployment: git push origin main"
echo ""
echo -e "${GREEN}🎉 Your Bringee project is ready for automatic deployment!${NC}"