import 'package:firebase_core/firebase_core.dart';
import '../utils/logger.dart';
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
        AppLogger.info('Persistance Firebase ignorée — $e');
      }
      AppLogger.info('Firebase initialisé.');
      return true;
    }
  } catch (e) {
    AppLogger.error('Firebase non disponible', e);
  }

  isFirebaseInitialized = false;
  await ensureDemoModeEnabled();
  AppLogger.info('Mode démo activé (Firebase indisponible).');
  return false;
}
