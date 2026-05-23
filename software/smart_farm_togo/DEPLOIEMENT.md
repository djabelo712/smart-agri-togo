# Déploiement SmartFarm Togo

Guide pour construire et distribuer l’application Android.

## Prérequis

- Flutter SDK installé
- `flutterfire configure` (Firebase : `google-services.json`, `lib/firebase_options.dart`)
- Compte Firebase (App Distribution) et/ou Google Play Console (25 USD)

## 1. Signature release (une seule fois)

```bash
keytool -genkey -v -keystore ~/smartfarm_keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias smartfarm_key
```

Copier le modèle et remplir les chemins absolus :

```bash
cp android/key.properties.example android/key.properties
# Éditer android/key.properties (ne jamais le commiter)
```

## 2. Firebase Android

1. Console Firebase → projet SmartFarm → ajouter app Android  
   ID : `com.agrolabAfrica.togo.smartfarm`
2. Télécharger `google-services.json` → `android/app/google-services.json`
3. Terminal projet :

```bash
flutterfire configure
```

## 3. Build release

```bash
cd software/smart_farm_togo
flutter pub get

# APK tests terrain
flutter build apk --release
# Sortie : build/app/outputs/flutter-apk/app-release.apk

# AAB Play Store
flutter build appbundle --release
# Sortie : build/app/outputs/bundle/release/app-release.aab
```

Sans `key.properties`, le build release utilise temporairement la clé debug.

## 4. Firebase App Distribution (phase test)

```bash
npm install -g firebase-tools
firebase login

firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app VOTRE_FIREBASE_APP_ID_ANDROID \
  --groups testeurs-terrain \
  --release-notes "SmartFarm Togo — build de test terrain"
```

## 5. Google Play Store

1. [play.google.com/console](https://play.google.com/console) → créer l’app **SmartFarm Togo**
2. Piste **Test interne** → importer `app-release.aab`
3. Fiche en français, captures dans `assets/store/`
4. Après validation → Beta fermée → Production

## 6. Vérifications avant publication

```bash
flutter analyze
flutter test
```

Checklist :

- [ ] Mode démo et Firebase testés sur Android 10 et 13+
- [ ] Notifications (test dans Réglages)
- [ ] `key.properties` et `*.jks` hors Git
- [ ] Aucun secret dans le dépôt

## Identifiants

| Élément | Valeur |
|---------|--------|
| `applicationId` | `com.agrolabAfrica.togo.smartfarm` |
| `minSdk` | 23 |
| Version | `pubspec.yaml` (`1.0.0+1`) |
