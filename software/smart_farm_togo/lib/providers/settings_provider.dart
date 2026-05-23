import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _demoModeKey = 'demo_mode';

/// Préférences initialisées dans [main] via [initializeSharedPreferences].
SharedPreferences? _prefsInstance;

Future<void> initializeSharedPreferences() async {
  _prefsInstance = await SharedPreferences.getInstance();
}

/// Force le mode démo quand Firebase n'est pas disponible.
Future<void> ensureDemoModeEnabled() async {
  await _prefsInstance?.setBool(_demoModeKey, true);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  assert(_prefsInstance != null, 'Appeler initializeSharedPreferences() dans main');
  return _prefsInstance!;
});

final demoModeProvider =
    StateNotifierProvider<DemoModeNotifier, bool>((ref) {
  return DemoModeNotifier(ref.watch(sharedPreferencesProvider));
});

class DemoModeNotifier extends StateNotifier<bool> {
  DemoModeNotifier(this._prefs) : super(_prefs.getBool(_demoModeKey) ?? true);

  final SharedPreferences _prefs;

  Future<void> setDemoMode(bool value) async {
    state = value;
    await _prefs.setBool(_demoModeKey, value);
  }
}
