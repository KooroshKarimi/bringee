# Bringee Testing Guide

## Überblick

Diese Anleitung erklärt, wie Sie die Bringee-Anwendung testen können, nachdem sie von einer einfachen "Hello World" Implementierung zu einer vollständigen Plattform erweitert wurde.

## 🚀 Schnelltest

### 1. Backend Services starten

Öffnen Sie zwei Terminal-Fenster und starten Sie die Services:

**Terminal 1 - User Service:**
```bash
cd backend/services/user-service
go run main.go
```

**Terminal 2 - Shipment Service:**
```bash
cd backend/services/shipment-service
go run main.go
```

### 2. Frontend starten

**Terminal 3 - Flutter App:**
```bash
cd frontend/bringee_app
flutter pub get
flutter run
```

## 📱 Frontend Testing

### Hauptbildschirm testen
1. **Willkommensnachricht** - Sollte "Willkommen bei Bringee" anzeigen
2. **Aktionskarten** - "Sendung erstellen" und "Transport anbieten" sollten funktionieren
3. **Aktuelle Sendungen** - Demo-Sendungen sollten angezeigt werden

### Sendungserstellung testen
1. Klicken Sie auf "Sendung erstellen"
2. Füllen Sie das Formular aus:
   - **Empfänger-Name:** "Test Empfänger"
   - **Adresse:** "Teststraße 123, 12345 Teststadt"
   - **Telefon:** "+49123456789"
   - **Beschreibung:** "Test-Paket"
   - **Wert:** "100"
3. Klicken Sie "Sendung erstellen"
4. **Erwartung:** Erfolgsmeldung und Rückkehr zum Hauptbildschirm

### Verfügbare Sendungen testen
1. Klicken Sie auf "Transport anbieten"
2. **Erwartung:** Liste mit Demo-Sendungen
3. Klicken Sie "Annehmen" bei einer Sendung
4. **Erwartung:** Erfolgsmeldung "Sendung angenommen!"

### Navigation testen
1. **Sendungen-Tab** - Sollte Ihre Sendungen anzeigen
2. **Chat-Tab** - Sollte Demo-Chats anzeigen
3. **Profil-Tab** - Sollte Benutzerprofil mit Demo-Daten anzeigen

## 🔧 Backend API Testing

### User Service testen

**1. Service-Status prüfen:**
```bash
curl http://localhost:8080/health
```
**Erwartung:** JSON mit Status "healthy"

**2. Alle Benutzer abrufen:**
```bash
curl http://localhost:8080/api/v1/users
```
**Erwartung:** JSON mit Demo-Benutzerdaten

**3. Neue Sendung erstellen:**
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
**Erwartung:** JSON mit erstellter Sendung

### Shipment Service testen

**1. Service-Status prüfen:**
```bash
curl http://localhost:8080/health
```
**Erwartung:** JSON mit Status "healthy"

**2. Alle Sendungen abrufen:**
```bash
curl http://localhost:8080/api/v1/shipments
```
**Erwartung:** JSON mit Demo-Sendungsdaten

**3. Gebote abrufen:**
```bash
curl http://localhost:8080/api/v1/bids
```
**Erwartung:** JSON mit Demo-Geboten

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
