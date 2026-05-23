import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'SmartFarm Togo'**
  String get appName;

  /// No description provided for @connexion.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get connexion;

  /// No description provided for @seConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get seConnecter;

  /// No description provided for @adresseEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get adresseEmail;

  /// No description provided for @motDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get motDePasse;

  /// No description provided for @tableauDeBord.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get tableauDeBord;

  /// No description provided for @carteChamp.
  ///
  /// In fr, this message translates to:
  /// **'Carte du champ'**
  String get carteChamp;

  /// No description provided for @controle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle'**
  String get controle;

  /// No description provided for @analyses.
  ///
  /// In fr, this message translates to:
  /// **'Analyses'**
  String get analyses;

  /// No description provided for @reglages.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get reglages;

  /// No description provided for @accueil.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get accueil;

  /// No description provided for @carte.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get carte;

  /// No description provided for @enLigne.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get enLigne;

  /// No description provided for @horsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get horsLigne;

  /// No description provided for @pompeArretee.
  ///
  /// In fr, this message translates to:
  /// **'Pompe arrêtée'**
  String get pompeArretee;

  /// No description provided for @pompeActive.
  ///
  /// In fr, this message translates to:
  /// **'Pompe active'**
  String get pompeActive;

  /// No description provided for @demarrerPompe.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer la pompe'**
  String get demarrerPompe;

  /// No description provided for @arreterPompe.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la pompe'**
  String get arreterPompe;

  /// No description provided for @ouvrirVanne.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la vanne'**
  String get ouvrirVanne;

  /// No description provided for @fermerVanne.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la vanne'**
  String get fermerVanne;

  /// No description provided for @toutFermer.
  ///
  /// In fr, this message translates to:
  /// **'Tout fermer'**
  String get toutFermer;

  /// No description provided for @confirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmer;

  /// No description provided for @annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// No description provided for @stressHydrique.
  ///
  /// In fr, this message translates to:
  /// **'Stress hydrique'**
  String get stressHydrique;

  /// No description provided for @optimal.
  ///
  /// In fr, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @sec.
  ///
  /// In fr, this message translates to:
  /// **'Sec'**
  String get sec;

  /// No description provided for @sature.
  ///
  /// In fr, this message translates to:
  /// **'Saturé'**
  String get sature;

  /// No description provided for @correct.
  ///
  /// In fr, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @derniereMesure.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mesure'**
  String get derniereMesure;

  /// No description provided for @volumeJournalier.
  ///
  /// In fr, this message translates to:
  /// **'Volume journalier'**
  String get volumeJournalier;

  /// No description provided for @budgetEau.
  ///
  /// In fr, this message translates to:
  /// **'Budget d\'eau'**
  String get budgetEau;

  /// No description provided for @batterieSolaire.
  ///
  /// In fr, this message translates to:
  /// **'Batterie solaire'**
  String get batterieSolaire;

  /// No description provided for @modeMPC.
  ///
  /// In fr, this message translates to:
  /// **'MPC Actif'**
  String get modeMPC;

  /// No description provided for @modePID.
  ///
  /// In fr, this message translates to:
  /// **'PID Actif'**
  String get modePID;

  /// No description provided for @modeManuel.
  ///
  /// In fr, this message translates to:
  /// **'Manuel'**
  String get modeManuel;

  /// No description provided for @rendementPrevu.
  ///
  /// In fr, this message translates to:
  /// **'Rendement prévu'**
  String get rendementPrevu;

  /// No description provided for @revenuEstime.
  ///
  /// In fr, this message translates to:
  /// **'Revenu net estimé'**
  String get revenuEstime;

  /// No description provided for @alertesRecentes.
  ///
  /// In fr, this message translates to:
  /// **'Alertes récentes'**
  String get alertesRecentes;

  /// No description provided for @modeDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo (données simulées)'**
  String get modeDemo;

  /// No description provided for @seDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get seDeconnecter;

  /// No description provided for @deconnexionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la déconnexion ?'**
  String get deconnexionConfirm;

  /// No description provided for @horsLigneBanner.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne — Affichage des dernières données disponibles'**
  String get horsLigneBanner;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
