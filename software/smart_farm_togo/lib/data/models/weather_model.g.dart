// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherImpl _$$WeatherImplFromJson(Map<String, dynamic> json) =>
    _$WeatherImpl(
      timestamp: const IsoDateTimeConverter().fromJson(json['timestamp']),
      tempC: (json['temp_c'] as num).toDouble(),
      humidityPct: (json['humidity_pct'] as num).toDouble(),
      solarRadWm2: (json['solar_rad_wm2'] as num?)?.toDouble() ?? 0.0,
      windSpeedMs: (json['wind_speed_ms'] as num?)?.toDouble() ?? 0.0,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      et0MmDay: (json['et0_mm_day'] as num).toDouble(),
    );

Map<String, dynamic> _$$WeatherImplToJson(_$WeatherImpl instance) =>
    <String, dynamic>{
      'timestamp': const IsoDateTimeConverter().toJson(instance.timestamp),
      'temp_c': instance.tempC,
      'humidity_pct': instance.humidityPct,
      'solar_rad_wm2': instance.solarRadWm2,
      'wind_speed_ms': instance.windSpeedMs,
      'rainfall_mm': instance.rainfallMm,
      'et0_mm_day': instance.et0MmDay,
    };

_$FieldForecastImpl _$$FieldForecastImplFromJson(Map<String, dynamic> json) =>
    _$FieldForecastImpl(
      et0Next7Days:
          (json['et0_next_7_days'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      rainNext7Days:
          (json['rain_next_7_days'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FieldForecastImplToJson(_$FieldForecastImpl instance) =>
    <String, dynamic>{
      'et0_next_7_days': instance.et0Next7Days,
      'rain_next_7_days': instance.rainNext7Days,
    };
