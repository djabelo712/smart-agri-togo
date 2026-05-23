// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FarmAlertImpl _$$FarmAlertImplFromJson(Map<String, dynamic> json) =>
    _$FarmAlertImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      cell: json['cell'] as String?,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: const IsoDateTimeConverter().fromJson(json['timestamp']),
      acknowledged: json['acknowledged'] as bool? ?? false,
    );

Map<String, dynamic> _$$FarmAlertImplToJson(_$FarmAlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'cell': instance.cell,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': const IsoDateTimeConverter().toJson(instance.timestamp),
      'acknowledged': instance.acknowledged,
    };
