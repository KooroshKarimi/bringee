# Bringee - Peer-to-Peer Logistikplattform

Bringee ist eine innovative Peer-to-Peer (P2P) Logistikplattform, die Privatpersonen (Absender) mit Reisenden (Transporteuren) verbindet, die freie Kapazitäten auf ihrer geplanten Route haben.

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

## 📱 Frontend Features

### Hauptbildschirm
- Willkommensnachricht und Plattformbeschreibung
- Schnellzugriff auf Sendungserstellung und Transportangebote
- Übersicht über aktuelle Sendungen

### Sendungserstellung
- Vollständiges Formular für Empfängerdetails
- Sendungsbeschreibung und Wertangabe
- Validierung aller Eingabefelder

### Sendungsverwaltung
- Liste aller eigenen Sendungen
- Status-Tracking (In Bearbeitung, In Transit, Zugestellt)
- Preis- und Datumsanzeige

### Chat-System
- Übersicht über alle Konversationen
- Ungelesene Nachrichten-Anzeige
- Zeitstempel für jede Nachricht

### Benutzerprofil
- Persönliche Informationen
- Verifizierungsstatus
- Bewertungen und abgeschlossene Sendungen
- Einstellungen und Support

## 🔧 Backend Features

### User Service (`/api/v1/users`)
- **GET /api/v1/users** - Liste aller Benutzer
- **GET /api/v1/users/{id}** - Benutzerdetails
- **PUT /api/v1/users/{id}** - Benutzer aktualisieren
- **POST /api/v1/auth/login** - Anmeldung
- **POST /api/v1/auth/register** - Registrierung
- **POST /api/v1/auth/verify** - Token-Verifizierung

### Shipment Service (`/api/v1/shipments`)
- **GET /api/v1/shipments** - Liste aller Sendungen
- **GET /api/v1/shipments/{id}** - Sendungsdetails mit Status-Historie
- **POST /api/v1/shipments** - Neue Sendung erstellen
- **PUT /api/v1/shipments/{id}/accept** - Sendung annehmen
- **PUT /api/v1/shipments/{id}/status** - Status aktualisieren

## � Schnellstart

### Frontend starten
```bash
cd frontend/bringee_app
flutter pub get
flutter run
```

### Backend Services starten

#### User Service
```bash
cd backend/services/user-service
go run main.go
```
Service läuft auf: http://localhost:8080

#### Shipment Service
```bash
cd backend/services/shipment-service
go run main.go
```
Service läuft auf: http://localhost:8080

## 📊 Demo-Daten

Die Anwendung enthält Demo-Daten für sofortige Nutzung:

### Benutzer
- **Max Mustermann** (max.mustermann@email.com) - Verifiziert, 4.8/5 Sterne
- **Anna Schmidt** (anna.schmidt@email.com) - Verifiziert, 4.9/5 Sterne

### Sendungen
- **Laptop nach Berlin** - Status: In Bearbeitung, €45
- **Dokumente nach München** - Status: Zugestellt, €25
- **Paket nach Hamburg** - Status: In Transit, €35

## � API Endpoints

### User Service
```
GET    /health                    - Service-Status
GET    /api/v1/users             - Alle Benutzer
GET    /api/v1/users/{id}        - Benutzerdetails
PUT    /api/v1/users/{id}        - Benutzer aktualisieren
POST   /api/v1/auth/login        - Anmeldung
POST   /api/v1/auth/register     - Registrierung
POST   /api/v1/auth/verify       - Token verifizieren
```

### Shipment Service
```
GET    /health                    - Service-Status
GET    /api/v1/shipments         - Alle Sendungen
GET    /api/v1/shipments/{id}    - Sendungsdetails
POST   /api/v1/shipments         - Neue Sendung
PUT    /api/v1/shipments/{id}/accept - Sendung annehmen
PUT    /api/v1/shipments/{id}/status - Status aktualisieren
```

## 🎯 Nächste Schritte

Die Anwendung ist jetzt bereit für die nächsten Entwicklungsphasen:

1. **Datenbank-Integration** - PostgreSQL und Firestore
2. **Authentifizierung** - Firebase Auth Integration
3. **Zahlungsabwicklung** - Stripe Connect
4. **Push-Benachrichtigungen** - Firebase Cloud Messaging
5. **Zoll- und Steuerabwicklung** - Drittanbieter-APIs
6. **KI-Funktionen** - Dynamische Preisgestaltung und Betrugserkennung

## 📝 Technische Details

- **Frontend**: Flutter mit Material Design
- **Backend**: Go mit HTTP-Server
- **Architektur**: Microservices mit REST APIs
- **Daten**: In-Memory Storage (Demo-Zwecke)
- **API**: JSON-basiert mit Standard HTTP-Statuscodes

## 🤝 Beitragen

Die Anwendung ist in aktiver Entwicklung. Feedback und Beiträge sind willkommen!

---

**Bringee** - Sichere und kostengünstige Peer-to-Peer Logistik
