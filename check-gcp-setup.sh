#!/bin/bash

# Bringee GCP Setup Checker
# Prüft, ob alles für das GCP Deployment bereit ist

set -e

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Bringee GCP Setup Checker${NC}"
echo "=================================="

# Prüfe Git Repository
echo -e "${YELLOW}📋 Prüfe Git Repository...${NC}"
if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Git Repository gefunden${NC}"
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -n "$REMOTE_URL" ]; then
        echo -e "${GREEN}✅ Remote URL: $REMOTE_URL${NC}"
    else
        echo -e "${RED}❌ Keine Remote URL gefunden${NC}"
        echo "   Führe aus: git remote add origin https://github.com/DEIN_USERNAME/DEIN_REPO.git"
    fi
else
    echo -e "${RED}❌ Kein Git Repository gefunden${NC}"
    echo "   Führe aus: git init && git add . && git commit -m 'Initial commit'"
fi

# Prüfe GitHub Actions Workflow
echo -e "\n${YELLOW}📋 Prüfe GitHub Actions Workflow...${NC}"
if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo -e "${GREEN}✅ GitHub Actions Workflow gefunden${NC}"
else
    echo -e "${RED}❌ GitHub Actions Workflow nicht gefunden${NC}"
fi

# Prüfe Backend Services
echo -e "\n${YELLOW}📋 Prüfe Backend Services...${NC}"
if [ -f "backend/services/user-service/main.go" ]; then
    echo -e "${GREEN}✅ User Service gefunden${NC}"
else
    echo -e "${RED}❌ User Service nicht gefunden${NC}"
fi

if [ -f "backend/services/shipment-service/main.go" ]; then
    echo -e "${GREEN}✅ Shipment Service gefunden${NC}"
else
    echo -e "${RED}❌ Shipment Service nicht gefunden${NC}"
fi

# Prüfe Dockerfiles
echo -e "\n${YELLOW}📋 Prüfe Dockerfiles...${NC}"
if [ -f "backend/services/user-service/Dockerfile" ]; then
    echo -e "${GREEN}✅ User Service Dockerfile gefunden${NC}"
else
    echo -e "${RED}❌ User Service Dockerfile nicht gefunden${NC}"
fi

if [ -f "backend/services/shipment-service/Dockerfile" ]; then
    echo -e "${GREEN}✅ Shipment Service Dockerfile gefunden${NC}"
else
    echo -e "${RED}❌ Shipment Service Dockerfile nicht gefunden${NC}"
fi

# Prüfe Frontend
echo -e "\n${YELLOW}📋 Prüfe Frontend...${NC}"
if [ -f "frontend/bringee_app/pubspec.yaml" ]; then
    echo -e "${GREEN}✅ Flutter App gefunden${NC}"
else
    echo -e "${RED}❌ Flutter App nicht gefunden${NC}"
fi

# Anleitung für GitHub Secrets
echo -e "\n${BLUE}📋 GitHub Secrets Checklist${NC}"
echo "=================================="
echo -e "${YELLOW}Füge diese Secrets zu deinem GitHub Repository hinzu:${NC}"
echo -e "${GREEN}Settings → Secrets and variables → Actions${NC}"
echo ""
echo -e "${BLUE}Benötigte Secrets:${NC}"
echo -e "1. ${GREEN}GCP_PROJECT_ID${NC} - Deine Google Cloud Project ID"
echo -e "2. ${GREEN}GCP_PROJECT_NUMBER${NC} - Deine Google Cloud Project Number"
echo -e "3. ${GREEN}GCP_SA_KEY${NC} - Service Account JSON Key"
echo ""

# Anleitung für Google Cloud Setup
echo -e "${BLUE}📋 Google Cloud Setup Checklist${NC}"
echo "=================================="
echo -e "${YELLOW}1. Google Cloud Projekt erstellen${NC}"
echo "   - Gehe zu: https://console.cloud.google.com/"
echo "   - Erstelle ein neues Projekt"
echo "   - Notiere die Project ID"
echo ""
echo -e "${YELLOW}2. Service Account erstellen${NC}"
echo "   - IAM & Admin → Service Accounts"
echo "   - Name: github-actions-runner"
echo "   - Berechtigungen: Cloud Run Admin, Service Account User, Storage Admin, Artifact Registry Admin"
echo ""
echo -e "${YELLOW}3. Service Account Key erstellen${NC}"
echo "   - Klicke auf den Service Account"
echo "   - Keys → Add Key → Create new key (JSON)"
echo "   - Lade die JSON-Datei herunter"
echo ""
echo -e "${YELLOW}4. APIs aktivieren${NC}"
echo "   - APIs & Services → Library"
echo "   - Aktiviere: Cloud Run API, Artifact Registry API, Cloud Build API"
echo ""

# Deployment Anleitung
echo -e "${BLUE}📋 Deployment Anleitung${NC}"
echo "=================================="
echo -e "${YELLOW}Nach dem Setup:${NC}"
echo "1. Füge die GitHub Secrets hinzu"
echo "2. Führe aus: git push origin main"
echo "3. Überwache das Deployment in GitHub Actions"
echo "4. Finde die URLs in Google Cloud Console → Cloud Run"
echo ""

echo -e "${GREEN}🎉 Setup Check abgeschlossen!${NC}"
echo -e "${YELLOW}Folge der Anleitung in SIMPLE_GCP_SETUP.md für das vollständige Setup.${NC}"