# Bringee - Peer-to-Peer Logistik Plattform

## Überblick

Bringee ist eine innovative Peer-to-Peer (P2P) Logistikplattform, die Privatpersonen (Absender) mit Reisenden (Transporteuren) verbindet, die freie Kapazitäten auf ihrer geplanten Route haben. Die Plattform bietet eine kostengünstige und flexible Alternative zu traditionellen Logistikdienstleistern.

## 🚀 Was ist neu?

Die Anwendung wurde von einfachen "Hello World" Texten zu einer vollständigen Plattform weiterentwickelt:

### Frontend (Flutter App)
- **Hauptnavigation** mit 4 Bereichen: Start, Sendungen, Chat, Profil
- **Sendungserstellung** mit detailliertem Formular
- **Verfügbare Sendungen** für Transporteure
- **Benutzerprofile** mit Bewertungen und Verifizierung
- **Chat-System** für Kommunikation zwischen Nutzern
- **Moderne UI** mit Material Design

### Backend Services
- **User Service** mit Authentifizierung und Benutzerverwaltung
- **Shipment Service** mit Sendungsverwaltung und Status-Tracking
- **RESTful APIs** für alle Kernfunktionen
- **Demo-Daten** für sofortige Nutzung

## Aktueller Status

Die Anwendung wurde von einer einfachen "Hello World" Implementierung zu einer vollständigen Plattform erweitert:

### ✅ Implementiert
- **Flutter Mobile App** mit vollständiger Navigation
  - Startseite mit Schnellaktionen
  - Sendungsverwaltung
  - Chat-System
  - Benutzerprofil
- **Backend Services** mit realistischen APIs
  - User Service mit Benutzerverwaltung
  - Shipment Service mit Sendungsverwaltung
  - Chat-Funktionalität
  - Status-Tracking

### 🚧 In Entwicklung
- Vollständige Backend-Integration
- Datenbank-Anbindung
- Authentifizierung
- Zahlungsabwicklung

## Technologie-Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programmiersprache
- **Material Design** - UI/UX Framework

### Backend
- **Go** - Programmiersprache
- **Google Cloud Platform** - Cloud Infrastructure
- **Microservices Architecture** - Service-basierte Architektur

## Schnellstart

### Frontend (Flutter App)

1. **Flutter installieren** (falls noch nicht geschehen):
   ```bash
   # Flutter SDK herunterladen und installieren
   # Siehe: https://flutter.dev/docs/get-started/install
   ```

2. **In das Frontend-Verzeichnis wechseln**:
   ```bash
   cd frontend/bringee_app
   ```

3. **Abhängigkeiten installieren**:
   ```bash
   flutter pub get
   ```

4. **App starten**:
   ```bash
   # Für Web (empfohlen für schnelles Testen)
   flutter run -d chrome
   
   # Für Android
   flutter run -d android
   
   # Für iOS
   flutter run -d ios
   ```

### Backend Services

1. **Go installieren** (falls noch nicht geschehen):
   ```bash
   # Go SDK herunterladen und installieren
   # Siehe: https://golang.org/doc/install
   ```

2. **User Service starten**:
   ```bash
   cd backend/services/user-service
   go run main.go
   ```
   Der Service läuft dann auf `http://localhost:8080`

3. **Shipment Service starten** (in einem neuen Terminal):
   ```bash
   cd backend/services/shipment-service
   go run main.go
   ```
   Der Service läuft dann auf `http://localhost:8080` (anderer Port möglich)

## API Endpoints

### User Service (`http://localhost:8080`)
- `GET /` - Service-Informationen
- `GET /health` - Health Check
- `GET /api/v1/users` - Benutzer auflisten
- `POST /api/v1/users` - Benutzer erstellen
- `GET /api/v1/shipments` - Sendungen auflisten
- `POST /api/v1/shipments` - Sendung erstellen
- `GET /api/v1/chat` - Chat-Nachrichten abrufen
- `POST /api/v1/chat` - Nachricht senden

### Shipment Service (`http://localhost:8080`)
- `GET /` - Service-Informationen
- `GET /health` - Health Check
- `GET /api/v1/shipments` - Sendungen auflisten
- `POST /api/v1/shipments` - Sendung erstellen
- `GET /api/v1/shipments/{id}` - Sendungsdetails
- `GET /api/v1/bids` - Gebote auflisten
- `POST /api/v1/bids` - Gebot erstellen
- `GET /api/v1/status` - Status-Historie
- `POST /api/v1/status` - Status aktualisieren

## App-Features

### 📱 Mobile App
- **Startseite**: Übersicht und Schnellaktionen
- **Sendungen**: Verwaltung eigener Sendungen
- **Chat**: Kommunikation zwischen Absendern und Transporteuren
- **Profil**: Benutzerprofil und Einstellungen

### 🔧 Backend Services
- **Benutzerverwaltung**: Registrierung, Authentifizierung, Profile
- **Sendungsverwaltung**: Erstellung, Tracking, Status-Updates
- **Chat-System**: Echtzeit-Kommunikation
- **Gebotssystem**: Transporteure können auf Sendungen bieten

## Entwicklung

### Projektstruktur
```
bringee/
├── frontend/
│   └── bringee_app/          # Flutter App
│       ├── lib/
│       │   └── main.dart     # Hauptanwendung
│       └── pubspec.yaml      # Dependencies
├── backend/
│   └── services/
│       ├── user-service/      # Benutzer-Service
│       └── shipment-service/  # Sendungs-Service
└── terraform/                # Infrastructure as Code
```

### Nächste Schritte
1. **Datenbank-Integration**: PostgreSQL und Firestore Setup
2. **Authentifizierung**: Firebase Auth Integration
3. **Zahlungsabwicklung**: Stripe Integration
4. **Deployment**: Google Cloud Platform Setup
5. **Testing**: Unit, Integration und E2E Tests

## Kontakt

Für Fragen oder Unterstützung bei der Entwicklung der Bringee-Plattform.

---

**Hinweis**: Dies ist eine Entwicklungsversion. Die Produktionsversion wird zusätzliche Sicherheitsfeatures, Datenbank-Integration und vollständige Backend-Funktionalität enthalten.
