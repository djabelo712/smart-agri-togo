import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/api_datasource.dart';
import '../data/models/alert_model.dart';
import '../data/repositories/control_repository.dart';
import 'api_provider.dart';
import 'field_provider.dart';

final alertsStreamProvider = StreamProvider<List<FarmAlert>>((ref) {
  return ref.watch(fieldRepositoryProvider).watchAlerts();
});

final unreadAlertsProvider = Provider<List<FarmAlert>>((ref) {
  final alerts = ref.watch(alertsStreamProvider);
  return alerts.maybeWhen(
    data: (list) =>
        list.where((a) => !a.acknowledged).toList(growable: false),
    orElse: () => [],
  );
});

final criticalAlertProvider = Provider<FarmAlert?>((ref) {
  final unread = ref.watch(unreadAlertsProvider);
  final critical = unread.where((a) => a.severity == 'critical').toList();
  if (critical.isEmpty) {
    final warnings = unread.where((a) => a.severity == 'warning').toList();
    return warnings.isEmpty ? null : warnings.first;
  }
  return critical.first;
});

final controlRepositoryProvider = Provider<ControlRepository>((ref) {
  return ControlRepository(api: ref.watch(apiDatasourceProvider));
});

final alertActionsProvider = Provider<AlertActions>((ref) {
  return AlertActions(ref.watch(apiDatasourceProvider));
});

class AlertActions {
  AlertActions(this._api);

  final ApiDatasource _api;

  Future<void> acknowledge(String id) => _api.acknowledgeAlert(id);
}
