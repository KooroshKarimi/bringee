# Flutter Setup Guide - Bringee App

## 🚀 Flutter SDK Installation

### 1. Flutter SDK herunterladen

#### Für Linux:
```bash
# Flutter SDK herunterladen
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.3-stable.tar.xz

# Archiv entpacken
tar xf flutter_linux_3.19.3-stable.tar.xz

# Flutter zu PATH hinzufügen
export PATH="$PATH:`pwd`/flutter/bin"

# Permanente Installation (zu ~/.bashrc hinzufügen)
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

#### Für macOS:
```bash
# Mit Homebrew
brew install --cask flutter

# Oder manuell
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.19.3-stable.tar.xz
tar xf flutter_macos_3.19.3-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Für Windows:
```bash
# Flutter SDK von https://flutter.dev/docs/get-started/install/windows herunterladen
# ZIP-Datei entpacken und zu PATH hinzufügen
```

### 2. Flutter Doctor ausführen

```bash
flutter doctor
```

### 3. Fehlende Abhängigkeiten installieren

#### Android Studio (für Android Development):
```bash
# Android Studio installieren
# https://developer.android.com/studio

# Android SDK installieren
flutter doctor --android-licenses
```

#### Xcode (für iOS Development - nur macOS):
```bash
# Xcode von App Store installieren
xcode-select --install
```

#### VS Code Extensions:
```bash
# Flutter Extension installieren
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

### 4. Projekt Setup

```bash
# In das Flutter-Projektverzeichnis wechseln
cd frontend/bringee_app

# Dependencies installieren
flutter pub get

# App starten (Web)
flutter run -d chrome

# App starten (Android)
flutter run -d android

# App starten (iOS)
flutter run -d ios
```

## 🔧 Entwicklungsumgebung

### VS Code Konfiguration

Erstelle `.vscode/settings.json`:
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Flutter Konfiguration

Überprüfe `analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_unused_constructor_parameters
    - await_only_futures
    - camel_case_types
    - cancel_subscriptions
    - constant_identifier_names
    - control_flow_in_finally
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - empty_statements
    - hash_and_equals
    - implementation_imports
    - library_names
    - library_prefixes
    - non_constant_identifier_names
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_typing_uninitialized_variables
    - slash_for_doc_comments
    - test_types_in_equals
    - throw_in_finally
    - type_init_formals
    - unnecessary_brace_in_string_interps
    - unnecessary_getters_setters
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_statements
    - unrelated_type_equality_checks
    - use_rethrow_when_possible
    - valid_regexps
```

## 🧪 Testing

### Unit Tests ausführen:
```bash
flutter test
```

### Integration Tests:
```bash
flutter test integration_test/
```

### Widget Tests:
```bash
flutter test test/widget_test.dart
```

## 📱 Build

### Web Build:
```bash
flutter build web
```

### Android Build:
```bash
flutter build apk
flutter build appbundle
```

### iOS Build:
```bash
flutter build ios
```

## 🔍 Debugging

### Flutter Inspector:
```bash
flutter run --debug
```

### Performance Profiling:
```bash
flutter run --profile
```

### Release Build:
```bash
flutter run --release
```

## 📦 Dependencies

### Aktuelle Dependencies (pubspec.yaml):
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_riverpod: ^2.4.9
  http: ^1.1.0
  json_annotation: ^4.8.1
  image_picker: ^1.0.4
  shared_preferences: ^2.2.2
  go_router: ^12.1.3
  flutter_svg: ^2.0.9
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

### Dependencies aktualisieren:
```bash
flutter pub upgrade
flutter pub outdated
```

## 🚨 Häufige Probleme

### 1. Flutter nicht gefunden:
```bash
# PATH überprüfen
echo $PATH

# Flutter Version prüfen
flutter --version
```

### 2. Android SDK nicht gefunden:
```bash
# Android Studio installieren
# ANDROID_HOME setzen
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### 3. iOS Simulator nicht verfügbar:
```bash
# Xcode installieren
# iOS Simulator starten
open -a Simulator
```

### 4. Web Development:
```bash
# Chrome installieren
# Web Server starten
flutter run -d chrome --web-port 8080
```

## 📚 Nützliche Befehle

```bash
# Flutter Doctor
flutter doctor -v

# Dependencies installieren
flutter pub get

# Code generieren
flutter packages pub run build_runner build

# Clean Build
flutter clean
flutter pub get

# Hot Reload
# Drücke 'r' im Terminal während flutter run läuft

# Hot Restart
# Drücke 'R' im Terminal während flutter run läuft

# Quit
# Drücke 'q' im Terminal während flutter run läuft
```

## 🎯 Nächste Schritte

1. **Flutter SDK installieren** (siehe oben)
2. **Dependencies installieren**: `flutter pub get`
3. **App starten**: `flutter run -d chrome`
4. **Backend-Services starten**: Siehe Backend-Dokumentation
5. **API-Integration implementieren**: HTTP-Calls zu Backend
6. **Tests schreiben**: Unit und Widget Tests
7. **Deployment vorbereiten**: Build für Produktion