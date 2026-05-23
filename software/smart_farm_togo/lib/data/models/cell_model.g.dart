// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FieldCellImpl _$$FieldCellImplFromJson(Map<String, dynamic> json) =>
    _$FieldCellImpl(
      id: json['id'] as String,
      theta: (json['soil_moisture'] as num).toDouble(),
      soilTempC: (json['soil_temp_c'] as num?)?.toDouble(),
      valveOpen: json['valve_open'] as bool? ?? false,
      treatment: json['treatment'] as String,
      crop: json['crop'] as String,
      stressKs: (json['stress_ks'] as num).toDouble(),
      lastIrrigatedAt: const IsoDateTimeNullableConverter().fromJson(
        json['last_irrigated_at'],
      ),
      cumulativeIrrigationMm:
          (json['cumulative_irrigation_mm'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$FieldCellImplToJson(_$FieldCellImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'soil_moisture': instance.theta,
      'soil_temp_c': instance.soilTempC,
      'valve_open': instance.valveOpen,
      'treatment': instance.treatment,
      'crop': instance.crop,
      'stress_ks': instance.stressKs,
      'last_irrigated_at': const IsoDateTimeNullableConverter().toJson(
        instance.lastIrrigatedAt,
      ),
      'cumulative_irrigation_mm': instance.cumulativeIrrigationMm,
    };
