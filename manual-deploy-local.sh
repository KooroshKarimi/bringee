#!/bin/bash

# Manuelles Deployment Skript für lokale Umgebung
# Führen Sie dieses Skript aus, um das Projekt auf Google Cloud zu deployen

set -e

echo "🚀 Manuelles Deployment - Bringee"
echo "================================="

# Konfiguration
GCP_PROJECT_ID=${GCP_PROJECT_ID:-"bringee-project"}
GCP_REGION=${GCP_REGION:-"europe-west3"}

echo "Konfiguration:"
echo "  GCP Project ID: $GCP_PROJECT_ID"
echo "  GCP Region: $GCP_REGION"
echo ""

# Überprüfe gcloud
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI ist nicht installiert"
    echo "Installieren Sie es: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Überprüfe Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform ist nicht installiert"
    echo "Installieren Sie es: https://developer.hashicorp.com/terraform/downloads"
    exit 1
fi

echo "✅ Alle Tools sind installiert"
echo ""

# Authentifizierung
echo "🔐 Authentifizierung..."
echo "Bitte authentifizieren Sie sich bei Google Cloud:"
gcloud auth login

echo "Setze Projekt auf $GCP_PROJECT_ID..."
gcloud config set project "$GCP_PROJECT_ID"

# Überprüfe ob das Projekt existiert
if ! gcloud projects describe "$GCP_PROJECT_ID" >/dev/null 2>&1; then
    echo "❌ Projekt $GCP_PROJECT_ID existiert nicht"
    echo "Bitte erstellen Sie das Projekt zuerst in der Google Cloud Console"
    echo "Oder ändern Sie GCP_PROJECT_ID in eine existierende Projekt-ID"
    exit 1
fi

echo "✅ Projekt $GCP_PROJECT_ID gefunden"
echo ""

# Terraform Deployment
echo "🏗️  Terraform Deployment..."
cd terraform

# Erstelle terraform.tfvars falls nicht vorhanden
if [ ! -f "terraform.tfvars" ]; then
    echo "Erstelle terraform.tfvars..."
    cat > terraform.tfvars << EOF
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
github_repository = "your-username/bringee"
environment       = "dev"
EOF
fi

echo "Initialisiere Terraform..."
terraform init

echo "Plane Terraform Deployment..."
terraform plan -out=tfplan

echo "Wende Terraform Konfiguration an..."
terraform apply tfplan

cd ..

echo "✅ Terraform Deployment abgeschlossen"
echo ""

# Docker Build und Push
echo "🐳 Docker Build und Push..."

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

echo "✅ Docker Images gebaut und gepusht"
echo ""

# Cloud Run Deployment
echo "☁️  Cloud Run Deployment..."

echo "Deploye user-service..."
gcloud run deploy user-service \
    --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/user-service:latest \
    --region $GCP_REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10

echo "Deploye shipment-service..."
gcloud run deploy shipment-service \
    --image europe-west3-docker.pkg.dev/$GCP_PROJECT_ID/bringee-artifacts/shipment-service:latest \
    --region $GCP_REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10

echo ""
echo "🎉 Deployment abgeschlossen!"
echo "=========================="
echo ""
echo "Ihre Services sind jetzt deployed:"
echo "• User Service: https://user-service-xxxxx-$GCP_REGION.run.app"
echo "• Shipment Service: https://shipment-service-xxxxx-$GCP_REGION.run.app"
echo ""
echo "Um die URLs zu finden, führen Sie aus:"
echo "gcloud run services list --region=$GCP_REGION"