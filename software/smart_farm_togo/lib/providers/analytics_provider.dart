import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/api_datasource.dart';
import '../data/models/history_model.dart';
import 'auth_provider.dart';
import 'field_provider.dart';
import 'settings_provider.dart';

final dailyHistoryStreamProvider = StreamProvider<List<DailyHistory>>((ref) {
  return ref.watch(fieldRepositoryProvider).watchDailyHistory();
});

final analyticsApiProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(apiDatasourceProvider));
});

class AnalyticsRepository {
  AnalyticsRepository(this._api);

  final ApiDatasource _api;

  Future<Map<String, dynamic>> yieldForecast() => _api.getYieldForecast();

  Future<List<double>> et0Forecast() => _api.getEt0Forecast();

  Future<Map<String, dynamic>> researchComparison() =>
      _api.getResearchComparison();

  Future<List<DailyHistory>> dailyHistory({int days = 30}) =>
      _api.getDailyHistory(days: days);
}

final yieldForecastProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  if (ref.watch(demoModeProvider)) {
    return {
      'cells': {
        'C00': {'predicted_yield_kg': 2.1, 'confidence': 0.82},
      },
    };
  }
  return ref.watch(analyticsApiProvider).yieldForecast();
});

final researchComparisonProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  if (ref.watch(demoModeProvider)) {
    return {
      'MPC': {
        'avg_ks': 0.94,
        'water_mm': 32.0,
        'stress_days': 2,
        'balance': 'Optimal',
      },
      'PID': {
        'avg_ks': 0.88,
        'water_mm': 38.0,
        'stress_days': 5,
        'balance': 'Correct',
      },
      'Manuel': {
        'avg_ks': 0.82,
        'water_mm': 48.0,
        'stress_days': 9,
        'balance': 'Stress',
      },
    };
  }
  return ref.watch(analyticsApiProvider).researchComparison();
});
