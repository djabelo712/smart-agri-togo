import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/analytics_mock.dart';
import 'field_provider.dart';
import 'ml_provider.dart';
import 'settings_provider.dart';

final moistureHistory7DaysProvider = Provider<List<double>>((ref) {
  ref.watch(demoModeProvider);
  return AnalyticsMock.moistureAvg7Days;
});

final waterDaily7DaysProvider = Provider<List<double>>((ref) {
  ref.watch(demoModeProvider);
  return AnalyticsMock.waterDaily7Days;
});

final avgFieldStressKsProvider = Provider<double>((ref) {
  final cells = ref.watch(cellsListProvider);
  if (cells.isEmpty) return 0.85;
  return cells.map((c) => c.stressKs).reduce((a, b) => a + b) / cells.length;
});

final alertZonesCountProvider = Provider<int>((ref) {
  final cells = ref.watch(cellsListProvider);
  return cells.where((c) => c.stressKs < 0.5).length;
});

List<Map<String, dynamic>> _mockCropYields() => [
      {'crop': 'Oignon', 'yield_t_ha': 42.5, 'status': 'Excellent'},
      {'crop': 'Carotte', 'yield_t_ha': 33.1, 'status': 'Bon'},
      {'crop': 'Laitue', 'yield_t_ha': 28.5, 'status': 'Bon'},
      {'crop': 'Maïs', 'yield_t_ha': 7.5, 'status': 'Bon'},
    ];

/// Rendements agrégés par culture — Model 3.
final cropYieldsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final yieldAsync = ref.watch(fullFieldYieldProvider);
  return yieldAsync.when(
    data: (data) {
      if (data.isEmpty) return _mockCropYields();
      final byCrop = <String, List<double>>{};
      data.forEach((cellId, result) {
        if (result is! Map) return;
        final map = Map<String, dynamic>.from(result);
        final crop = map['crop'] as String? ?? '';
        final y = (map['predicted_yield_kgm2'] as num?)?.toDouble() ?? 0;
        if (crop.isEmpty) return;
        byCrop.putIfAbsent(crop, () => []).add(y);
      });
      if (byCrop.isEmpty) return _mockCropYields();
      return byCrop.entries.map((e) {
        final avg = e.value.reduce((a, b) => a + b) / e.value.length;
        String status;
        if (avg >= 3.5) {
          status = 'Excellent';
        } else if (avg >= 2.5) {
          status = 'Bon';
        } else if (avg >= 1.5) {
          status = 'Moyen';
        } else {
          status = 'Faible';
        }
        return {'crop': e.key, 'yield_t_ha': avg * 10, 'status': status};
      }).toList();
    },
    loading: _mockCropYields,
    error: (_, __) => _mockCropYields(),
  );
});

final estimatedRevenueProvider = Provider<double>((ref) {
  ref.watch(demoModeProvider);
  return AnalyticsMock.estimatedNetRevenueFcfa;
});

final hydricSatisfactionProvider = Provider<double>((ref) {
  final avgKs = ref.watch(avgFieldStressKsProvider);
  return avgKs.clamp(0.0, 1.0);
});
