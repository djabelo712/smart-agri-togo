import '../datasources/api_datasource.dart';

class ControlRepository {
  ControlRepository({required ApiDatasource api}) : _api = api;

  final ApiDatasource _api;

  Future<void> openValve(String cellId, {int durationMin = 15}) =>
      _api.controlValve(cell: cellId, action: 'open', durationMin: durationMin);

  Future<void> closeValve(String cellId) =>
      _api.controlValve(cell: cellId, action: 'close');

  Future<void> startPump({int durationMin = 30}) =>
      _api.controlPump(action: 'start', durationMin: durationMin);

  Future<void> stopPump() => _api.controlPump(action: 'stop');

  Future<void> setMode(String mode) => _api.setControllerMode(mode);

  Future<void> closeAllValves(List<String> openCellIds) async {
    for (final id in openCellIds) {
      await closeValve(id);
    }
  }
}
