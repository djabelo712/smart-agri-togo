// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cell_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FieldCell _$FieldCellFromJson(Map<String, dynamic> json) {
  return _FieldCell.fromJson(json);
}

/// @nodoc
mixin _$FieldCell {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'soil_moisture')
  double get theta => throw _privateConstructorUsedError;
  @JsonKey(name: 'soil_temp_c')
  double? get soilTempC => throw _privateConstructorUsedError;
  @JsonKey(name: 'valve_open')
  bool get valveOpen => throw _privateConstructorUsedError;
  String get treatment => throw _privateConstructorUsedError;
  String get crop => throw _privateConstructorUsedError;
  @JsonKey(name: 'stress_ks')
  double get stressKs => throw _privateConstructorUsedError;
  @IsoDateTimeNullableConverter()
  @JsonKey(name: 'last_irrigated_at')
  DateTime? get lastIrrigatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cumulative_irrigation_mm')
  double get cumulativeIrrigationMm => throw _privateConstructorUsedError;

  /// Serializes this FieldCell to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldCellCopyWith<FieldCell> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldCellCopyWith<$Res> {
  factory $FieldCellCopyWith(FieldCell value, $Res Function(FieldCell) then) =
      _$FieldCellCopyWithImpl<$Res, FieldCell>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'soil_moisture') double theta,
    @JsonKey(name: 'soil_temp_c') double? soilTempC,
    @JsonKey(name: 'valve_open') bool valveOpen,
    String treatment,
    String crop,
    @JsonKey(name: 'stress_ks') double stressKs,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_irrigated_at')
    DateTime? lastIrrigatedAt,
    @JsonKey(name: 'cumulative_irrigation_mm') double cumulativeIrrigationMm,
  });
}

/// @nodoc
class _$FieldCellCopyWithImpl<$Res, $Val extends FieldCell>
    implements $FieldCellCopyWith<$Res> {
  _$FieldCellCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? theta = null,
    Object? soilTempC = freezed,
    Object? valveOpen = null,
    Object? treatment = null,
    Object? crop = null,
    Object? stressKs = null,
    Object? lastIrrigatedAt = freezed,
    Object? cumulativeIrrigationMm = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            theta:
                null == theta
                    ? _value.theta
                    : theta // ignore: cast_nullable_to_non_nullable
                        as double,
            soilTempC:
                freezed == soilTempC
                    ? _value.soilTempC
                    : soilTempC // ignore: cast_nullable_to_non_nullable
                        as double?,
            valveOpen:
                null == valveOpen
                    ? _value.valveOpen
                    : valveOpen // ignore: cast_nullable_to_non_nullable
                        as bool,
            treatment:
                null == treatment
                    ? _value.treatment
                    : treatment // ignore: cast_nullable_to_non_nullable
                        as String,
            crop:
                null == crop
                    ? _value.crop
                    : crop // ignore: cast_nullable_to_non_nullable
                        as String,
            stressKs:
                null == stressKs
                    ? _value.stressKs
                    : stressKs // ignore: cast_nullable_to_non_nullable
                        as double,
            lastIrrigatedAt:
                freezed == lastIrrigatedAt
                    ? _value.lastIrrigatedAt
                    : lastIrrigatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            cumulativeIrrigationMm:
                null == cumulativeIrrigationMm
                    ? _value.cumulativeIrrigationMm
                    : cumulativeIrrigationMm // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldCellImplCopyWith<$Res>
    implements $FieldCellCopyWith<$Res> {
  factory _$$FieldCellImplCopyWith(
    _$FieldCellImpl value,
    $Res Function(_$FieldCellImpl) then,
  ) = __$$FieldCellImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'soil_moisture') double theta,
    @JsonKey(name: 'soil_temp_c') double? soilTempC,
    @JsonKey(name: 'valve_open') bool valveOpen,
    String treatment,
    String crop,
    @JsonKey(name: 'stress_ks') double stressKs,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_irrigated_at')
    DateTime? lastIrrigatedAt,
    @JsonKey(name: 'cumulative_irrigation_mm') double cumulativeIrrigationMm,
  });
}

