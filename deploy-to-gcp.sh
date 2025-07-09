#!/bin/bash

# Bringee GCP Deployment Script
# This script deploys the application to Google Cloud Platform

set -e

echo "🚀 Deploying Bringee to Google Cloud Platform"
echo "=============================================="

# Configuration
GCP_PROJECT_ID=${GCP_PROJECT_ID:-"bringee-project"}
GCP_REGION=${GCP_REGION:-"europe-west3"}
GITHUB_REPO=${GITHUB_REPO:-"your-username/bringee"}

echo "Configuration:"
echo "  GCP Project ID: $GCP_PROJECT_ID"
echo "  GCP Region: $GCP_REGION"
echo "  GitHub Repo: $GITHUB_REPO"
echo ""

# Check if we're in a GitHub Actions environment
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "✅ Running in GitHub Actions environment"
    echo "The CI/CD pipeline will handle the deployment automatically"
    echo ""
    echo "Make sure the following GitHub secrets are configured:"
    echo "  - GCP_PROJECT_ID: $GCP_PROJECT_ID"
    echo "  - GCP_SA_KEY: Your Google Cloud Service Account key"
    echo ""
    echo "To configure these secrets:"
    echo "1. Go to your GitHub repository: https://github.com/$GITHUB_REPO"
    echo "2. Go to Settings > Secrets and variables > Actions"
    echo "3. Add the secrets listed above"
    echo ""
    echo "Then push a commit to the main branch to trigger deployment"
    exit 0
fi

# Check if required tools are installed
check_requirements() {
    echo "📋 Checking requirements..."
    
    if ! command -v gcloud &> /dev/null; then
        echo "❌ Google Cloud SDK is not installed."
        echo "Please install it first: https://cloud.google.com/sdk/docs/install"
        echo ""
        echo "For Ubuntu/Debian:"
        echo "  curl https://sdk.cloud.google.com | bash"
        echo "  exec -l $SHELL"
        echo "  gcloud init"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed."
        echo "Please install it first: https://developer.hashicorp.com/terraform/downloads"
        exit 1
    fi
    
    echo "✅ All requirements met"
}

# Authenticate with Google Cloud
authenticate_gcp() {
    echo "🔐 Authenticating with Google Cloud..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        echo "Please authenticate with Google Cloud:"
        gcloud auth login
    fi
    
    echo "Setting project to $GCP_PROJECT_ID..."
    gcloud config set project "$GCP_PROJECT_ID"
    
    echo "✅ Google Cloud authentication complete"
}

# Deploy infrastructure with Terraform
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
    
    echo "✅ Infrastructure deployed"
}

# Build and deploy services manually
build_and_deploy_services() {
    echo "🔨 Building and deploying services..."
    
    # Build and deploy user-service
    echo "Building user-service..."
    cd backend/services/user-service
    go build -o server .
    
    # Create Docker image
    docker build -t gcr.io/$GCP_PROJECT_ID/user-service:latest .
    docker push gcr.io/$GCP_PROJECT_ID/user-service:latest
    
    # Deploy to Cloud Run
    gcloud run deploy user-service \
        --image gcr.io/$GCP_PROJECT_ID/user-service:latest \
        --region $GCP_REGION \
        --platform managed \
        --allow-unauthenticated \
        --port 8080 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10
    
    cd ../../..
    
    # Build and deploy shipment-service
    echo "Building shipment-service..."
    cd backend/services/shipment-service
    go build -o server .
    
    # Create Docker image
    docker build -t gcr.io/$GCP_PROJECT_ID/shipment-service:latest .
    docker push gcr.io/$GCP_PROJECT_ID/shipment-service:latest
    
    # Deploy to Cloud Run
    gcloud run deploy shipment-service \
        --image gcr.io/$GCP_PROJECT_ID/shipment-service:latest \
        --region $GCP_REGION \
        --platform managed \
        --allow-unauthenticated \
        --port 8080 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10
    
    cd ../../..
    
    echo "✅ Services deployed"
}

# Deploy frontend
deploy_frontend() {
    echo "🌐 Deploying frontend..."
    
    cd frontend/bringee_app
    
    # Build Flutter web app
    flutter build web --release
    
    # Deploy to Firebase Hosting (if configured)
    if [ -f "firebase.json" ]; then
        firebase deploy --only hosting --project $GCP_PROJECT_ID
    else
        echo "Firebase configuration not found. Please configure Firebase Hosting manually."
    fi
    
    cd ../..
    
    echo "✅ Frontend deployed"
}

# Main execution
main() {
    check_requirements
    authenticate_gcp
    deploy_infrastructure
    build_and_deploy_services
    deploy_frontend
    
    echo ""
    echo "🎉 Deployment complete!"
    echo "====================="
    echo ""
    echo "Your services are now deployed:"
    [ -n "$USER_SERVICE_URL" ] && echo "• User Service: $USER_SERVICE_URL"
    [ -n "$SHIPMENT_SERVICE_URL" ] && echo "• Shipment Service: $SHIPMENT_SERVICE_URL"
    echo ""
    echo "Next steps:"
    echo "1. Configure GitHub secrets for CI/CD"
    echo "2. Test the deployed services"
    echo "3. Set up monitoring and logging"
}

# Run the script
main "$@"