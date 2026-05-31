import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_provider.dart';
import 'field_provider.dart';

/// Prédictions ML distantes (Models 1–3) avec repli mock si API inactive.

/// ET₀ du jour — Model 1 (XGBoost).
final et0TodayProvider = FutureProvider.autoDispose<double>((ref) async {
  if (!ref.watch(useLiveApiProvider)) return 4.2;
  final api = ref.watch(apiDatasourceProvider);
  try {
    return await api.getEt0Today();
  } catch (_) {
    return 4.2;
  }
});

Map<String, dynamic> _mockEt0Forecast() => {
      'et0_7days': [4.2, 4.5, 3.9, 4.7, 4.3, 4.1, 4.6],
      'rain_7days': [0.0, 0.0, 2.1, 0.0, 0.0, 0.0, 0.0],
      'dates': List.generate(
        7,
        (i) => DateTime.now()
            .add(Duration(days: i + 1))
            .toIso8601String()
            .substring(0, 10),
      ),
    };

/// Prévision 7 jours ET₀ + pluie — Model 2.
final et0ForecastProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  if (!ref.watch(useLiveApiProvider)) return _mockEt0Forecast();
  final api = ref.watch(apiDatasourceProvider);
  try {
    return await api.getEt0Forecast();
  } catch (_) {
    return _mockEt0Forecast();
  }
});

/// Rendement par zone — Model 3 (Random Forest).
final fullFieldYieldProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  if (!ref.watch(useLiveApiProvider)) return {};
  final api = ref.watch(apiDatasourceProvider);
  final cells = ref.watch(cellsListProvider);
  if (cells.isEmpty) return {};
  try {
    final ksSensors = <String, List<double>>{};
    for (final cell in cells) {
      final ks = cell.stressKs.clamp(0.3, 1.0);
      ksSensors[cell.id] = List.generate(
        60,
        (i) => (ks + (i % 7 - 3) * 0.02).clamp(0.3, 1.0),
      );
    }
    return await api.getFullFieldYieldForecast(ksSensors);
  } catch (_) {
    return {};
  }
});
