import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../security/secure_storage.dart';
import '../utils/logger.dart';
import '../../data/datasources/api_datasource.dart';

const _apiConnectedKey = 'api_connected';
const _demoModeKey = 'demo_mode';

/// Vérifie que l'API enregistrée répond encore au démarrage.
Future<void> bootstrapApiConnection() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_apiConnectedKey) != true) return;

  try {
    final savedUrl = await SecureStorage.getApiUrl();
    final baseUrl = savedUrl ?? AppConstants.defaultApiBaseUrl;
    final api = ApiDatasource(baseUrl: baseUrl);
    final health = await api.getFieldHealth();
    if (health['status'] != 'ok') {
      await prefs.setBool(_apiConnectedKey, false);
      AppLogger.info('API enregistrée ne répond plus correctement.');
    }
  } catch (e) {
    await prefs.setBool(_apiConnectedKey, false);
    await prefs.setBool(_demoModeKey, true);
    AppLogger.error('Vérification API au démarrage échouée', e);
  }
}
