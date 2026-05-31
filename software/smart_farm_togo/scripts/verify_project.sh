#!/usr/bin/env bash
# Vérification qualité avant livraison SmartFarm Togo
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> flutter pub get"
flutter pub get

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

echo ""
echo "✓ Analyse et tests OK. Pour la release : ./scripts/build_release.sh"
