import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'system_model.freezed.dart';
part 'system_model.g.dart';

@freezed
class SystemStatus with _$SystemStatus {
  const factory SystemStatus({
    @JsonKey(name: 'pump_running') @Default(false) bool pumpRunning,
    @JsonKey(name: 'controller_mode') @Default('MPC') String controllerMode,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_heartbeat')
    DateTime? lastHeartbeat,
    @JsonKey(name: 'active_valves_count') @Default(0) int activeValvesCount,
    @JsonKey(name: 'daily_water_used_mm') @Default(0.0) double dailyWaterUsedMm,
    @JsonKey(name: 'daily_water_budget_mm')
    @Default(8.0)
    double dailyWaterBudgetMm,
  }) = _SystemStatus;

  factory SystemStatus.fromJson(Map<String, dynamic> json) =>
      _$SystemStatusFromJson(json);
}
