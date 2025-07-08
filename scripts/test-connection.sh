#!/bin/bash

# Test GitHub-Google Cloud Connection
# This script tests if the connection between GitHub and Google Cloud is working

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔗 Testing GitHub-Google Cloud Connection${NC}"
echo "=============================================="

# Check if gcloud is available
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Google Cloud SDK is not installed${NC}"
    echo "Please install it first:"
    echo "curl https://sdk.cloud.google.com | bash"
    exit 1
fi

# Check authentication
echo -e "${YELLOW}1. Checking Google Cloud authentication...${NC}"
if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${GREEN}✅ Authenticated with Google Cloud${NC}"
    gcloud auth list --filter=status:ACTIVE --format="value(account)"
else
    echo -e "${RED}❌ Not authenticated with Google Cloud${NC}"
    echo "Run: gcloud auth login"
    exit 1
fi

# Check project
echo -e "\n${YELLOW}2. Checking GCP project...${NC}"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -n "$PROJECT_ID" ]; then
    echo -e "${GREEN}✅ GCP Project is set: ${PROJECT_ID}${NC}"
else
    echo -e "${RED}❌ No GCP project is set${NC}"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Check Workload Identity Pool
echo -e "\n${YELLOW}3. Checking Workload Identity Federation...${NC}"
if gcloud iam workload-identity-pools list --location=global --format="value(name)" | grep -q "github-actions-pool"; then
    echo -e "${GREEN}✅ Workload Identity Pool exists${NC}"
    
    # Get the provider details
    PROVIDER=$(gcloud iam workload-identity-pools providers describe github-actions-provider \
        --workload-identity-pool=github-actions-pool \
        --location=global \
        --format="value(name)" 2>/dev/null || echo "")
    
    if [ -n "$PROVIDER" ]; then
        echo -e "${GREEN}✅ Workload Identity Provider configured${NC}"
    else
        echo -e "${RED}❌ Workload Identity Provider not found${NC}"
    fi
else
    echo -e "${RED}❌ Workload Identity Pool not found${NC}"
    echo "Run the setup script: ./scripts/setup-gcp.sh $PROJECT_ID"
fi

# Check Service Account
echo -e "\n${YELLOW}4. Checking Service Account...${NC}"
SERVICE_ACCOUNT="github-actions-runner@$PROJECT_ID.iam.gserviceaccount.com"
if gcloud iam service-accounts list --format="value(email)" | grep -q "github-actions-runner"; then
    echo -e "${GREEN}✅ Service Account exists: $SERVICE_ACCOUNT${NC}"
else
    echo -e "${RED}❌ Service Account not found${NC}"
    echo "Run the setup script: ./scripts/setup-gcp.sh $PROJECT_ID"
fi

# Check Artifact Registry
echo -e "\n${YELLOW}5. Checking Artifact Registry...${NC}"
if gcloud artifacts repositories list --location=us-central1 --format="value(name)" | grep -q "bringee-artifacts"; then
    echo -e "${GREEN}✅ Artifact Registry repository exists${NC}"
else
    echo -e "${RED}❌ Artifact Registry repository not found${NC}"
    echo "Run Terraform: cd terraform && terraform apply"
fi

# Check Cloud Run services
echo -e "\n${YELLOW}6. Checking Cloud Run services...${NC}"
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

# Test Docker authentication
echo -e "\n${YELLOW}7. Testing Docker authentication...${NC}"
if gcloud auth configure-docker us-central1-docker.pkg.dev --quiet; then
    echo -e "${GREEN}✅ Docker authentication configured${NC}"
else
    echo -e "${RED}❌ Docker authentication failed${NC}"
fi

# Check GitHub repository
echo -e "\n${YELLOW}8. Checking GitHub repository configuration...${NC}"
if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo -e "${GREEN}✅ GitHub Actions workflow exists${NC}"
    
    # Check if GCP_PROJECT_ID is referenced
    if grep -q "GCP_PROJECT_ID" .github/workflows/ci-cd.yml; then
        echo -e "${GREEN}✅ GitHub Actions workflow references GCP_PROJECT_ID${NC}"
    else
        echo -e "${RED}❌ GitHub Actions workflow doesn't reference GCP_PROJECT_ID${NC}"
    fi
else
    echo -e "${RED}❌ GitHub Actions workflow not found${NC}"
fi

echo -e "\n${BLUE}📋 Connection Test Summary${NC}"
echo "=========================="

echo -e "${YELLOW}To complete the setup, you need to:${NC}"
echo "1. Add GitHub Secret: GCP_PROJECT_ID = $PROJECT_ID"
echo "2. Apply Terraform: cd terraform && terraform apply"
echo "3. Test deployment: git push origin main"
echo ""
echo -e "${GREEN}🎉 Connection test completed!${NC}"