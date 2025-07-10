#!/bin/bash

# Phase 0 Deployment Script
# Deploys Phase 0 services to Google Cloud

set -e

echo "🚀 Phase 0 Deployment - Bringee"
echo "================================"

# Configuration
GCP_PROJECT_ID=${GCP_PROJECT_ID:-"gemini-koorosh-karimi"}
GCP_REGION=${GCP_REGION:-"europe-west3"}

echo "Configuration:"
echo "  GCP Project ID: $GCP_PROJECT_ID"
echo "  GCP Region: $GCP_REGION"
echo ""

# Check if gcloud is available
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed"
    echo "Please install it first: https://cloud.google.com/sdk/docs/install"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "  curl https://sdk.cloud.google.com | bash"
    echo "  exec -l $SHELL"
    echo "  gcloud init"
    exit 1
fi

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "🔐 Please authenticate with Google Cloud:"
    gcloud auth login
fi

# Set project
echo "Setting project to $GCP_PROJECT_ID..."
gcloud config set project "$GCP_PROJECT_ID"

# Deploy infrastructure with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd terraform

# Create terraform.tfvars
cat > terraform.tfvars << EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git/\1\/\2/')"
EOF

# Initialize and apply Terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan

cd ..

# Build and push Docker images
echo "🐳 Building and pushing Docker images..."

# User Service
echo "Building user-service..."
cd backend/services/user-service
docker build -t europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest .
docker push europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest
cd ../../..

# Shipment Service
echo "Building shipment-service..."
cd backend/services/shipment-service
docker build -t europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest .
docker push europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest
cd ../../..

# Deploy to Cloud Run
echo "☁️  Deploying to Cloud Run..."

# User Service
echo "Deploying user-service..."
gcloud run deploy user-service \
    --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest \
    --region $GCP_REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10

# Shipment Service
echo "Deploying shipment-service..."
gcloud run deploy shipment-service \
    --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest \
    --region $GCP_REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10

# Get service URLs
echo ""
echo "🎉 Deployment complete!"
echo "====================="
echo ""
echo "Service URLs:"
USER_SERVICE_URL=$(gcloud run services describe user-service --region=$GCP_REGION --format="value(status.url)")
SHIPMENT_SERVICE_URL=$(gcloud run services describe shipment-service --region=$GCP_REGION --format="value(status.url)")

echo "• User Service: $USER_SERVICE_URL"
echo "• Shipment Service: $SHIPMENT_SERVICE_URL"
echo ""

# Test services
echo "🧪 Testing services..."
echo ""

echo "Testing User Service:"
curl -s "$USER_SERVICE_URL" || echo "User service not responding"
echo ""

echo "Testing Shipment Service:"
curl -s "$SHIPMENT_SERVICE_URL" || echo "Shipment service not responding"
echo ""

echo "✅ Phase 0 deployment successful!"
echo ""
echo "Next steps:"
echo "1. Configure GitHub secrets for CI/CD"
echo "2. Push to main branch to enable automatic deployments"
echo "3. Start developing Phase 1 features"