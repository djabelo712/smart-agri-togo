# SmartFarm Togo

Application mobile Flutter pour l'irrigation intelligente du champ pilote 25×25 m à Lomé, Togo (AgroLab Africa).

## Prérequis

- Flutter 3.x stable
- Android SDK (API 23+, cible 34)
- Pour FCM / Auth : `flutterfire configure` + `android/app/google-services.json` (non versionné)

## Démarrage développement

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Mode **démo** activé par défaut (données simulées, sans Firebase).

## Build release Android

### 1. Keystore (une seule fois)

```bash
keytool -genkey -v -keystore ~/smartfarm_keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias smartfarm_key
```

Copier `android/key.properties.example` vers `android/key.properties` et renseigner les mots de passe et le chemin absolu du `.jks`.

### 2. APK (tests terrain / Firebase App Distribution)

```bash
flutter build apk --release
# Sortie : build/app/outputs/flutter-apk/app-release.apk
```

### 3. AAB (Google Play Store)

```bash
flutter build appbundle --release
# Sortie : build/app/outputs/bundle/release/app-release.aab
```

### Script tout-en-un

```bash
./scripts/build_release.sh
```

## Firebase App Distribution

```bash
firebase login
flutter build apk --release

firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app VOTRE_FIREBASE_APP_ID_ANDROID \
  --groups testeurs-terrain \
  --release-notes "SmartFarm Togo v1.0.0 — tests de terrain"
```

## Google Play Store

1. Compte [Google Play Console](https://play.google.com/console) (25 USD)
2. Créer l'application **SmartFarm Togo**
3. Remplir la fiche en français (voir `assets/store/README.md`)
4. Piste **Test interne** → uploader `app-release.aab`
5. Assets : icône 512×512, bannière 1024×500, ≥ 4 captures

## Icônes launcher

Icônes placeholder (vert #1B6B3A) :

```bash
python3 scripts/generate_placeholder_icons.py
dart run flutter_launcher_icons
```

Remplacer ensuite `assets/icon/icon_512.png` et `icon_foreground.png` par la charte AgroLab finale.

## Distribution Firebase (script)

```bash
export FIREBASE_APP_ID=1:xxx:android:yyy
./scripts/build_release.sh
./scripts/distribute_firebase.sh "Notes de version"
```

## Structure principale

```
lib/
├── core/          # thème, router, firebase, notifications
├── data/          # modèles, repositories, mock
├── providers/     # Riverpod
└── screens/       # UI (5 onglets)
```

## Checklist avant livraison

- [ ] `flutter analyze` sans erreur
- [ ] `flutter test`
- [ ] `flutter build apk --release` et `appbundle --release`
- [ ] Tests Android 10 et 13+
- [ ] `google-services.json` et `firebase_options.dart` configurés (prod)
- [ ] Keystore et `key.properties` hors dépôt Git
- [ ] Mode démo et notifications testées

## Licence

Projet AgroLab Africa — usage interne / terrain.
