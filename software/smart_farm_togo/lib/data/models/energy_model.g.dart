// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnergyStatusImpl _$$EnergyStatusImplFromJson(Map<String, dynamic> json) =>
    _$EnergyStatusImpl(
      batterySocPct: (json['battery_soc_pct'] as num).toDouble(),
      solarPowerW: (json['solar_power_w'] as num).toDouble(),
      loadPowerW: (json['load_power_w'] as num).toDouble(),
      dailyGenerationKwh:
          (json['daily_generation_kwh'] as num?)?.toDouble() ?? 0.0,
      dailyConsumptionKwh:
          (json['daily_consumption_kwh'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$EnergyStatusImplToJson(_$EnergyStatusImpl instance) =>
    <String, dynamic>{
      'battery_soc_pct': instance.batterySocPct,
      'solar_power_w': instance.solarPowerW,
      'load_power_w': instance.loadPowerW,
      'daily_generation_kwh': instance.dailyGenerationKwh,
      'daily_consumption_kwh': instance.dailyConsumptionKwh,
    };
