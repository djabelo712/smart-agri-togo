#!/usr/bin/env bash
# Distribue l'APK release via Firebase App Distribution
# Usage : FIREBASE_APP_ID=1:xxx:android:yyy ./scripts/distribute_firebase.sh [notes]
set -euo pipefail

cd "$(dirname "$0")/.."

APK="build/app/outputs/flutter-apk/app-release.apk"
NOTES="${1:-SmartFarm Togo — build de test terrain}"

if [[ -z "${FIREBASE_APP_ID:-}" ]]; then
  echo "Erreur : définir FIREBASE_APP_ID (console Firebase → App Android → ID app)."
  echo "Exemple : export FIREBASE_APP_ID=1:123456789:android:abcdef"
  exit 1
fi

if [[ ! -f "$APK" ]]; then
  echo "APK introuvable. Lancer d'abord : flutter build apk --release"
  exit 1
fi

if ! command -v firebase &>/dev/null; then
  echo "Installer Firebase CLI : npm install -g firebase-tools && firebase login"
  exit 1
fi

firebase appdistribution:distribute "$APK" \
  --app "$FIREBASE_APP_ID" \
  --groups testeurs-terrain \
  --release-notes "$NOTES"

echo "Distribution terminée."
