// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'energy_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EnergyStatus _$EnergyStatusFromJson(Map<String, dynamic> json) {
  return _EnergyStatus.fromJson(json);
}

/// @nodoc
mixin _$EnergyStatus {
  @JsonKey(name: 'battery_soc_pct')
  double get batterySocPct => throw _privateConstructorUsedError;
  @JsonKey(name: 'solar_power_w')
  double get solarPowerW => throw _privateConstructorUsedError;
  @JsonKey(name: 'load_power_w')
  double get loadPowerW => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_generation_kwh')
  double get dailyGenerationKwh => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_consumption_kwh')
  double get dailyConsumptionKwh => throw _privateConstructorUsedError;

  /// Serializes this EnergyStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnergyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnergyStatusCopyWith<EnergyStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnergyStatusCopyWith<$Res> {
  factory $EnergyStatusCopyWith(
    EnergyStatus value,
    $Res Function(EnergyStatus) then,
  ) = _$EnergyStatusCopyWithImpl<$Res, EnergyStatus>;
  @useResult
  $Res call({
    @JsonKey(name: 'battery_soc_pct') double batterySocPct,
    @JsonKey(name: 'solar_power_w') double solarPowerW,
    @JsonKey(name: 'load_power_w') double loadPowerW,
    @JsonKey(name: 'daily_generation_kwh') double dailyGenerationKwh,
    @JsonKey(name: 'daily_consumption_kwh') double dailyConsumptionKwh,
  });
}

/// @nodoc
class _$EnergyStatusCopyWithImpl<$Res, $Val extends EnergyStatus>
    implements $EnergyStatusCopyWith<$Res> {
  _$EnergyStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnergyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batterySocPct = null,
    Object? solarPowerW = null,
    Object? loadPowerW = null,
    Object? dailyGenerationKwh = null,
    Object? dailyConsumptionKwh = null,
  }) {
    return _then(
      _value.copyWith(
            batterySocPct:
                null == batterySocPct
                    ? _value.batterySocPct
                    : batterySocPct // ignore: cast_nullable_to_non_nullable
                        as double,
            solarPowerW:
                null == solarPowerW
                    ? _value.solarPowerW
                    : solarPowerW // ignore: cast_nullable_to_non_nullable
                        as double,
            loadPowerW:
                null == loadPowerW
                    ? _value.loadPowerW
                    : loadPowerW // ignore: cast_nullable_to_non_nullable
                        as double,
            dailyGenerationKwh:
                null == dailyGenerationKwh
                    ? _value.dailyGenerationKwh
                    : dailyGenerationKwh // ignore: cast_nullable_to_non_nullable
                        as double,
            dailyConsumptionKwh:
                null == dailyConsumptionKwh
                    ? _value.dailyConsumptionKwh
                    : dailyConsumptionKwh // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnergyStatusImplCopyWith<$Res>
    implements $EnergyStatusCopyWith<$Res> {
  factory _$$EnergyStatusImplCopyWith(
    _$EnergyStatusImpl value,
    $Res Function(_$EnergyStatusImpl) then,
  ) = __$$EnergyStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'battery_soc_pct') double batterySocPct,
    @JsonKey(name: 'solar_power_w') double solarPowerW,
    @JsonKey(name: 'load_power_w') double loadPowerW,
    @JsonKey(name: 'daily_generation_kwh') double dailyGenerationKwh,
    @JsonKey(name: 'daily_consumption_kwh') double dailyConsumptionKwh,
  });
}

