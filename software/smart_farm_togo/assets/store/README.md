# Déploiement Play Store — SmartFarm Togo

## 1. Signature release

Voir `android/key.properties.example` et la section **Build release** du `README.md` à la racine du projet.

## 2. Icône application

| Fichier | Taille | Rôle |
|---------|--------|------|
| `assets/icon/icon_512.png` | 512×512 | Play Store + base launcher |
| `assets/icon/icon_foreground.png` | 432×432 | Premier plan icône adaptative |

Style : vert `#1B6B3A`, symbole plante sobre (pas d’icônes « IA »).

```bash
dart run flutter_launcher_icons
```

## 3. Captures d’écran (minimum 4)

Résolution : 1080×1920 px (9:16).

| # | Écran | Nom fichier |
|---|--------|-------------|
| 1 | Connexion | `screenshot_01_login.png` |
| 2 | Tableau de bord | `screenshot_02_dashboard.png` |
| 3 | Carte du champ | `screenshot_03_carte.png` |
| 4 | Contrôle | `screenshot_04_controle.png` |

```bash
flutter run -d <id_appareil_ou_emulateur>
# Captures via l’émulateur ou : adb exec-out screencap -p > screenshot.png
```

## 4. Bannière Play Store

- Fichier : `assets/store/feature_graphic.png`
- Dimensions : **1024×500 px**
- Texte suggéré : « SmartFarm Togo · Irrigation intelligente · Lomé »

## 5. Fiche Play Store (français)

| Champ | Contenu |
|-------|---------|
| Titre | SmartFarm Togo |
| Catégorie | Agriculture / Utilitaires |
| Description courte | Irrigation intelligente pour parcelles agricoles à Lomé, Togo. |
| Description longue | Surveillance en temps réel de 25 zones, contrôle des vannes et de la pompe, analyses MPC/PID/Manuel, alertes stress hydrique. Déployé par AgroLab Africa. |
| Public cible | Agriculteurs, techniciens, recherche agricole |

## 6. Firebase App Distribution (phase tests)

```bash
npm install -g firebase-tools
firebase login

flutter build apk --release

firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_APP_ID_ANDROID> \
  --groups testeurs-terrain \
  --release-notes "Version initiale SmartFarm Togo"
```

L’ID application se trouve dans la console Firebase → Paramètres du projet → Vos applications → Android.

## 7. Google Play Console (production)

1. [play.google.com/console](https://play.google.com/console) — compte développeur 25 USD
2. Créer l’app **SmartFarm Togo**
3. **Test interne** → créer une version → uploader `app-release.aab`
4. Ajouter des testeurs par e-mail
5. Après validation : **Beta fermée** puis **Production**

Chemin AAB après build :

```
build/app/outputs/bundle/release/app-release.aab
```

## 8. Configuration Firebase production

Avant la release terrain :

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Fichiers générés (ne pas commiter si dépôt public) :

- `lib/firebase_options.dart`
- `android/app/google-services.json`

Ajouter le plugin Google Services dans `android/settings.gradle.kts` si FlutterFire le demande.
