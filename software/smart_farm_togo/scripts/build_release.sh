#!/usr/bin/env bash
# Build release SmartFarm Togo — APK + AAB
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> flutter pub get"
flutter pub get

echo "==> Analyse"
flutter analyze

echo "==> Build APK release"
flutter build apk --release

echo "==> Build App Bundle release"
flutter build appbundle --release

echo ""
echo "Fichiers générés :"
ls -lh build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || true
ls -lh build/app/outputs/bundle/release/app-release.aab 2>/dev/null || true

echo ""
echo "Terminé."
