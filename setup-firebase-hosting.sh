#!/bin/bash

# Firebase Hosting Setup für Flutter Web App
# Dieses Skript richtet Firebase Hosting für die Bringee Flutter Web App ein

set -e

echo "🚀 Firebase Hosting Setup für Bringee Flutter Web App"
echo "=================================================="

# Prüfe ob wir im richtigen Verzeichnis sind
if [ ! -f "frontend/bringee_app/pubspec.yaml" ]; then
    echo "❌ Fehler: Flutter App nicht gefunden. Bitte führe dieses Skript im Root-Verzeichnis aus."
    exit 1
fi

cd frontend/bringee_app

echo "📦 Installiere Firebase CLI..."
npm install -g firebase-tools

echo "🔐 Authentifiziere bei Firebase..."
firebase login --no-localhost

echo "🏗️ Initialisiere Firebase Hosting..."
firebase init hosting --project gemini-koorosh-karimi --public build/web --yes

echo "✅ Firebase Hosting Setup abgeschlossen!"
echo ""
echo "📋 Nächste Schritte:"
echo "1. Generiere ein Firebase Token: firebase login:ci"
echo "2. Füge das Token als FIREBASE_TOKEN Secret in GitHub hinzu"
echo "3. Push deine Änderungen: git add . && git commit -m 'Add Firebase Hosting' && git push"
echo ""
echo "🌐 Deine App wird dann automatisch auf Firebase Hosting deployed!"