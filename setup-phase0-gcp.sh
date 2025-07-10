#!/bin/bash

# Bringee Phase 0 - Google Cloud Setup Script
# This script sets up the complete Phase 0 infrastructure on Google Cloud

set -e

echo "🚀 Setting up Bringee Phase 0 on Google Cloud"
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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    local missing_tools=()
    
    if ! command -v gcloud &> /dev/null; then
        missing_tools+=("Google Cloud SDK")
    fi
    
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("Terraform")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("Docker")
    fi
    
    if ! command -v go &> /dev/null; then
        missing_tools+=("Go")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools:"
        echo "  - Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
        echo "  - Terraform: https://developer.hashicorp.com/terraform/downloads"
        echo "  - Docker: https://docs.docker.com/get-docker/"
        echo "  - Go: https://golang.org/doc/install"
        exit 1
    fi
    
    print_success "All requirements met"
}

# Authenticate with Google Cloud
authenticate_gcp() {
    print_status "Authenticating with Google Cloud..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_warning "No active Google Cloud authentication found"
        echo "Please authenticate with Google Cloud:"
        gcloud auth login
    fi
    
    print_status "Setting project to $GCP_PROJECT_ID..."
    gcloud config set project "$GCP_PROJECT_ID"
    
    # Enable required APIs
    print_status "Enabling required Google Cloud APIs..."
    gcloud services enable \
        iam.googleapis.com \
        cloudresourcemanager.googleapis.com \
        artifactregistry.googleapis.com \
        secretmanager.googleapis.com \
        run.googleapis.com \
        iamcredentials.googleapis.com \
        logging.googleapis.com \
        monitoring.googleapis.com \
        cloudbuild.googleapis.com \
        containerregistry.googleapis.com
    
    print_success "Google Cloud authentication complete"
}

# Create GCS bucket for Terraform state
create_terraform_bucket() {
    print_status "Creating GCS bucket for Terraform state..."
    
    local bucket_name="bringee-terraform-state-bucket-unique"
    
    if ! gsutil ls -b "gs://$bucket_name" &> /dev/null; then
        gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://$bucket_name"
        gsutil iam ch allUsers:objectViewer "gs://$bucket_name"
        print_success "Terraform state bucket created: gs://$bucket_name"
    else
        print_success "Terraform state bucket already exists: gs://$bucket_name"
    fi
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Create terraform.tfvars
    cat > terraform.tfvars << EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "$GITHUB_REPO"
EOF
    
    print_status "Initializing Terraform..."
    terraform init
    
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    print_status "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Get outputs
    GITHUB_ACTIONS_SA_EMAIL=$(terraform output -raw github_actions_sa_email 2>/dev/null || echo "")
    USER_SERVICE_URL=$(terraform output -raw user_service_url 2>/dev/null || echo "")
    SHIPMENT_SERVICE_URL=$(terraform output -raw shipment_service_url 2>/dev/null || echo "")
    
    cd ..
    
    print_success "Infrastructure deployed successfully"
}

# Build and test backend services
build_and_test_services() {
    print_status "Building and testing backend services..."
    
    # Build and test user-service
    print_status "Building user-service..."
    cd backend/services/user-service
    
    # Download dependencies
    go mod download
    
    # Run tests
    print_status "Running tests for user-service..."
    go test -v ./...
    
    # Build the service
    go build -v -o server .
    
    cd ../../..
    
    # Build and test shipment-service
    print_status "Building shipment-service..."
    cd backend/services/shipment-service
    
    # Download dependencies
    go mod download
    
    # Run tests
    print_status "Running tests for shipment-service..."
    go test -v ./...
    
    # Build the service
    go build -v -o server .
    
    cd ../../..
    
    print_success "Backend services built and tested successfully"
}

# Build and push Docker images
build_and_push_images() {
    print_status "Building and pushing Docker images..."
    
    # Authenticate Docker to Google Cloud
    gcloud auth configure-docker europe-west3-docker.pkg.dev
    
    # Build and push user-service
    print_status "Building user-service Docker image..."
    cd backend/services/user-service
    
    docker build --platform linux/amd64 \
        --tag europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest \
        .
    
    docker push europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest
    
    cd ../../..
    
    # Build and push shipment-service
    print_status "Building shipment-service Docker image..."
    cd backend/services/shipment-service
    
    docker build --platform linux/amd64 \
        --tag europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest \
        .
    
    docker push europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest
    
    cd ../../..
    
    print_success "Docker images built and pushed successfully"
}

