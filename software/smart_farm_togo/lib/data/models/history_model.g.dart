// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyHistoryImpl _$$DailyHistoryImplFromJson(Map<String, dynamic> json) =>
    _$DailyHistoryImpl(
      date: json['date'] as String,
      totalIrrigationMm: (json['total_irrigation_mm'] as num).toDouble(),
      avgStressKs: (json['avg_stress_ks'] as num).toDouble(),
      et0Mm: (json['et0_mm'] as num).toDouble(),
      rainMm: (json['rain_mm'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DailyHistoryImplToJson(_$DailyHistoryImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'total_irrigation_mm': instance.totalIrrigationMm,
      'avg_stress_ks': instance.avgStressKs,
      'et0_mm': instance.et0Mm,
      'rain_mm': instance.rainMm,
    };
