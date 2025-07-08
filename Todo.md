Bringee Entwicklungs-Roadmap: TODO-Liste
Phase 0: Fundament & DevOps (Iteration 1)
Ziel: Schaffung einer stabilen, automatisierten Grundlage für die gesamte zukünftige Entwicklung. Diese Phase hat höchste Priorität, um von Anfang an eine hohe Code-Qualität und schnelle Deployments zu gewährleisten.

[ ] Projekt-Setup & Infrastruktur als Code (IaC)

Beschreibung: Initiales Setup des Google Cloud Projekts und der grundlegenden Infrastruktur mit Terraform.

Akzeptanzkriterien:

[ ] Ein Google Cloud Projekt ist erstellt und die Abrechnung ist konfiguriert.

[ ] Ein GitHub-Repository für den gesamten Code ist angelegt.

[ ] Ein separates GitHub-Repository für den Terraform-Code ist vorhanden.

[ ] Terraform-Code (IaC) ist geschrieben, um initiale Ressourcen zu provisionieren: VPC-Netzwerk, IAM-Rollen, Google Artifact Registry für Container-Images und Secret Manager.

[ ] Der Terraform-State wird sicher in einem GCS-Bucket gespeichert.

[ ] Continuous Integration / Continuous Deployment (CI/CD) Pipeline

Beschreibung: Aufbau einer automatisierten CI/CD-Pipeline mit GitHub Actions.

Akzeptanzkriterien:

[ ] Eine GitHub Actions-Workflow-Datei (.github/workflows/) ist im Code-Repository vorhanden.

[ ] Der Workflow wird bei jedem Push in einen main- oder develop-Branch automatisch ausgelöst.

[ ] CI-Teil: Der Workflow führt erfolgreich Linting und Unit-Tests für Backend und Frontend aus.

[ ] CI-Teil: Ein "Hello World"-Backend-Service wird erfolgreich in ein Docker-Image gebaut und in die Google Artifact Registry gepusht.

[ ] CD-Teil: Der Workflow authentifiziert sich sicher bei GCP mittels Workload Identity Federation (WIF).

[ ] CD-Teil: Der "Hello World"-Service wird automatisch auf einer Cloud Run-Instanz in einer Staging-Umgebung bereitgestellt.

[ ] Projekt-Scaffolding

Beschreibung: Erstellung der grundlegenden Ordner- und Modulstruktur für die Frontend- und Backend-Anwendungen.

Akzeptanzkriterien:

[ ] Das Flutter-Projekt ist initialisiert und folgt einer modularen, Feature-First-Architektur.

[ ] Die Backend-Microservices (UserService, ShipmentService) sind als separate Verzeichnisse mit einer grundlegenden Struktur (z.B. main.go/main.py, Dockerfile) angelegt.

[ ] Die grundlegende Konfiguration für die Beobachtbarkeit (strukturiertes Logging) ist in den "Hello World"-Services implementiert.

Phase 1: Kernfunktionalität (Minimum Viable Product)
Ziel: Implementierung des "Happy Path" der Kern-Transaktion, um das Geschäftsmodell mit echten Nutzern validieren zu können. Fokus liegt auf Online-Funktionalität.

[ ] Benutzer-Onboarding & Profil

Beschreibung: Implementierung der grundlegenden Benutzerregistrierung und -verwaltung.

Akzeptanzkriterien:

[ ] Benutzer können sich per E-Mail/Passwort über Firebase Authentication registrieren.

[ ] Benutzer können sich mit ihren Anmeldedaten einloggen.

[ ] Nach dem Login können Benutzer ihre grundlegenden Profilinformationen (Name, Profilbild) einsehen und bearbeiten.

[ ] Die Daten werden im UserService und den entsprechenden Datenbanken (Cloud SQL/Firestore) gespeichert.

[ ] Erstellung & Ansicht von Sendungsangeboten

Beschreibung: Ein Absender kann ein neues Versandangebot erstellen, das für Transporteure sichtbar ist.

Akzeptanzkriterien:

[ ] Ein Formular in der Flutter-App ermöglicht die Eingabe aller Sendungsdetails (Titel, Beschreibung, Größe, Gewicht, Start-/Zielort).

[ ] Der Absender muss mindestens ein Foto des unverpackten Inhalts hochladen. Das Foto wird sicher in einem Google Cloud Storage Bucket gespeichert.

[ ] Erstellte Angebote werden in einer für alle authentifizierten Benutzer sichtbaren Liste angezeigt.

[ ] Benutzer können die Detailansicht eines Angebots öffnen, um alle Informationen und Fotos zu sehen.

[ ] Bewerbungs- & Auswahlprozess

Beschreibung: Ein Transporteur kann sich auf ein Angebot bewerben und der Absender kann einen Transporteur auswählen.

