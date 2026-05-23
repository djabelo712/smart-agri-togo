// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemStatus _$SystemStatusFromJson(Map<String, dynamic> json) {
  return _SystemStatus.fromJson(json);
}

/// @nodoc
mixin _$SystemStatus {
  @JsonKey(name: 'pump_running')
  bool get pumpRunning => throw _privateConstructorUsedError;
  @JsonKey(name: 'controller_mode')
  String get controllerMode => throw _privateConstructorUsedError;
  @IsoDateTimeNullableConverter()
  @JsonKey(name: 'last_heartbeat')
  DateTime? get lastHeartbeat => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_valves_count')
  int get activeValvesCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_water_used_mm')
  double get dailyWaterUsedMm => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_water_budget_mm')
  double get dailyWaterBudgetMm => throw _privateConstructorUsedError;

  /// Serializes this SystemStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemStatusCopyWith<SystemStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemStatusCopyWith<$Res> {
  factory $SystemStatusCopyWith(
    SystemStatus value,
    $Res Function(SystemStatus) then,
  ) = _$SystemStatusCopyWithImpl<$Res, SystemStatus>;
  @useResult
  $Res call({
    @JsonKey(name: 'pump_running') bool pumpRunning,
    @JsonKey(name: 'controller_mode') String controllerMode,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_heartbeat')
    DateTime? lastHeartbeat,
    @JsonKey(name: 'active_valves_count') int activeValvesCount,
    @JsonKey(name: 'daily_water_used_mm') double dailyWaterUsedMm,
    @JsonKey(name: 'daily_water_budget_mm') double dailyWaterBudgetMm,
  });
}

