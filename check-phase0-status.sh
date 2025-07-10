#!/bin/bash

# Phase 0 Status Check Script
# Überprüft, ob alle Phase 0 Services auf Google Cloud laufen

set -e

echo "🔍 Phase 0 Status Check - Bringee Projekt"
echo "=========================================="

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Überprüfe GCP Projekt Konfiguration
echo ""
echo "📋 1. Google Cloud Projekt Konfiguration"
echo "----------------------------------------"

# Überprüfe ob gcloud installiert ist
if command -v gcloud &> /dev/null; then
    print_status 0 "gcloud CLI ist installiert"
    
    # Überprüfe aktuelle Konfiguration
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "Nicht konfiguriert")
    print_info "Aktuelles Projekt: $CURRENT_PROJECT"
    
    # Überprüfe ob authentifiziert
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_status 0 "Authentifizierung aktiv"
        ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)
        print_info "Aktiver Account: $ACTIVE_ACCOUNT"
    else
        print_status 1 "Keine aktive Authentifizierung"
        print_warning "Führen Sie 'gcloud auth login' aus"
    fi
else
    print_status 1 "gcloud CLI ist nicht installiert"
    print_warning "Installieren Sie gcloud CLI: https://cloud.google.com/sdk/docs/install"
fi

# 2. Überprüfe Terraform State
echo ""
echo "🏗️  2. Terraform Infrastruktur"
echo "-------------------------------"

# Überprüfe Terraform Dateien
if [ -f "terraform/main.tf" ]; then
    print_status 0 "Terraform Konfiguration vorhanden"
else
    print_status 1 "Terraform Konfiguration fehlt"
fi

if [ -f "terraform/cloud-run.tf" ]; then
    print_status 0 "Cloud Run Konfiguration vorhanden"
else
    print_status 1 "Cloud Run Konfiguration fehlt"
fi

# 3. Überprüfe Backend Services
echo ""
echo "🔧 3. Backend Services"
echo "----------------------"

# Überprüfe user-service
if [ -f "backend/services/user-service/main.go" ]; then
    print_status 0 "user-service Code vorhanden"
else
    print_status 1 "user-service Code fehlt"
fi

if [ -f "backend/services/user-service/Dockerfile" ]; then
    print_status 0 "user-service Dockerfile vorhanden"
else
    print_status 1 "user-service Dockerfile fehlt"
fi

# Überprüfe shipment-service
if [ -f "backend/services/shipment-service/main.go" ]; then
    print_status 0 "shipment-service Code vorhanden"
else
    print_status 1 "shipment-service Code fehlt"
fi

if [ -f "backend/services/shipment-service/Dockerfile" ]; then
    print_status 0 "shipment-service Dockerfile vorhanden"
else
    print_status 1 "shipment-service Dockerfile fehlt"
fi

# 4. Überprüfe GitHub Actions
echo ""
echo "🚀 4. GitHub Actions CI/CD"
echo "---------------------------"

if [ -f ".github/workflows/ci-cd.yml" ]; then
    print_status 0 "CI/CD Workflow vorhanden"
else
    print_status 1 "CI/CD Workflow fehlt"
fi

# 5. Überprüfe Cloud Run Services (falls gcloud verfügbar)
echo ""
echo "☁️  5. Cloud Run Services Status"
echo "--------------------------------"

if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    # Überprüfe user-service
    if gcloud run services describe user-service --region=europe-west3 --format="value(status.url)" &>/dev/null; then
        USER_SERVICE_URL=$(gcloud run services describe user-service --region=europe-west3 --format="value(status.url)")
        print_status 0 "user-service läuft"
        print_info "URL: $USER_SERVICE_URL"
        
        # Teste Service
        if curl -s "$USER_SERVICE_URL" &>/dev/null; then
            print_status 0 "user-service ist erreichbar"
        else
            print_status 1 "user-service ist nicht erreichbar"
        fi
    else
        print_status 1 "user-service läuft nicht"
    fi
    
    # Überprüfe shipment-service
    if gcloud run services describe shipment-service --region=europe-west3 --format="value(status.url)" &>/dev/null; then
        SHIPMENT_SERVICE_URL=$(gcloud run services describe shipment-service --region=europe-west3 --format="value(status.url)")
        print_status 0 "shipment-service läuft"
        print_info "URL: $SHIPMENT_SERVICE_URL"
        
        # Teste Service
        if curl -s "$SHIPMENT_SERVICE_URL" &>/dev/null; then
            print_status 0 "shipment-service ist erreichbar"
        else
            print_status 1 "shipment-service ist nicht erreichbar"
        fi
    else
        print_status 1 "shipment-service läuft nicht"
    fi
else
    print_warning "gcloud nicht verfügbar oder nicht authentifiziert - Cloud Run Status kann nicht überprüft werden"
fi

# 6. Überprüfe Artifact Registry
echo ""
echo "📦 6. Artifact Registry"
echo "-----------------------"

if command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    if gcloud artifacts repositories describe bringee-artifacts --location=europe-west3 &>/dev/null; then
        print_status 0 "Artifact Registry 'bringee-artifacts' vorhanden"
        
        # Überprüfe Docker Images
        USER_IMAGES=$(gcloud artifacts docker images list europe-west3-docker.pkg.dev/$(gcloud config get-value project)/bringee-artifacts/user-service --limit=1 2>/dev/null | wc -l)
        if [ $USER_IMAGES -gt 1 ]; then
            print_status 0 "user-service Docker Images vorhanden"
        else
            print_status 1 "user-service Docker Images fehlen"
        fi
        
        SHIPMENT_IMAGES=$(gcloud artifacts docker images list europe-west3-docker.pkg.dev/$(gcloud config get-value project)/bringee-artifacts/shipment-service --limit=1 2>/dev/null | wc -l)
        if [ $SHIPMENT_IMAGES -gt 1 ]; then
            print_status 0 "shipment-service Docker Images vorhanden"
        else
            print_status 1 "shipment-service Docker Images fehlen"
        fi
    else
        print_status 1 "Artifact Registry 'bringee-artifacts' fehlt"
    fi
else
    print_warning "gcloud nicht verfügbar oder nicht authentifiziert - Artifact Registry Status kann nicht überprüft werden"
fi

# 7. Zusammenfassung
echo ""
echo "📊 Zusammenfassung"
echo "=================="

print_info "Phase 0 Status Check abgeschlossen"
print_info "Für detaillierte Informationen siehe: PHASE_0_STATUS.md"

echo ""
echo "🚀 Nächste Schritte:"
echo "1. Stellen Sie sicher, dass alle GitHub Secrets konfiguriert sind"
echo "2. Pushen Sie einen Commit zum main Branch, um das Deployment zu triggern"
echo "3. Überprüfen Sie die GitHub Actions Logs für Details"
echo "4. Für manuelle Deployment: ./deploy-to-gcp.sh"

echo ""
echo "📚 Nützliche Dokumentation:"
echo "- PHASE_0_STATUS.md - Detaillierter Status"
echo "- GITHUB_SECRETS_SETUP.md - GitHub Secrets Konfiguration"
echo "- MANUAL_GCP_SETUP.md - Manuelle GCP Einrichtung"
echo "- QUICK_GCP_SETUP.md - Schnelle GCP Einrichtung"