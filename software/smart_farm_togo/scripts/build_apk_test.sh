#!/usr/bin/env bash
# APK installable aujourd'hui (sans R8/minify) — tests terrain rapides
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Build APK profile (recommandé pour tests)"
flutter build apk --profile

APK="build/app/outputs/flutter-apk/app-profile.apk"
if [[ -f "$APK" ]]; then
  echo ""
  echo "APK prêt : $APK"
  echo "Installation : adb install -r \"$APK\""
fi