/// @nodoc
class __$$EnergyStatusImplCopyWithImpl<$Res>
    extends _$EnergyStatusCopyWithImpl<$Res, _$EnergyStatusImpl>
    implements _$$EnergyStatusImplCopyWith<$Res> {
  __$$EnergyStatusImplCopyWithImpl(
    _$EnergyStatusImpl _value,
    $Res Function(_$EnergyStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnergyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batterySocPct = null,
    Object? solarPowerW = null,
    Object? loadPowerW = null,
    Object? dailyGenerationKwh = null,
    Object? dailyConsumptionKwh = null,
  }) {
    return _then(
      _$EnergyStatusImpl(
        batterySocPct:
            null == batterySocPct
                ? _value.batterySocPct
                : batterySocPct // ignore: cast_nullable_to_non_nullable
                    as double,
        solarPowerW:
            null == solarPowerW
                ? _value.solarPowerW
                : solarPowerW // ignore: cast_nullable_to_non_nullable
                    as double,
        loadPowerW:
            null == loadPowerW
                ? _value.loadPowerW
                : loadPowerW // ignore: cast_nullable_to_non_nullable
                    as double,
        dailyGenerationKwh:
            null == dailyGenerationKwh
                ? _value.dailyGenerationKwh
                : dailyGenerationKwh // ignore: cast_nullable_to_non_nullable
                    as double,
        dailyConsumptionKwh:
            null == dailyConsumptionKwh
                ? _value.dailyConsumptionKwh
                : dailyConsumptionKwh // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EnergyStatusImpl implements _EnergyStatus {
  const _$EnergyStatusImpl({
    @JsonKey(name: 'battery_soc_pct') required this.batterySocPct,
    @JsonKey(name: 'solar_power_w') required this.solarPowerW,
    @JsonKey(name: 'load_power_w') required this.loadPowerW,
    @JsonKey(name: 'daily_generation_kwh') this.dailyGenerationKwh = 0.0,
    @JsonKey(name: 'daily_consumption_kwh') this.dailyConsumptionKwh = 0.0,
  });

  factory _$EnergyStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnergyStatusImplFromJson(json);

  @override
  @JsonKey(name: 'battery_soc_pct')
  final double batterySocPct;
  @override
  @JsonKey(name: 'solar_power_w')
  final double solarPowerW;
  @override
  @JsonKey(name: 'load_power_w')
  final double loadPowerW;
  @override
  @JsonKey(name: 'daily_generation_kwh')
  final double dailyGenerationKwh;
  @override
  @JsonKey(name: 'daily_consumption_kwh')
  final double dailyConsumptionKwh;

  @override
  String toString() {
    return 'EnergyStatus(batterySocPct: $batterySocPct, solarPowerW: $solarPowerW, loadPowerW: $loadPowerW, dailyGenerationKwh: $dailyGenerationKwh, dailyConsumptionKwh: $dailyConsumptionKwh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnergyStatusImpl &&
            (identical(other.batterySocPct, batterySocPct) ||
                other.batterySocPct == batterySocPct) &&
            (identical(other.solarPowerW, solarPowerW) ||
                other.solarPowerW == solarPowerW) &&
            (identical(other.loadPowerW, loadPowerW) ||
                other.loadPowerW == loadPowerW) &&
            (identical(other.dailyGenerationKwh, dailyGenerationKwh) ||
                other.dailyGenerationKwh == dailyGenerationKwh) &&
            (identical(other.dailyConsumptionKwh, dailyConsumptionKwh) ||
                other.dailyConsumptionKwh == dailyConsumptionKwh));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    batterySocPct,
    solarPowerW,
    loadPowerW,
    dailyGenerationKwh,
    dailyConsumptionKwh,
  );

  /// Create a copy of EnergyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnergyStatusImplCopyWith<_$EnergyStatusImpl> get copyWith =>
      __$$EnergyStatusImplCopyWithImpl<_$EnergyStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnergyStatusImplToJson(this);
  }
}

abstract class _EnergyStatus implements EnergyStatus {
  const factory _EnergyStatus({
    @JsonKey(name: 'battery_soc_pct') required final double batterySocPct,
    @JsonKey(name: 'solar_power_w') required final double solarPowerW,
    @JsonKey(name: 'load_power_w') required final double loadPowerW,
    @JsonKey(name: 'daily_generation_kwh') final double dailyGenerationKwh,
    @JsonKey(name: 'daily_consumption_kwh') final double dailyConsumptionKwh,
  }) = _$EnergyStatusImpl;

  factory _EnergyStatus.fromJson(Map<String, dynamic> json) =
      _$EnergyStatusImpl.fromJson;

  @override
  @JsonKey(name: 'battery_soc_pct')
  double get batterySocPct;
  @override
  @JsonKey(name: 'solar_power_w')
  double get solarPowerW;
  @override
  @JsonKey(name: 'load_power_w')
  double get loadPowerW;
  @override
  @JsonKey(name: 'daily_generation_kwh')
  double get dailyGenerationKwh;
  @override
  @JsonKey(name: 'daily_consumption_kwh')
  double get dailyConsumptionKwh;

  /// Create a copy of EnergyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnergyStatusImplCopyWith<_$EnergyStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
