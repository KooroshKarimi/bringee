# Bringee

Ein modernes Lieferdienst-System mit automatischer CI/CD-Pipeline.

## 🚀 Schnellstart

### Automatisches Deployment einrichten

```bash
# Setup-Skript ausführen
./scripts/setup-gcp.sh

# GitHub Secrets konfigurieren (siehe DEPLOYMENT.md)

# Code pushen
git add .
git commit -m "Setup automatic deployment"
git push origin main
```

## 📁 Projektstruktur

```
bringee/
├── backend/services/     # Go Backend-Services
│   ├── user-service/    # Benutzer-Management
│   └── shipment-service/ # Lieferungs-Management
├── frontend/            # React Frontend
├── flutter/             # Mobile App
├── terraform/           # Infrastructure as Code
├── .github/workflows/   # CI/CD Pipeline
└── scripts/            # Setup-Skripts
```

## 🔧 Technologie-Stack

- **Backend:** Go (Microservices)
- **Frontend:** React
- **Mobile:** Flutter
- **Infrastructure:** Terraform + Google Cloud
- **CI/CD:** GitHub Actions
- **Container:** Docker + Cloud Run

## 📚 Dokumentation

- [Deployment-Anleitung](DEPLOYMENT.md) - Automatische Deployment-Konfiguration
- [Spezifikation](Spezifikation.md) - Detaillierte System-Spezifikation
- [Todo](Todo.md) - Aktuelle Aufgaben und Features

## 🏗️ Architektur

Das System verwendet eine moderne Microservices-Architektur:

- **User Service:** Benutzer-Management und Authentifizierung
- **Shipment Service:** Lieferungs-Management und Tracking
- **Frontend:** React-basierte Web-Anwendung
- **Mobile App:** Flutter-basierte iOS/Android App

## 🔐 Sicherheit

- Workload Identity Federation für sichere GCP-Authentifizierung
- Service Accounts mit minimalen Berechtigungen
- Automatische Token-Rotation
- Keine statischen Credentials im Code

## 📈 Skalierung

- **Cloud Run:** Automatische Skalierung (0-10 Instanzen)
- **Pay-per-use:** Kostenoptimiert für Startups
- **Global:** Multi-Region Deployment möglich

## 🚀 Deployment

Nach dem Setup wird bei jedem Push auf den `main` Branch automatisch:

1. **Tests** ausgeführt
2. **Docker-Images** erstellt
3. **Services** zu Cloud Run deployed

## 📞 Support

Bei Fragen oder Problemen:
1. Prüfen Sie die [Deployment-Anleitung](DEPLOYMENT.md)
2. Schauen Sie in die GitHub Actions Logs
3. Überprüfen Sie die Cloud Run Logs

## 🎯 Features

- ✅ Automatische CI/CD-Pipeline
- ✅ Infrastructure as Code
- ✅ Sichere Authentifizierung
- ✅ Kostenoptimierte Skalierung
- ✅ Multi-Service Architektur
- ✅ Mobile & Web Support
