import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/firebase/firebase_bootstrap.dart';
import '../core/security/secure_storage.dart';
import '../core/utils/api_url_utils.dart';
import '../data/datasources/api_datasource.dart';
import 'auth_provider.dart';
import 'settings_provider.dart';

/// Providers FastAPI : URL de base, état de connexion, client Dio JWT.

const _apiConnectedKey = 'api_connected';

/// URL de base FastAPI (persistée de façon sécurisée).
final apiBaseUrlProvider =
    StateNotifierProvider<ApiBaseUrlNotifier, String>((ref) {
  return ApiBaseUrlNotifier();
});

class ApiBaseUrlNotifier extends StateNotifier<String> {
  ApiBaseUrlNotifier() : super(AppConstants.defaultApiBaseUrl) {
    _load();
  }

  Future<void> _load() async {
    final saved = await SecureStorage.getApiUrl();
    if (saved != null && saved.isNotEmpty) {
      state = normalizeApiBaseUrl(saved);
    }
  }

  Future<void> setBaseUrl(String url) async {
    final normalized = normalizeApiBaseUrl(url);
    state = normalized;
    await SecureStorage.saveApiUrl(normalized);
  }
}

/// `true` après un test API réussi (persisté).
final apiConnectedProvider =
    StateNotifierProvider<ApiConnectedNotifier, bool>((ref) {
  return ApiConnectedNotifier(ref.watch(sharedPreferencesProvider));
});

class ApiConnectedNotifier extends StateNotifier<bool> {
  ApiConnectedNotifier(this._prefs)
      : super(_prefs.getBool(_apiConnectedKey) ?? false);

  final SharedPreferences _prefs;

  Future<void> setConnected(bool value) async {
    state = value;
    await _prefs.setBool(_apiConnectedKey, value);
  }
}

/// Utiliser les modèles ML distants (API testée ou mode démo désactivé).
final useLiveApiProvider = Provider<bool>((ref) {
  return ref.watch(apiConnectedProvider) || !ref.watch(demoModeProvider);
});

/// Libellé rôle affiché sur le profil Réglages.
final userRoleLabelProvider = Provider<String>((ref) {
  final demo = ref.watch(demoModeProvider);
  final apiOk = ref.watch(apiConnectedProvider);
  if (apiOk && !demo) return 'Opérateur champ · API';
  if (apiOk && demo) return 'API connectée · champ simulé';
  if (demo) return 'Mode démo';
  return firebaseAvailable ? 'Opérateur champ' : 'Utilisateur local';
});

/// Libellé connexion (section Système).
final systemConnectionLabelProvider = Provider<String>((ref) {
  final apiOk = ref.watch(apiConnectedProvider);
  final firebaseOk = firebaseAvailable;
  if (apiOk && firebaseOk) return 'Firebase + API';
  if (apiOk) return 'API production';
  if (firebaseOk) return 'Firebase';
  return 'Locale (démo)';
});

/// Client HTTP configuré avec JWT depuis [AuthRepository].
final apiDatasourceProvider = Provider<ApiDatasource>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return ApiDatasource(
    baseUrl: baseUrl,
    tokenProvider: authRepo.getToken,
  );
});
