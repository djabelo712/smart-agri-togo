import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/firebase_paths.dart';
import '../models/alert_model.dart';
import '../models/cell_model.dart';
import '../models/energy_model.dart';
import '../models/history_model.dart';
import '../models/system_model.dart';
import '../models/weather_model.dart';

/// Accès Firebase RTDB — un seul listener pour `/farm/field/cells`.
class FirebaseDatasource {
  FirebaseDatasource({FirebaseDatabase? database})
      : _db = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _db;

  DatabaseReference get _root => _db.ref();

  /// Listener unique sur toutes les cellules.
  Stream<Map<String, FieldCell>> watchAllCells() {
    return _root.child(FirebasePaths.cells).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return <String, FieldCell>{};
      final raw = Map<String, dynamic>.from(value as Map);
      return raw.map(
        (k, v) => MapEntry(
          k,
          FieldCell.fromJson(k, Map<String, dynamic>.from(v as Map)),
        ),
      );
    });
  }

  Stream<Weather?> watchWeather() {
    return _root.child(FirebasePaths.weather).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return Weather.fromJson(Map<String, dynamic>.from(value as Map));
    });
  }

  Stream<SystemStatus?> watchSystem() {
    return _root.child(FirebasePaths.system).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return SystemStatus.fromJson(Map<String, dynamic>.from(value as Map));
    });
  }

  Stream<EnergyStatus?> watchEnergy() {
    return _root.child(FirebasePaths.energy).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return EnergyStatus.fromJson(Map<String, dynamic>.from(value as Map));
    });
  }

  Stream<FieldForecast?> watchForecast() {
    return _root.child(FirebasePaths.forecast).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return FieldForecast.fromJson(Map<String, dynamic>.from(value as Map));
    });
  }

  Stream<List<FarmAlert>> watchAlerts() {
    return _root.child(FirebasePaths.alerts).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return <FarmAlert>[];
      final raw = Map<String, dynamic>.from(value as Map);
      return raw.entries
          .map(
            (e) => FarmAlert.fromJson(
              e.key,
              Map<String, dynamic>.from(e.value as Map),
            ),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Stream<List<DailyHistory>> watchDailyHistory() {
    return _root.child(FirebasePaths.historyDaily).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return <DailyHistory>[];
      final raw = Map<String, dynamic>.from(value as Map);
      return raw.entries
          .map(
            (e) => DailyHistory.fromJson(
              e.key,
              Map<String, dynamic>.from(e.value as Map),
            ),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }
}