/// @nodoc
class _$SystemStatusCopyWithImpl<$Res, $Val extends SystemStatus>
    implements $SystemStatusCopyWith<$Res> {
  _$SystemStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pumpRunning = null,
    Object? controllerMode = null,
    Object? lastHeartbeat = freezed,
    Object? activeValvesCount = null,
    Object? dailyWaterUsedMm = null,
    Object? dailyWaterBudgetMm = null,
  }) {
    return _then(
      _value.copyWith(
            pumpRunning:
                null == pumpRunning
                    ? _value.pumpRunning
                    : pumpRunning // ignore: cast_nullable_to_non_nullable
                        as bool,
            controllerMode:
                null == controllerMode
                    ? _value.controllerMode
                    : controllerMode // ignore: cast_nullable_to_non_nullable
                        as String,
            lastHeartbeat:
                freezed == lastHeartbeat
                    ? _value.lastHeartbeat
                    : lastHeartbeat // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            activeValvesCount:
                null == activeValvesCount
                    ? _value.activeValvesCount
                    : activeValvesCount // ignore: cast_nullable_to_non_nullable
                        as int,
            dailyWaterUsedMm:
                null == dailyWaterUsedMm
                    ? _value.dailyWaterUsedMm
                    : dailyWaterUsedMm // ignore: cast_nullable_to_non_nullable
                        as double,
            dailyWaterBudgetMm:
                null == dailyWaterBudgetMm
                    ? _value.dailyWaterBudgetMm
                    : dailyWaterBudgetMm // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemStatusImplCopyWith<$Res>
    implements $SystemStatusCopyWith<$Res> {
  factory _$$SystemStatusImplCopyWith(
    _$SystemStatusImpl value,
    $Res Function(_$SystemStatusImpl) then,
  ) = __$$SystemStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pump_running') bool pumpRunning,
    @JsonKey(name: 'controller_mode') String controllerMode,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_heartbeat')
    DateTime? lastHeartbeat,
    @JsonKey(name: 'active_valves_count') int activeValvesCount,
    @JsonKey(name: 'daily_water_used_mm') double dailyWaterUsedMm,
    @JsonKey(name: 'daily_water_budget_mm') double dailyWaterBudgetMm,
  });
}

/// @nodoc
class __$$SystemStatusImplCopyWithImpl<$Res>
    extends _$SystemStatusCopyWithImpl<$Res, _$SystemStatusImpl>
    implements _$$SystemStatusImplCopyWith<$Res> {
  __$$SystemStatusImplCopyWithImpl(
    _$SystemStatusImpl _value,
    $Res Function(_$SystemStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pumpRunning = null,
    Object? controllerMode = null,
    Object? lastHeartbeat = freezed,
    Object? activeValvesCount = null,
    Object? dailyWaterUsedMm = null,
    Object? dailyWaterBudgetMm = null,
  }) {
    return _then(
      _$SystemStatusImpl(
        pumpRunning:
            null == pumpRunning
                ? _value.pumpRunning
                : pumpRunning // ignore: cast_nullable_to_non_nullable
                    as bool,
        controllerMode:
            null == controllerMode
                ? _value.controllerMode
                : controllerMode // ignore: cast_nullable_to_non_nullable
                    as String,
        lastHeartbeat:
            freezed == lastHeartbeat
                ? _value.lastHeartbeat
                : lastHeartbeat // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        activeValvesCount:
            null == activeValvesCount
                ? _value.activeValvesCount
                : activeValvesCount // ignore: cast_nullable_to_non_nullable
                    as int,
        dailyWaterUsedMm:
            null == dailyWaterUsedMm
                ? _value.dailyWaterUsedMm
                : dailyWaterUsedMm // ignore: cast_nullable_to_non_nullable
                    as double,
        dailyWaterBudgetMm:
            null == dailyWaterBudgetMm
                ? _value.dailyWaterBudgetMm
                : dailyWaterBudgetMm // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemStatusImpl implements _SystemStatus {
  const _$SystemStatusImpl({
    @JsonKey(name: 'pump_running') this.pumpRunning = false,
    @JsonKey(name: 'controller_mode') this.controllerMode = 'MPC',
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_heartbeat')
    this.lastHeartbeat,
    @JsonKey(name: 'active_valves_count') this.activeValvesCount = 0,
    @JsonKey(name: 'daily_water_used_mm') this.dailyWaterUsedMm = 0.0,
    @JsonKey(name: 'daily_water_budget_mm') this.dailyWaterBudgetMm = 8.0,
  });

  factory _$SystemStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemStatusImplFromJson(json);

  @override
  @JsonKey(name: 'pump_running')
  final bool pumpRunning;
  @override
  @JsonKey(name: 'controller_mode')
  final String controllerMode;
  @override
  @IsoDateTimeNullableConverter()
  @JsonKey(name: 'last_heartbeat')
  final DateTime? lastHeartbeat;
  @override
  @JsonKey(name: 'active_valves_count')
  final int activeValvesCount;
  @override
  @JsonKey(name: 'daily_water_used_mm')
  final double dailyWaterUsedMm;
  @override
  @JsonKey(name: 'daily_water_budget_mm')
  final double dailyWaterBudgetMm;

  @override
  String toString() {
    return 'SystemStatus(pumpRunning: $pumpRunning, controllerMode: $controllerMode, lastHeartbeat: $lastHeartbeat, activeValvesCount: $activeValvesCount, dailyWaterUsedMm: $dailyWaterUsedMm, dailyWaterBudgetMm: $dailyWaterBudgetMm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemStatusImpl &&
            (identical(other.pumpRunning, pumpRunning) ||
                other.pumpRunning == pumpRunning) &&
            (identical(other.controllerMode, controllerMode) ||
                other.controllerMode == controllerMode) &&
            (identical(other.lastHeartbeat, lastHeartbeat) ||
                other.lastHeartbeat == lastHeartbeat) &&
            (identical(other.activeValvesCount, activeValvesCount) ||
                other.activeValvesCount == activeValvesCount) &&
            (identical(other.dailyWaterUsedMm, dailyWaterUsedMm) ||
                other.dailyWaterUsedMm == dailyWaterUsedMm) &&
            (identical(other.dailyWaterBudgetMm, dailyWaterBudgetMm) ||
                other.dailyWaterBudgetMm == dailyWaterBudgetMm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pumpRunning,
    controllerMode,
    lastHeartbeat,
    activeValvesCount,
    dailyWaterUsedMm,
    dailyWaterBudgetMm,
  );

  /// Create a copy of SystemStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemStatusImplCopyWith<_$SystemStatusImpl> get copyWith =>
      __$$SystemStatusImplCopyWithImpl<_$SystemStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemStatusImplToJson(this);
  }
}

abstract class _SystemStatus implements SystemStatus {
  const factory _SystemStatus({
    @JsonKey(name: 'pump_running') final bool pumpRunning,
    @JsonKey(name: 'controller_mode') final String controllerMode,
    @IsoDateTimeNullableConverter()
    @JsonKey(name: 'last_heartbeat')
    final DateTime? lastHeartbeat,
    @JsonKey(name: 'active_valves_count') final int activeValvesCount,
    @JsonKey(name: 'daily_water_used_mm') final double dailyWaterUsedMm,
    @JsonKey(name: 'daily_water_budget_mm') final double dailyWaterBudgetMm,
  }) = _$SystemStatusImpl;

  factory _SystemStatus.fromJson(Map<String, dynamic> json) =
      _$SystemStatusImpl.fromJson;

  @override
  @JsonKey(name: 'pump_running')
  bool get pumpRunning;
  @override
  @JsonKey(name: 'controller_mode')
  String get controllerMode;
  @override
  @IsoDateTimeNullableConverter()
  @JsonKey(name: 'last_heartbeat')
  DateTime? get lastHeartbeat;
  @override
  @JsonKey(name: 'active_valves_count')
  int get activeValvesCount;
  @override
  @JsonKey(name: 'daily_water_used_mm')
  double get dailyWaterUsedMm;
  @override
  @JsonKey(name: 'daily_water_budget_mm')
  double get dailyWaterBudgetMm;

  /// Create a copy of SystemStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemStatusImplCopyWith<_$SystemStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
