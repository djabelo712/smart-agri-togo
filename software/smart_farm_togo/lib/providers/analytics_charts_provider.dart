import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/analytics_mock.dart';
import 'field_provider.dart';
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

final cropYieldsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  ref.watch(demoModeProvider);
  return AnalyticsMock.cropYields;
});

final estimatedRevenueProvider = Provider<double>((ref) {
  ref.watch(demoModeProvider);
  return AnalyticsMock.estimatedNetRevenueFcfa;
});

final hydricSatisfactionProvider = Provider<double>((ref) {
  final avgKs = ref.watch(avgFieldStressKsProvider);
  return avgKs.clamp(0.0, 1.0);
});
