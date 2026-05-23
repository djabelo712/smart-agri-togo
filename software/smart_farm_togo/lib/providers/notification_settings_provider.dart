import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_provider.dart';

const _stressKey = 'notif_stress';
const _pumpKey = 'notif_pump';
const _rainKey = 'notif_rain';
const _dailyKey = 'notif_daily';

class NotificationSettings {
  const NotificationSettings({
    required this.stressHydrique,
    required this.pannePompe,
    required this.pluieDetectee,
    required this.rapportQuotidien,
  });

  final bool stressHydrique;
  final bool pannePompe;
  final bool pluieDetectee;
  final bool rapportQuotidien;

  NotificationSettings copyWith({
    bool? stressHydrique,
    bool? pannePompe,
    bool? pluieDetectee,
    bool? rapportQuotidien,
  }) {
    return NotificationSettings(
      stressHydrique: stressHydrique ?? this.stressHydrique,
      pannePompe: pannePompe ?? this.pannePompe,
      pluieDetectee: pluieDetectee ?? this.pluieDetectee,
      rapportQuotidien: rapportQuotidien ?? this.rapportQuotidien,
    );
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier(ref.watch(sharedPreferencesProvider));
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier(this._prefs)
      : super(
          NotificationSettings(
            stressHydrique: _prefs.getBool(_stressKey) ?? true,
            pannePompe: _prefs.getBool(_pumpKey) ?? true,
            pluieDetectee: _prefs.getBool(_rainKey) ?? true,
            rapportQuotidien: _prefs.getBool(_dailyKey) ?? true,
          ),
        );

  final SharedPreferences _prefs;

  Future<void> setStress(bool v) async {
    state = state.copyWith(stressHydrique: v);
    await _prefs.setBool(_stressKey, v);
  }

  Future<void> setPump(bool v) async {
    state = state.copyWith(pannePompe: v);
    await _prefs.setBool(_pumpKey, v);
  }

  Future<void> setRain(bool v) async {
    state = state.copyWith(pluieDetectee: v);
    await _prefs.setBool(_rainKey, v);
  }

  Future<void> setDaily(bool v) async {
    state = state.copyWith(rapportQuotidien: v);
    await _prefs.setBool(_dailyKey, v);
  }
}
