# Bringee Testing Guide

## Überblick

Diese Anleitung erklärt, wie Sie die Bringee-Anwendung testen können, nachdem sie von einer einfachen "Hello World" Implementierung zu einer vollständigen Plattform erweitert wurde.

## 🚀 Schnelltest

### 1. Flutter App testen

#### Web-Version (Empfohlen für schnelles Testen)
```bash
cd frontend/bringee_app
flutter pub get
flutter run -d chrome
```

Die App öffnet sich im Browser und Sie können:
- **Navigation testen**: Zwischen den 4 Hauptbereichen wechseln
- **Startseite**: Schnellaktionen und letzte Aktivitäten anzeigen
- **Sendungen**: Liste der Sendungen mit verschiedenen Status
- **Chat**: Chat-Übersicht mit Nachrichten
- **Profil**: Benutzerprofil mit Bewertungen und Einstellungen

#### Mobile Version
```bash
# Für Android
flutter run -d android

# Für iOS (nur auf macOS)
flutter run -d ios
```

### 2. Backend Services testen

#### User Service starten
```bash
cd backend/services/user-service
go run main.go
```

#### API-Endpoints testen
```bash
# Service-Informationen
curl http://localhost:8080/

# Health Check
curl http://localhost:8080/health

# Benutzer auflisten
curl http://localhost:8080/api/v1/users

# Sendungen auflisten
curl http://localhost:8080/api/v1/shipments

# Chat-Nachrichten
curl http://localhost:8080/api/v1/chat
```

#### Shipment Service starten (in neuem Terminal)
```bash
cd backend/services/shipment-service
go run main.go
```

#### Shipment API testen
```bash
# Service-Informationen
curl http://localhost:8080/

# Sendungen mit Details
curl http://localhost:8080/api/v1/shipments

# Gebote auflisten
curl http://localhost:8080/api/v1/bids

# Status-Historie
curl http://localhost:8080/api/v1/status
```

## 📱 App-Features zum Testen

### Startseite
- ✅ **Willkommensnachricht** anzeigen
- ✅ **Schnellaktionen** (Sendung erstellen, Sendungen finden)
- ✅ **Letzte Aktivitäten** mit Status-Badges
- ✅ **Benachrichtigungen** Button

### Sendungen
- ✅ **Sendungsliste** mit verschiedenen Status
- ✅ **Filter-Button** (zeigt Snackbar)
- ✅ **Floating Action Button** für neue Sendung
- ✅ **Sendungsdetails** (ID, Route, Preis, Datum)

### Chat
- ✅ **Chat-Übersicht** mit Benutzernamen
- ✅ **Letzte Nachrichten** anzeigen
- ✅ **Zeitstempel** und **Ungelesen-Badge**
- ✅ **Avatar** mit Initialen

### Profil
- ✅ **Benutzeravatar** mit Initialen
- ✅ **Benutzerinformationen** (Name, Email)
- ✅ **Verifizierungsstatus** mit grünem Check
- ✅ **Bewertung** mit Sternen
- ✅ **Sendungsstatistik**
- ✅ **Einstellungen-Menü**

## 🔧 Backend-Features zum Testen

### User Service
- ✅ **Service-Informationen** mit Endpoints
- ✅ **Health Check** mit Timestamp
- ✅ **Mock-Benutzerdaten** (GET /api/v1/users)
- ✅ **Benutzer-Erstellung** (POST /api/v1/users)
- ✅ **Mock-Sendungsdaten** (GET /api/v1/shipments)
- ✅ **Chat-Nachrichten** (GET /api/v1/chat)

### Shipment Service
- ✅ **Service-Informationen** mit Endpoints
- ✅ **Health Check** mit Version
- ✅ **Detaillierte Sendungsdaten** mit Gewicht und Dimensionen
- ✅ **Gebotssystem** (GET /api/v1/bids)
- ✅ **Status-Historie** (GET /api/v1/status)
- ✅ **Sendungsdetails** (GET /api/v1/shipments/{id})

## 🧪 Erweiterte Tests

### API-Tests mit curl

#### Neue Sendung erstellen
```bash
curl -X POST http://localhost:8080/api/v1/shipments \
  -H "Content-Type: application/json" \
  -d '{
    "from": "Hamburg",
    "to": "Berlin",
    "price": 35.00,
    "description": "Test-Sendung"
  }'
```

#### Neuen Benutzer erstellen
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "Test User"
  }'
```

#### Chat-Nachricht senden
```bash
curl -X POST http://localhost:8080/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sender_id": "user-001",
    "receiver_id": "user-002",
    "message": "Test-Nachricht"
  }'
```

### Browser-Tests

#### Flutter Web App
1. Öffnen Sie `http://localhost:8080` im Browser
2. Testen Sie die Navigation zwischen allen Bereichen
3. Klicken Sie auf alle interaktiven Elemente
4. Testen Sie die Responsive Darstellung

#### API-Dokumentation
- Öffnen Sie `http://localhost:8080/` für Service-Informationen
- Testen Sie alle aufgelisteten Endpoints

## 🐛 Bekannte Probleme

### Flutter Web
- **Hot Reload**: Funktioniert normalerweise gut
- **Performance**: Kann bei ersten Ladezeiten langsam sein
- **Browser-Kompatibilität**: Chrome empfohlen

### Backend Services
- **Port-Konflikte**: Beide Services laufen standardmäßig auf Port 8080
- **Lösung**: Ändern Sie den Port für einen Service
  ```bash
  PORT=8081 go run main.go
  ```

## 📊 Test-Ergebnisse

### ✅ Funktioniert
- Vollständige Flutter App mit Navigation
- Realistische Backend APIs
- Mock-Daten für alle Features
- Responsive UI-Design
- Service Health Checks

### 🚧 In Entwicklung
- Echte Datenbank-Integration
- Authentifizierung
- Echtzeit-Chat
- Push-Benachrichtigungen
- Zahlungsabwicklung

## 🎯 Nächste Test-Schritte

1. **Integration Tests**: Verbindung zwischen Frontend und Backend
2. **E2E Tests**: Vollständige Benutzer-Workflows
3. **Performance Tests**: Ladezeiten und Skalierung
4. **Security Tests**: API-Sicherheit und Authentifizierung
5. **Mobile Tests**: iOS und Android spezifische Features

---

**Hinweis**: Dies ist eine Entwicklungsversion. Für Produktions-Tests werden zusätzliche Sicherheits- und Performance-Tests erforderlich sein.