import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../../data/repositories/field_repository.dart';
import '../../providers/settings_provider.dart';

/// `true` après une initialisation Firebase réussie.
bool isFirebaseInitialized = false;

/// Firebase utilisable (app [DEFAULT] créée).
bool get firebaseAvailable =>
    isFirebaseInitialized && Firebase.apps.isNotEmpty;

/// Initialise Firebase si possible ; active le mode démo en cas d'échec.
Future<bool> bootstrapFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    isFirebaseInitialized = Firebase.apps.isNotEmpty;

    if (firebaseAvailable) {
      try {
        FieldRepository.enableOfflinePersistence();
      } catch (e) {
        debugPrint('SmartFarm: persistance Firebase ignorée — $e');
      }
      debugPrint('SmartFarm: Firebase initialisé.');
      return true;
    }
  } catch (e, st) {
    debugPrint('SmartFarm: Firebase non disponible — $e');
    if (kDebugMode) debugPrint('$st');
  }

  isFirebaseInitialized = false;
  await ensureDemoModeEnabled();
  debugPrint('SmartFarm: mode démo activé (Firebase indisponible).');
  return false;
}