/// @nodoc
class __$$FieldCellImplCopyWithImpl<$Res>
    extends _$FieldCellCopyWithImpl<$Res, _$FieldCellImpl>
    implements _$$FieldCellImplCopyWith<$Res> {
  __$$FieldCellImplCopyWithImpl(
    _$FieldCellImpl _value,
    $Res Function(_$FieldCellImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? theta = null,
    Object? soilTempC = freezed,
    Object? valveOpen = null,
    Object? treatment = null,
    Object? crop = null,
    Object? stressKs = null,
    Object? lastIrrigatedAt = freezed,
    Object? cumulativeIrrigationMm = null,
  }) {
    return _then(
      _$FieldCellImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        theta:
            null == theta
                ? _value.theta
                : theta // ignore: cast_nullable_to_non_nullable
                    as double,
        soilTempC:
            freezed == soilTempC
                ? _value.soilTempC
                : soilTempC // ignore: cast_nullable_to_non_nullable
                    as double?,
        valveOpen:
            null == valveOpen
                ? _value.valveOpen
                : valveOpen // ignore: cast_nullable_to_non_nullable
                    as bool,
        treatment:
            null == treatment
                ? _value.treatment
                : treatment // ignore: cast_nullable_to_non_nullable
                    as String,
        crop:
            null == crop
                ? _value.crop
                : crop // ignore: cast_nullable_to_non_nullable
                    as String,
        stressKs:
            null == stressKs
                ? _value.stressKs
                : stressKs // ignore: cast_nullable_to_non_nullable
                    as double,
        lastIrrigatedAt:
            freezed == lastIrrigatedAt
                ? _value.lastIrrigatedAt
                : lastIrrigatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        cumulativeIrrigationMm:
            null == cumulativeIrrigationMm
                ? _value.cumulativeIrrigationMm
                : cumulativeIrrigationMm // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldCellImpl implements _FieldCell {
  const _$FieldCellImpl({
    required this.id,
    @JsonKey(name: 'soil_moisture') required this.theta,
    @JsonKey(name: 'soil_temp_c') this.soilTempC,
    @JsonKey(name: 'valve_open') this.valveOpen = false,
    required this.treatment,
    required this.crop,
    @JsonKey(name: 'stress_ks') required this.stressKs,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_irrigated_at')
    this.lastIrrigatedAt,
    @JsonKey(name: 'cumulative_irrigation_mm')
    this.cumulativeIrrigationMm = 0.0,
  });

  factory _$FieldCellImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldCellImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'soil_moisture')
  final double theta;
  @override
  @JsonKey(name: 'soil_temp_c')
  final double? soilTempC;
  @override
  @JsonKey(name: 'valve_open')
  final bool valveOpen;
  @override
  final String treatment;
  @override
  final String crop;
  @override
  @JsonKey(name: 'stress_ks')
  final double stressKs;
  @override
  @IsoDateTimeNullableConverter()
  @JsonKey(name: 'last_irrigated_at')
  final DateTime? lastIrrigatedAt;
  @override
  @JsonKey(name: 'cumulative_irrigation_mm')
  final double cumulativeIrrigationMm;

  @override
  String toString() {
    return 'FieldCell(id: $id, theta: $theta, soilTempC: $soilTempC, valveOpen: $valveOpen, treatment: $treatment, crop: $crop, stressKs: $stressKs, lastIrrigatedAt: $lastIrrigatedAt, cumulativeIrrigationMm: $cumulativeIrrigationMm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldCellImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.theta, theta) || other.theta == theta) &&
            (identical(other.soilTempC, soilTempC) ||
                other.soilTempC == soilTempC) &&
            (identical(other.valveOpen, valveOpen) ||
                other.valveOpen == valveOpen) &&
            (identical(other.treatment, treatment) ||
                other.treatment == treatment) &&
            (identical(other.crop, crop) || other.crop == crop) &&
            (identical(other.stressKs, stressKs) ||
                other.stressKs == stressKs) &&
            (identical(other.lastIrrigatedAt, lastIrrigatedAt) ||
                other.lastIrrigatedAt == lastIrrigatedAt) &&
            (identical(other.cumulativeIrrigationMm, cumulativeIrrigationMm) ||
                other.cumulativeIrrigationMm == cumulativeIrrigationMm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    theta,
    soilTempC,
    valveOpen,
    treatment,
    crop,
    stressKs,
    lastIrrigatedAt,
    cumulativeIrrigationMm,
  );

  /// Create a copy of FieldCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldCellImplCopyWith<_$FieldCellImpl> get copyWith =>
      __$$FieldCellImplCopyWithImpl<_$FieldCellImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldCellImplToJson(this);
  }
}

abstract class _FieldCell implements FieldCell {
  const factory _FieldCell({
    required final String id,
    @JsonKey(name: 'soil_moisture') required final double theta,
    @JsonKey(name: 'soil_temp_c') final double? soilTempC,
    @JsonKey(name: 'valve_open') final bool valveOpen,
    required final String treatment,
    required final String crop,
    @JsonKey(name: 'stress_ks') required final double stressKs,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_irrigated_at')
    final DateTime? lastIrrigatedAt,
    @JsonKey(name: 'cumulative_irrigation_mm')
    final double cumulativeIrrigationMm,
  }) = _$FieldCellImpl;

  factory _FieldCell.fromJson(Map<String, dynamic> json) =
      _$FieldCellImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'soil_moisture')
  double get theta;
  @override
  @JsonKey(name: 'soil_temp_c')
  double? get soilTempC;
  @override
  @JsonKey(name: 'valve_open')
  bool get valveOpen;
  @override
  String get treatment;
  @override
  String get crop;
  @override
  @JsonKey(name: 'stress_ks')
  double get stressKs;
  @override
  @IsoDateTimeNullableConverter()
  @JsonKey(name: 'last_irrigated_at')
  DateTime? get lastIrrigatedAt;
  @override
  @JsonKey(name: 'cumulative_irrigation_mm')
  double get cumulativeIrrigationMm;

  /// Create a copy of FieldCell
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldCellImplCopyWith<_$FieldCellImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