Akzeptanzkriterien:

[ ] Ein Transporteur kann auf ein Angebot klicken und eine "Bewerben"-Aktion auslösen.

[ ] Der Absender sieht eine Liste aller Bewerber für sein Angebot.

[ ] Der Absender kann das Profil eines Bewerbers einsehen.

[ ] Der Absender kann eine Bewerbung annehmen, wodurch ein verbindlicher Transportauftrag entsteht und der Status der Sendung aktualisiert wird.

[ ] Basis-Chat-Funktionalität

Beschreibung: Ermöglicht die Kommunikation zwischen Absender und dem ausgewählten Transporteur im Kontext einer Sendung.

Akzeptanzkriterien:

[ ] Nachdem ein Transporteur ausgewählt wurde, wird ein 1-zu-1-Chat-Kanal zwischen Absender und Transporteur geöffnet.

[ ] Nachrichten werden in Echtzeit über Cloud Firestore ausgetauscht.

[ ] Der Chatverlauf ist persistent und an die jeweilige Sendung gebunden.

[ ] Vereinfachtes Übergabe- & Zustellprotokoll (Online-Modus)

Beschreibung: Digitale Bestätigung der Übergabe und Zustellung, die zunächst eine aktive Internetverbindung erfordert.

Akzeptanzkriterien:

[ ] Für jede Sendung wird ein eindeutiger, numerischer Zustellcode generiert und dem Absender angezeigt.

[ ] Der Transporteur hat in seiner App eine Eingabemaske, um den vom Empfänger erhaltenen Code einzugeben.

[ ] Das Backend validiert den Code. Bei korrekter Eingabe wird der Sendungsstatus auf "Zugestellt" (DELIVERED) aktualisiert.

[ ] Der Absender kann über die App die Übergabe an den Transporteur freigeben (als Alternative zum Code-Verlust des Empfängers).

Phase 2: Vertrauen & Monetarisierung
Ziel: Implementierung der Features, die für die finanzielle Abwicklung und den Aufbau von Vertrauen unerlässlich sind.

[ ] Zahlungsintegration mit Stripe Connect

Beschreibung: Integration der vollständigen Zahlungsabwicklung inklusive Treuhandfunktion.

Akzeptanzkriterien:

[ ] Transporteure können über einen von Stripe gehosteten Flow (Express-Konto) ihre Bankdaten sicher hinterlegen.

[ ] Absender können nach der Auswahl eines Transporteurs den vereinbarten Betrag sicher über die App bezahlen.

[ ] Die Zahlung wird nach dem "Separate Charges and Transfers"-Modell abgewickelt: Das Geld wird auf dem Plattformkonto gehalten.

[ ] Nach erfolgreicher Zustellung (DELIVERED-Status) wird die Auszahlung an den Transporteur automatisch über die Stripe API ausgelöst.

[ ] Die Bringee-Provision wird bei der Auszahlung korrekt einbehalten.

[ ] Identitätsprüfung

Beschreibung: Integration eines externen Dienstleisters zur Verifizierung der Identität der Nutzer.

Akzeptanzkriterien:

[ ] Ein Drittanbieter (z.B. ZignSec) ist via API angebunden.

[ ] Benutzer werden aus der App heraus durch den Verifizierungsprozess geführt (z.B. Hochladen von Ausweisdokumenten, Selfie-Abgleich).

[ ] Der Verifizierungsstatus ("Nicht verifiziert", "In Prüfung", "Verifiziert") wird im Benutzerprofil deutlich sichtbar angezeigt.

[ ] Reputations- & Bewertungssystem

Beschreibung: Einführung eines zweiseitigen Bewertungs- und Reputationssystems.

Akzeptanzkriterien:

[ ] Nach Abschluss einer Transaktion können sich Absender und Transporteur gegenseitig mit 1-5 Sternen bewerten und einen Kommentar hinterlassen.

[ ] Bewertungen werden erst sichtbar, wenn beide Parteien bewertet haben oder eine Frist abgelaufen ist.

[ ] Das Benutzerprofil zeigt die durchschnittliche Bewertung und die Anzahl der abgeschlossenen Transporte an.

[ ] Die Kriterien für den "Pro-Transporteur"-Status sind im Backend definiert und der Status wird Nutzern bei Erfüllung automatisch zugewiesen und im Profil angezeigt.

Phase 3: Fortgeschrittene Features & UX-Verbesserung
Ziel: Verbesserung der Kernfunktionen durch technisch anspruchsvollere Features, die die Zuverlässigkeit und den Nutzen der App massiv erhöhen.

[ ] Offline-First-Fähigkeit

Beschreibung: Umbau der Flutter-App, sodass sie auch ohne stabile Internetverbindung zuverlässig funktioniert.

