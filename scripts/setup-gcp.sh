#!/bin/bash

# Bringee GCP Setup Script
# Dieses Skript hilft dir, Google Cloud für automatisches Deployment einzurichten
set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Bringee GCP Setup Script${NC}"
echo "=================================="

# Prüfe, ob gcloud installiert ist
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Google Cloud SDK ist nicht installiert. Bitte installiere es zuerst:${NC}"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Prüfe, ob terraform installiert ist
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform ist nicht installiert. Bitte installiere es zuerst:${NC}"
    echo "https://developer.hashicorp.com/terraform/downloads"
    exit 1
fi

# Prüfe, ob der Nutzer authentifiziert ist
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo -e "${YELLOW}⚠️  Du bist nicht bei Google Cloud authentifiziert. Bitte führe aus:${NC}"
    echo "gcloud auth login"
    exit 1
fi

# Projekt-Konfiguration abfragen (interaktiv oder per Argument)
if [ -z "$1" ]; then
    echo -e "${YELLOW}Bitte gib deine GCP Project ID ein:${NC}"
    read -p "GCP Project ID: " GCP_PROJECT_ID
else
    GCP_PROJECT_ID=$1
fi

read -p "GCP Region (default: europe-west3): " GCP_REGION
GCP_REGION=${GCP_REGION:-europe-west3}

read -p "GitHub Repository (format: owner/repo): " GITHUB_REPOSITORY

# terraform.tfvars erzeugen
cat > terraform/terraform.tfvars << EOF
gcp_project_id    = "${GCP_PROJECT_ID}"
gcp_region        = "${GCP_REGION}"
github_repository = "${GITHUB_REPOSITORY}"
environment       = "dev"
EOF

echo -e "${GREEN}✅ Konfiguration gespeichert: terraform/terraform.tfvars${NC}"

# Projekt setzen
echo -e "${YELLOW}🔧 Setze GCP Projekt...${NC}"
gcloud config set project $GCP_PROJECT_ID

# APIs aktivieren
echo -e "${YELLOW}🔧 Aktiviere benötigte APIs...${NC}"
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
    echo "Aktiviere $api..."
    gcloud services enable $api --project=$GCP_PROJECT_ID
    sleep 1
    done

echo -e "${GREEN}✅ Alle APIs aktiviert${NC}"

# Terraform State Bucket erstellen
BUCKET_NAME="bringee-terraform-state-${GCP_PROJECT_ID}"
echo -e "${YELLOW}🔧 Erstelle Terraform State Bucket...${NC}"
if gsutil ls -b "gs://${BUCKET_NAME}" &> /dev/null; then
    echo -e "${YELLOW}Bucket existiert bereits${NC}"
else
    gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" "gs://${BUCKET_NAME}"
    echo -e "${GREEN}✅ Terraform State Bucket erstellt: ${BUCKET_NAME}${NC}"
fi

# Terraform ausführen
echo -e "${YELLOW}🔧 Starte Terraform Deployment...${NC}"
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ..
echo -e "${GREEN}✅ Infrastruktur erfolgreich deployed${NC}"

# Terraform Outputs für GitHub Secrets
cd terraform
terraform output -json > ../terraform_output.json
cd ..
echo -e "${GREEN}✅ Terraform Outputs gespeichert: terraform_output.json${NC}"
echo -e "${YELLOW}Bitte füge folgende Secrets zu deinem GitHub Repository hinzu:${NC}"
echo -e "${GREEN}GCP_PROJECT_ID: ${GCP_PROJECT_ID}${NC}"
echo -e "${GREEN}GCP_REGION: ${GCP_REGION}${NC}"

echo -e "${GREEN}🎉 Setup abgeschlossen!${NC}"
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo -e "1. Füge die GitHub Secrets hinzu"
echo -e "2. Push dein Code auf den main-Branch"
echo -e "3. Beobachte das Deployment im GitHub Actions Workflow"
