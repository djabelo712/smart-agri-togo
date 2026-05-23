// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemStatusImpl _$$SystemStatusImplFromJson(Map<String, dynamic> json) =>
    _$SystemStatusImpl(
      pumpRunning: json['pump_running'] as bool? ?? false,
      controllerMode: json['controller_mode'] as String? ?? 'MPC',
      lastHeartbeat: const IsoDateTimeNullableConverter().fromJson(
        json['last_heartbeat'],
      ),
      activeValvesCount: (json['active_valves_count'] as num?)?.toInt() ?? 0,
      dailyWaterUsedMm:
          (json['daily_water_used_mm'] as num?)?.toDouble() ?? 0.0,
      dailyWaterBudgetMm:
          (json['daily_water_budget_mm'] as num?)?.toDouble() ?? 8.0,
    );

Map<String, dynamic> _$$SystemStatusImplToJson(_$SystemStatusImpl instance) =>
    <String, dynamic>{
      'pump_running': instance.pumpRunning,
      'controller_mode': instance.controllerMode,
      'last_heartbeat': const IsoDateTimeNullableConverter().toJson(
        instance.lastHeartbeat,
      ),
      'active_valves_count': instance.activeValvesCount,
      'daily_water_used_mm': instance.dailyWaterUsedMm,
      'daily_water_budget_mm': instance.dailyWaterBudgetMm,
    };
