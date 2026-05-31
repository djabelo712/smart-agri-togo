import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/api_datasource.dart';
import '../data/models/history_model.dart';
import 'api_provider.dart';
import 'field_provider.dart';
import 'ml_provider.dart';

final dailyHistoryStreamProvider = StreamProvider<List<DailyHistory>>((ref) {
  return ref.watch(fieldRepositoryProvider).watchDailyHistory();
});

final analyticsApiProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(apiDatasourceProvider));
});

/// Accès API pour onglets non modifiés (historique, recherche).
class AnalyticsRepository {
  AnalyticsRepository(this._api);

  final ApiDatasource _api;

  Future<Map<String, dynamic>> researchComparison() =>
      _api.getResearchComparison();

  Future<List<DailyHistory>> dailyHistory({int days = 30}) =>
      _api.getDailyHistory(days: days);
}

final yieldForecastProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  if (!ref.watch(useLiveApiProvider)) return {};
  return ref.watch(fullFieldYieldProvider.future);
});

final researchComparisonProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  if (!ref.watch(useLiveApiProvider)) {
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