Akzeptanzkriterien:

[ ] Eine lokale Datenbank (Drift/SQLite) ist in der Flutter-App implementiert.

[ ] Alle für eine laufende Transaktion relevanten Daten werden lokal zwischengespeichert.

[ ] Die App zeigt Daten primär aus der lokalen Datenbank an (Optimistic UI).

[ ] Ein Synchronisationsdienst mit Request-Warteschlange wird implementiert, um Offline-Änderungen bei Wiederherstellung der Verbindung mit dem Backend abzugleichen.

[ ] Die App erkennt den Netzwerkstatus und informiert den Nutzer bei Bedarf.

[ ] Sicheres Übergabeprotokoll (Offline-fähig)

Beschreibung: Implementierung des robusten "Digitalen Handshakes" und der definierten Fallback-Mechanismen.

Akzeptanzkriterien:

[ ] Der QR-Code-basierte Challenge-Response-Mechanismus für die Übergabe funktioniert auch ohne Internetverbindung auf beiden Geräten.

[ ] Die Fallback-Optionen (manuelle Code-Eingabe, PDF-Versand per E-Mail) sind implementiert und können vom Nutzer ausgelöst werden.

[ ] Der Prozess bei "Inspektion verweigert" ist implementiert und führt zum korrekten Abbruch der Transaktion.

[ ] GPS-Tracking & Geofencing

Beschreibung: Implementierung der Live-Standortverfolgung für laufende Transporte.

Akzeptanzkriterien:

[ ] Der Transporteur kann vor Beginn einer Reise explizit die Erlaubnis zur Standortfreigabe erteilen (Opt-in).

[ ] Der Absender kann den Standort des Transporteurs auf einer Karte in der App verfolgen.

[ ] Das Backend empfängt und verarbeitet die Standortdaten.

[ ] Geofencing am Zielort löst eine Benachrichtigung an den Absender aus.

Phase 4: Ökosystem & Plattform-Intelligenz
Ziel: Integration von Partnerdiensten und KI-Funktionen, um den Wert der Plattform zu maximieren und die Betriebsabläufe zu optimieren.

[ ] Zoll- & Steuerabwicklung

Beschreibung: Integration eines Dienstes zur Berechnung von Zöllen und Steuern.

Akzeptanzkriterien:

[ ] Eine API (z.B. Zonos) ist an den CustomsService angebunden.

[ ] Bei der Angebotserstellung werden die voraussichtlichen Gesamtkosten (Landed Cost) berechnet und dem Absender transparent angezeigt.

[ ] Eine KI-gestützte HS-Code-Klassifizierung basierend auf der Artikelbeschreibung ist implementiert, um den Prozess für den Absender zu vereinfachen.

[ ] Die Haftungsregeln (DDU-Modell) werden dem Nutzer klar kommuniziert.

[ ] KI-gestützte Preisgestaltung & Inhaltsprüfung

Beschreibung: Implementierung der definierten KI-Modelle zur Optimierung von Preis und Sicherheit.

Akzeptanzkriterien:

[ ] Der PricingService schlägt bei der Angebotserstellung einen Preisbereich vor und zeigt eine einfache Begründung dafür an. Nutzer können frei davon abweichen.

[ ] Die Cloud Vision API analysiert hochgeladene Paketfotos.

[ ] Bei einer erkannten Diskrepanz zwischen Bild und Beschreibung erhält der Transporteur eine klare Warnung in seiner App.

[ ] Online Dispute Resolution (ODR) & Admin-Portal

Beschreibung: Aufbau eines umfassenden Administrationsportals mit einem strukturierten Streitbeilegungsprozess.

Akzeptanzkriterien:

[ ] Administratoren können sich in ein sicheres Web-Portal einloggen.

[ ] Das Portal bietet eine Übersicht über alle Nutzer, Transaktionen und Streitfälle.

[ ] Der mehrstufige ODR-Prozess (Direktverhandlung, Mediation, Entscheidung) ist implementiert.

[ ] Administratoren können auf Chatverläufe und Übergabeprotokolle zugreifen, um fundierte Entscheidungen zu treffen.

[ ] KI-gestützter Kundensupport

Beschreibung: Implementierung eines RAG-Chatbots für den First-Level-Support.

Akzeptanzkriterien:

[ ] Eine Wissensdatenbank (Vektordatenbank) mit AGBs, FAQs etc. ist erstellt.

[ ] Der RAG-Chatbot (via Dialogflow CX & Vertex AI Search) ist in die App integriert.

[ ] Der Bot kann faktengestützte Antworten auf häufige Fragen geben.

[ ] Bei komplexen Anfragen kann der Bot den Nutzer an einen menschlichen Mitarbeiter weiterleiten.