# Deploy services to Cloud Run
deploy_to_cloud_run() {
    print_status "Deploying services to Cloud Run..."
    
    # Deploy user-service
    print_status "Deploying user-service to Cloud Run..."
    gcloud run deploy user-service \
        --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest \
        --region $GCP_REGION \
        --platform managed \
        --allow-unauthenticated \
        --port 8080 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10 \
        --set-env-vars="ENVIRONMENT=staging"
    
    # Deploy shipment-service
    print_status "Deploying shipment-service to Cloud Run..."
    gcloud run deploy shipment-service \
        --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest \
        --region $GCP_REGION \
        --platform managed \
        --allow-unauthenticated \
        --port 8080 \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 10 \
        --set-env-vars="ENVIRONMENT=staging"
    
    print_success "Services deployed to Cloud Run successfully"
}

# Setup GitHub Actions secrets
setup_github_secrets() {
    print_status "Setting up GitHub Actions secrets..."
    
    echo ""
    echo "📋 GitHub Secrets Setup Required"
    echo "================================"
    echo ""
    echo "Please configure the following secrets in your GitHub repository:"
    echo ""
    echo "1. Go to: https://github.com/$GITHUB_REPO/settings/secrets/actions"
    echo ""
    echo "2. Add these secrets:"
    echo ""
    echo "   GCP_PROJECT_ID:"
    echo "   Value: $GCP_PROJECT_ID"
    echo ""
    echo "   GITHUB_ACTIONS_SA_EMAIL:"
    echo "   Value: $GITHUB_ACTIONS_SA_EMAIL"
    echo ""
    echo "3. For Workload Identity Federation, also add:"
    echo ""
    echo "   WORKLOAD_IDENTITY_PROVIDER:"
    echo "   Value: projects/$GCP_PROJECT_ID/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider"
    echo ""
    echo "4. Alternative: If you prefer Service Account Key authentication:"
    echo ""
    echo "   GCP_SA_KEY:"
    echo "   Value: [Download the JSON key from Google Cloud Console]"
    echo ""
}

# Test the deployed services
test_deployed_services() {
    print_status "Testing deployed services..."
    
    # Get service URLs
    USER_SERVICE_URL=$(gcloud run services describe user-service --region=$GCP_REGION --format="value(status.url)")
    SHIPMENT_SERVICE_URL=$(gcloud run services describe shipment-service --region=$GCP_REGION --format="value(status.url)")
    
    echo ""
    echo "🧪 Testing deployed services..."
    echo "================================"
    echo ""
    
    # Test user-service
    print_status "Testing user-service..."
    if curl -s "$USER_SERVICE_URL" | grep -q "Hello from user-service"; then
        print_success "✅ user-service is working correctly"
    else
        print_error "❌ user-service test failed"
    fi
    
    # Test shipment-service
    print_status "Testing shipment-service..."
    if curl -s "$SHIPMENT_SERVICE_URL" | grep -q "Hello from shipment-service"; then
        print_success "✅ shipment-service is working correctly"
    else
        print_error "❌ shipment-service test failed"
    fi
    
    # Test health endpoints
    print_status "Testing health endpoints..."
    if curl -s "$USER_SERVICE_URL/health" | grep -q "healthy"; then
        print_success "✅ user-service health check passed"
    else
        print_error "❌ user-service health check failed"
    fi
    
    if curl -s "$SHIPMENT_SERVICE_URL/health" | grep -q "healthy"; then
        print_success "✅ shipment-service health check passed"
    else
        print_error "❌ shipment-service health check failed"
    fi
    
    echo ""
    echo "🌐 Service URLs:"
    echo "  User Service: $USER_SERVICE_URL"
    echo "  Shipment Service: $SHIPMENT_SERVICE_URL"
    echo ""
}

# Main execution
main() {
    echo ""
    print_status "Starting Phase 0 setup..."
    echo ""
    
    check_requirements
    authenticate_gcp
    create_terraform_bucket
    deploy_infrastructure
    build_and_test_services
    build_and_push_images
    deploy_to_cloud_run
    setup_github_secrets
    test_deployed_services
    
    echo ""
    echo "🎉 Phase 0 Setup Complete!"
    echo "=========================="
    echo ""
    echo "✅ Infrastructure deployed"
    echo "✅ Backend services built and tested"
    echo "✅ Docker images pushed to Artifact Registry"
    echo "✅ Services deployed to Cloud Run"
    echo "✅ Health checks passed"
    echo ""
    echo "📋 Next steps:"
    echo "1. Configure GitHub secrets as shown above"
    echo "2. Push a commit to the main branch to trigger CI/CD"
    echo "3. Monitor the deployment in GitHub Actions"
    echo "4. Set up monitoring and alerting"
    echo ""
    echo "🔗 Useful links:"
    echo "  - Google Cloud Console: https://console.cloud.google.com/"
    echo "  - Cloud Run Services: https://console.cloud.google.com/run"
    echo "  - Artifact Registry: https://console.cloud.google.com/artifacts"
    echo "  - GitHub Actions: https://github.com/$GITHUB_REPO/actions"
    echo ""
}

# Run the script
main "$@"