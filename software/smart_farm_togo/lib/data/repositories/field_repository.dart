import 'package:firebase_database/firebase_database.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../datasources/firebase_datasource.dart';
import '../mock/mock_data.dart';
import '../models/alert_model.dart';
import '../models/cell_model.dart';
import '../models/energy_model.dart';
import '../models/history_model.dart';
import '../models/system_model.dart';
import '../models/weather_model.dart';

class FieldRepository {
  FieldRepository({
    FirebaseDatasource? firebase,
    required bool demoMode,
  })  : _firebase = firebase,
        _demoMode = demoMode || !firebaseAvailable;

  final FirebaseDatasource? _firebase;
  final bool _demoMode;

  static void enableOfflinePersistence() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.ref('farm/field').keepSynced(true);
  }

  bool get _useMock => _demoMode || _firebase == null;

  Stream<Map<String, FieldCell>> watchCells() {
    if (_useMock) return Stream.value(MockData.mockCellsMap);
    return _firebase!.watchAllCells();
  }

  Stream<Weather?> watchWeather() {
    if (_useMock) return Stream.value(MockData.mockWeather);
    return _firebase!.watchWeather();
  }

  Stream<FieldForecast?> watchForecast() {
    if (_useMock) return Stream.value(MockData.mockForecast);
    return _firebase!.watchForecast();
  }

  Stream<SystemStatus?> watchSystem() {
    if (_useMock) return Stream.value(MockData.mockSystem);
    return _firebase!.watchSystem();
  }

  Stream<EnergyStatus?> watchEnergy() {
    if (_useMock) return Stream.value(MockData.mockEnergy);
    return _firebase!.watchEnergy();
  }

  Stream<List<FarmAlert>> watchAlerts() {
    if (_useMock) return Stream.value(MockData.mockAlerts);
    return _firebase!.watchAlerts();
  }

  Stream<List<DailyHistory>> watchDailyHistory() {
    if (_useMock) return Stream.value(MockData.mockHistory);
    return _firebase!.watchDailyHistory();
  }
}
