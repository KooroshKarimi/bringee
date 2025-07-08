# Bringee - Automatische Deployment Pipeline

Dieses Repository enthält eine vollständige CI/CD-Pipeline für das Bringee-Projekt mit automatischem Deployment zu Google Cloud Platform.

## 🚀 Schnellstart

### Automatische Einrichtung
```bash
chmod +x setup-gcp-deployment.sh
./setup-gcp-deployment.sh
```

### Manuelle Einrichtung
Siehe [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) für detaillierte Anweisungen.

## 📁 Projektstruktur

- **`.github/workflows/`** - GitHub Actions CI/CD Pipeline
- **`terraform/`** - Infrastructure as Code für GCP
- **`backend/services/`** - Microservices (Go)
- **`frontend/`** - Frontend-Anwendung
- **`flutter/`** - Mobile App

## 🔄 Workflow

1. **Push zu main branch** → Trigger GitHub Actions
2. **Tests** → Automatische Tests aller Services
3. **Build** → Docker Images erstellen
4. **Push** → Images zu Google Artifact Registry
5. **Deploy** → Automatisches Deployment zu Cloud Run

## 📊 Services

- **User Service** - Benutzerverwaltung
- **Shipment Service** - Lieferungsverwaltung

## 🔧 Konfiguration

Alle Konfigurationen finden Sie in:
- `terraform/` - Infrastructure
- `.github/workflows/ci-cd.yml` - CI/CD Pipeline
- `DEPLOYMENT_GUIDE.md` - Detaillierte Anleitung

## 📞 Support

Bei Fragen oder Problemen siehe [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) oder erstellen Sie ein Issue.