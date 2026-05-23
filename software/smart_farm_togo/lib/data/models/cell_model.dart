import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'cell_model.freezed.dart';
part 'cell_model.g.dart';

@freezed
class FieldCell with _$FieldCell {
  const factory FieldCell({
    required String id,
    @JsonKey(name: 'soil_moisture') required double theta,
    @JsonKey(name: 'soil_temp_c') double? soilTempC,
    @JsonKey(name: 'valve_open') @Default(false) bool valveOpen,
    required String treatment,
    required String crop,
    @JsonKey(name: 'stress_ks') required double stressKs,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_irrigated_at')
    DateTime? lastIrrigatedAt,
    @JsonKey(name: 'cumulative_irrigation_mm')
    @Default(0.0)
    double cumulativeIrrigationMm,
  }) = _FieldCell;

  factory FieldCell.fromJson(String id, Map<String, dynamic> json) =>
      _$FieldCellFromJson(<String, dynamic>{'id': id, ...json});

  factory FieldCell.fromJsonMap(Map<String, dynamic> json) =>
      FieldCell.fromJson(json['id'] as String, json);
}
