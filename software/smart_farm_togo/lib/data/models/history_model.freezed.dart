// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyHistory _$DailyHistoryFromJson(Map<String, dynamic> json) {
  return _DailyHistory.fromJson(json);
}

/// @nodoc
mixin _$DailyHistory {
  String get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_irrigation_mm')
  double get totalIrrigationMm => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_stress_ks')
  double get avgStressKs => throw _privateConstructorUsedError;
  @JsonKey(name: 'et0_mm')
  double get et0Mm => throw _privateConstructorUsedError;
  @JsonKey(name: 'rain_mm')
  double get rainMm => throw _privateConstructorUsedError;

  /// Serializes this DailyHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyHistoryCopyWith<DailyHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyHistoryCopyWith<$Res> {
  factory $DailyHistoryCopyWith(
    DailyHistory value,
    $Res Function(DailyHistory) then,
  ) = _$DailyHistoryCopyWithImpl<$Res, DailyHistory>;
  @useResult
  $Res call({
    String date,
    @JsonKey(name: 'total_irrigation_mm') double totalIrrigationMm,
    @JsonKey(name: 'avg_stress_ks') double avgStressKs,
    @JsonKey(name: 'et0_mm') double et0Mm,
    @JsonKey(name: 'rain_mm') double rainMm,
  });
}

/// @nodoc
class _$DailyHistoryCopyWithImpl<$Res, $Val extends DailyHistory>
    implements $DailyHistoryCopyWith<$Res> {
  _$DailyHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalIrrigationMm = null,
    Object? avgStressKs = null,
    Object? et0Mm = null,
    Object? rainMm = null,
  }) {
    return _then(
      _value.copyWith(
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as String,
            totalIrrigationMm:
                null == totalIrrigationMm
                    ? _value.totalIrrigationMm
                    : totalIrrigationMm // ignore: cast_nullable_to_non_nullable
                        as double,
            avgStressKs:
                null == avgStressKs
                    ? _value.avgStressKs
                    : avgStressKs // ignore: cast_nullable_to_non_nullable
                        as double,
            et0Mm:
                null == et0Mm
                    ? _value.et0Mm
                    : et0Mm // ignore: cast_nullable_to_non_nullable
                        as double,
            rainMm:
                null == rainMm
                    ? _value.rainMm
                    : rainMm // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyHistoryImplCopyWith<$Res>
    implements $DailyHistoryCopyWith<$Res> {
  factory _$$DailyHistoryImplCopyWith(
    _$DailyHistoryImpl value,
    $Res Function(_$DailyHistoryImpl) then,
  ) = __$$DailyHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    @JsonKey(name: 'total_irrigation_mm') double totalIrrigationMm,
    @JsonKey(name: 'avg_stress_ks') double avgStressKs,
    @JsonKey(name: 'et0_mm') double et0Mm,
    @JsonKey(name: 'rain_mm') double rainMm,
  });
}

/// @nodoc
class __$$DailyHistoryImplCopyWithImpl<$Res>
    extends _$DailyHistoryCopyWithImpl<$Res, _$DailyHistoryImpl>
    implements _$$DailyHistoryImplCopyWith<$Res> {
  __$$DailyHistoryImplCopyWithImpl(
    _$DailyHistoryImpl _value,
    $Res Function(_$DailyHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalIrrigationMm = null,
    Object? avgStressKs = null,
    Object? et0Mm = null,
    Object? rainMm = null,
  }) {
    return _then(
      _$DailyHistoryImpl(
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as String,
        totalIrrigationMm:
            null == totalIrrigationMm
                ? _value.totalIrrigationMm
                : totalIrrigationMm // ignore: cast_nullable_to_non_nullable
                    as double,
        avgStressKs:
            null == avgStressKs
                ? _value.avgStressKs
                : avgStressKs // ignore: cast_nullable_to_non_nullable
                    as double,
        et0Mm:
            null == et0Mm
                ? _value.et0Mm
                : et0Mm // ignore: cast_nullable_to_non_nullable
                    as double,
        rainMm:
            null == rainMm
                ? _value.rainMm
                : rainMm // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyHistoryImpl implements _DailyHistory {
  const _$DailyHistoryImpl({
    required this.date,
    @JsonKey(name: 'total_irrigation_mm') required this.totalIrrigationMm,
    @JsonKey(name: 'avg_stress_ks') required this.avgStressKs,
    @JsonKey(name: 'et0_mm') required this.et0Mm,
    @JsonKey(name: 'rain_mm') this.rainMm = 0.0,
  });

  factory _$DailyHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyHistoryImplFromJson(json);

  @override
  final String date;
  @override
  @JsonKey(name: 'total_irrigation_mm')
  final double totalIrrigationMm;
  @override
  @JsonKey(name: 'avg_stress_ks')
  final double avgStressKs;
  @override
  @JsonKey(name: 'et0_mm')
  final double et0Mm;
  @override
  @JsonKey(name: 'rain_mm')
  final double rainMm;

  @override
  String toString() {
    return 'DailyHistory(date: $date, totalIrrigationMm: $totalIrrigationMm, avgStressKs: $avgStressKs, et0Mm: $et0Mm, rainMm: $rainMm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyHistoryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalIrrigationMm, totalIrrigationMm) ||
                other.totalIrrigationMm == totalIrrigationMm) &&
            (identical(other.avgStressKs, avgStressKs) ||
                other.avgStressKs == avgStressKs) &&
            (identical(other.et0Mm, et0Mm) || other.et0Mm == et0Mm) &&
            (identical(other.rainMm, rainMm) || other.rainMm == rainMm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    totalIrrigationMm,
    avgStressKs,
    et0Mm,
    rainMm,
  );

  /// Create a copy of DailyHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyHistoryImplCopyWith<_$DailyHistoryImpl> get copyWith =>
      __$$DailyHistoryImplCopyWithImpl<_$DailyHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyHistoryImplToJson(this);
  }
}

abstract class _DailyHistory implements DailyHistory {
  const factory _DailyHistory({
    required final String date,
    @JsonKey(name: 'total_irrigation_mm')
    required final double totalIrrigationMm,
    @JsonKey(name: 'avg_stress_ks') required final double avgStressKs,
    @JsonKey(name: 'et0_mm') required final double et0Mm,
    @JsonKey(name: 'rain_mm') final double rainMm,
  }) = _$DailyHistoryImpl;

  factory _DailyHistory.fromJson(Map<String, dynamic> json) =
      _$DailyHistoryImpl.fromJson;

  @override
  String get date;
  @override
  @JsonKey(name: 'total_irrigation_mm')
  double get totalIrrigationMm;
  @override
  @JsonKey(name: 'avg_stress_ks')
  double get avgStressKs;
  @override
  @JsonKey(name: 'et0_mm')
  double get et0Mm;
  @override
  @JsonKey(name: 'rain_mm')
  double get rainMm;

  /// Create a copy of DailyHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyHistoryImplCopyWith<_$DailyHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
