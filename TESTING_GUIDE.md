# Bringee Testing Guide

Dieser Guide erklärt, wie Sie die verbesserte Bringee-Anwendung testen können.

## 🚀 Schnellstart

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
**Erwartung:** JSON mit Demo-Benutzern (Max Mustermann, Anna Schmidt)

**3. Benutzerdetails abrufen:**
```bash
curl http://localhost:8080/api/v1/users/1
```
**Erwartung:** JSON mit Max Mustermanns Details

**4. Anmeldung testen:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"max.mustermann@email.com","password":"test123"}'
```
**Erwartung:** JSON mit Token und Benutzerdetails

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
**Erwartung:** JSON mit Demo-Sendungen

**3. Sendungsdetails abrufen:**
```bash
curl http://localhost:8080/api/v1/shipments/1
```
**Erwartung:** JSON mit Sendungsdetails und Status-Historie

**4. Neue Sendung erstellen:**
```bash
curl -X POST http://localhost:8080/api/v1/shipments \
  -H "Content-Type: application/json" \
  -d '{
    "recipient_name": "Test Empfänger",
    "recipient_address": "Teststraße 123, 12345 Teststadt",
    "recipient_phone": "+49123456789",
    "item_description": "Test-Paket",
    "item_value_usd": 100.0,
    "from_location": "München",
    "to_location": "Berlin",
    "estimated_delivery_date": "2025-01-20T00:00:00Z"
  }'
```
**Erwartung:** JSON mit neuer Sendung (Status: POSTED)

**5. Sendung annehmen:**
```bash
curl -X PUT http://localhost:8080/api/v1/shipments/1/accept \
  -H "Content-Type: application/json" \
  -d '{"traveler_id":"2","agreed_fee":50.0}'
```
**Erwartung:** JSON mit aktualisierter Sendung (Status: ACCEPTED)

**6. Status aktualisieren:**
```bash
curl -X PUT http://localhost:8080/api/v1/shipments/1/status \
  -H "Content-Type: application/json" \
  -d '{"status":"IN_TRANSIT"}'
```
**Erwartung:** JSON mit aktualisierter Sendung (Status: IN_TRANSIT)

## 📊 Demo-Daten

### Benutzer
- **ID:** 1, **Name:** Max Mustermann, **Email:** max.mustermann@email.com
- **ID:** 2, **Name:** Anna Schmidt, **Email:** anna.schmidt@email.com

### Sendungen
- **ID:** 1, **Status:** POSTED, **Route:** München → Berlin
- **ID:** 2, **Status:** DELIVERED, **Route:** Frankfurt → München  
- **ID:** 3, **Status:** IN_TRANSIT, **Route:** Düsseldorf → Hamburg

## 🐛 Bekannte Probleme

1. **Port-Konflikte:** Beide Services laufen standardmäßig auf Port 8080
   - **Lösung:** Ändern Sie den Port für einen Service in der `main.go`
   
2. **CORS-Probleme:** Frontend kann Backend nicht erreichen
   - **Lösung:** CORS-Headers in Backend-Services hinzufügen

3. **Flutter-Dependencies:** `flutter pub get` schlägt fehl
   - **Lösung:** Flutter SDK aktualisieren oder Dependencies manuell hinzufügen

## ✅ Erfolgreiche Tests

Wenn alles funktioniert, sollten Sie sehen:

✅ **Frontend:**
- Hauptbildschirm mit Willkommensnachricht
- Navigation zwischen allen Tabs
- Sendungserstellung funktioniert
- Demo-Daten werden angezeigt

✅ **Backend:**
- Beide Services starten ohne Fehler
- Health-Checks geben "healthy" zurück
- API-Endpoints antworten mit JSON
- Demo-Daten sind verfügbar

✅ **Integration:**
- Frontend kann mit Backend kommunizieren
- Daten werden korrekt angezeigt
- Benutzerinteraktionen funktionieren

## 🎯 Nächste Schritte

Nach erfolgreichen Tests können Sie:

1. **Echte Datenbank** integrieren (PostgreSQL/Firestore)
2. **Authentifizierung** implementieren (Firebase Auth)
3. **Zahlungsabwicklung** hinzufügen (Stripe)
4. **Push-Benachrichtigungen** einrichten (FCM)
5. **Zoll-APIs** integrieren
6. **KI-Funktionen** entwickeln

---

**Viel Erfolg beim Testen! 🚀**