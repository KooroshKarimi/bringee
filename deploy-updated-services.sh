#!/bin/bash

# Bringee Services Deployment Script
# This script builds and deploys the updated Bringee services

set -e

echo "🚀 Starting Bringee Services Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="europe-west3"
REPOSITORY="bringee-artifacts"

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Region: $REGION"
echo "  Repository: $REPOSITORY"

# Check if required tools are installed
check_dependencies() {
    echo -e "${YELLOW}🔍 Checking dependencies...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}❌ Google Cloud CLI is not installed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All dependencies are installed${NC}"
}

# Build and push user service
deploy_user_service() {
    echo -e "${YELLOW}🔨 Building User Service...${NC}"
    
    cd backend/services/user-service
    
    # Build Docker image
    docker build -t europe-west3-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/user-service:latest .
    
    # Push to Artifact Registry
    docker push europe-west3-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/user-service:latest
    
    echo -e "${GREEN}✅ User Service built and pushed${NC}"
    cd ../../..
}

# Build and push shipment service
deploy_shipment_service() {
    echo -e "${YELLOW}🔨 Building Shipment Service...${NC}"
    
    cd backend/services/shipment-service
    
    # Build Docker image
    docker build -t europe-west3-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/shipment-service:latest .
    
    # Push to Artifact Registry
    docker push europe-west3-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/shipment-service:latest
    
    echo -e "${GREEN}✅ Shipment Service built and pushed${NC}"
    cd ../../..
}

# Deploy to Cloud Run
deploy_to_cloud_run() {
    echo -e "${YELLOW}🚀 Deploying to Cloud Run...${NC}"
    
    # Deploy user service
    gcloud run deploy user-service \
        --image europe-west3-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/user-service:latest \
        --platform managed \
        --region $REGION \
        --allow-unauthenticated \
        --port 8080 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10
    
    # Deploy shipment service
    gcloud run deploy shipment-service \
        --image europe-west3-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/shipment-service:latest \
        --platform managed \
        --region $REGION \
        --allow-unauthenticated \
        --port 8080 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10
    
    echo -e "${GREEN}✅ Services deployed to Cloud Run${NC}"
}

# Get service URLs
get_service_urls() {
    echo -e "${YELLOW}🌐 Getting service URLs...${NC}"
    
    USER_SERVICE_URL=$(gcloud run services describe user-service --region=$REGION --format="value(status.url)")
    SHIPMENT_SERVICE_URL=$(gcloud run services describe shipment-service --region=$REGION --format="value(status.url)")
    
    echo -e "${GREEN}✅ Service URLs:${NC}"
    echo "  User Service: $USER_SERVICE_URL"
    echo "  Shipment Service: $SHIPMENT_SERVICE_URL"
    
    # Test the services
    echo -e "${YELLOW}🧪 Testing services...${NC}"
    
    echo "Testing User Service..."
    curl -s "$USER_SERVICE_URL/" | jq .
    
    echo "Testing Shipment Service..."
    curl -s "$SHIPMENT_SERVICE_URL/" | jq .
    
    echo -e "${GREEN}✅ Services are running and responding${NC}"
}

# Update Flutter app with correct URLs
update_flutter_urls() {
    echo -e "${YELLOW}📱 Updating Flutter app URLs...${NC}"
    
    USER_SERVICE_URL=$(gcloud run services describe user-service --region=$REGION --format="value(status.url)")
    SHIPMENT_SERVICE_URL=$(gcloud run services describe shipment-service --region=$REGION --format="value(status.url)")
    
    # Update the main.dart file with correct URLs
    sed -i "s|https://user-service-xxxxx-ew.a.run.app|$USER_SERVICE_URL|g" frontend/bringee_app/lib/main.dart
    sed -i "s|https://shipment-service-xxxxx-ew.a.run.app|$SHIPMENT_SERVICE_URL|g" frontend/bringee_app/lib/main.dart
    
    echo -e "${GREEN}✅ Flutter app URLs updated${NC}"
}

# Main deployment process
main() {
    check_dependencies
    deploy_user_service
    deploy_shipment_service
    deploy_to_cloud_run
    get_service_urls
    update_flutter_urls
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "  1. Build and deploy the Flutter app"
    echo "  2. Test the API endpoints"
    echo "  3. Verify the Bringee application is working"
    echo ""
    echo -e "${GREEN}🌐 Your Bringee services are now live!${NC}"
}

# Run the deployment
main