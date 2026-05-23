// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Weather _$WeatherFromJson(Map<String, dynamic> json) {
  return _Weather.fromJson(json);
}

/// @nodoc
mixin _$Weather {
  @IsoDateTimeConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'temp_c')
  double get tempC => throw _privateConstructorUsedError;
  @JsonKey(name: 'humidity_pct')
  double get humidityPct => throw _privateConstructorUsedError;
  @JsonKey(name: 'solar_rad_wm2')
  double get solarRadWm2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'wind_speed_ms')
  double get windSpeedMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'rainfall_mm')
  double get rainfallMm => throw _privateConstructorUsedError;
  @JsonKey(name: 'et0_mm_day')
  double get et0MmDay => throw _privateConstructorUsedError;

  /// Serializes this Weather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherCopyWith<Weather> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherCopyWith<$Res> {
  factory $WeatherCopyWith(Weather value, $Res Function(Weather) then) =
      _$WeatherCopyWithImpl<$Res, Weather>;
  @useResult
  $Res call({
    @IsoDateTimeConverter() DateTime timestamp,
    @JsonKey(name: 'temp_c') double tempC,
    @JsonKey(name: 'humidity_pct') double humidityPct,
    @JsonKey(name: 'solar_rad_wm2') double solarRadWm2,
    @JsonKey(name: 'wind_speed_ms') double windSpeedMs,
    @JsonKey(name: 'rainfall_mm') double rainfallMm,
    @JsonKey(name: 'et0_mm_day') double et0MmDay,
  });
}

/// @nodoc
class _$WeatherCopyWithImpl<$Res, $Val extends Weather>
    implements $WeatherCopyWith<$Res> {
  _$WeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? tempC = null,
    Object? humidityPct = null,
    Object? solarRadWm2 = null,
    Object? windSpeedMs = null,
    Object? rainfallMm = null,
    Object? et0MmDay = null,
  }) {
    return _then(
      _value.copyWith(
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            tempC:
                null == tempC
                    ? _value.tempC
                    : tempC // ignore: cast_nullable_to_non_nullable
                        as double,
            humidityPct:
                null == humidityPct
                    ? _value.humidityPct
                    : humidityPct // ignore: cast_nullable_to_non_nullable
                        as double,
            solarRadWm2:
                null == solarRadWm2
                    ? _value.solarRadWm2
                    : solarRadWm2 // ignore: cast_nullable_to_non_nullable
                        as double,
            windSpeedMs:
                null == windSpeedMs
                    ? _value.windSpeedMs
                    : windSpeedMs // ignore: cast_nullable_to_non_nullable
                        as double,
            rainfallMm:
                null == rainfallMm
                    ? _value.rainfallMm
                    : rainfallMm // ignore: cast_nullable_to_non_nullable
                        as double,
            et0MmDay:
                null == et0MmDay
                    ? _value.et0MmDay
                    : et0MmDay // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherImplCopyWith<$Res> implements $WeatherCopyWith<$Res> {
  factory _$$WeatherImplCopyWith(
    _$WeatherImpl value,
    $Res Function(_$WeatherImpl) then,
  ) = __$$WeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @IsoDateTimeConverter() DateTime timestamp,
    @JsonKey(name: 'temp_c') double tempC,
    @JsonKey(name: 'humidity_pct') double humidityPct,
    @JsonKey(name: 'solar_rad_wm2') double solarRadWm2,
    @JsonKey(name: 'wind_speed_ms') double windSpeedMs,
    @JsonKey(name: 'rainfall_mm') double rainfallMm,
    @JsonKey(name: 'et0_mm_day') double et0MmDay,
  });
}

/// @nodoc
class __$$WeatherImplCopyWithImpl<$Res>
    extends _$WeatherCopyWithImpl<$Res, _$WeatherImpl>
    implements _$$WeatherImplCopyWith<$Res> {
  __$$WeatherImplCopyWithImpl(
    _$WeatherImpl _value,
    $Res Function(_$WeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? tempC = null,
    Object? humidityPct = null,
    Object? solarRadWm2 = null,
    Object? windSpeedMs = null,
    Object? rainfallMm = null,
    Object? et0MmDay = null,
  }) {
    return _then(
      _$WeatherImpl(
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        tempC:
            null == tempC
                ? _value.tempC
                : tempC // ignore: cast_nullable_to_non_nullable
                    as double,
        humidityPct:
            null == humidityPct
                ? _value.humidityPct
                : humidityPct // ignore: cast_nullable_to_non_nullable
                    as double,
        solarRadWm2:
            null == solarRadWm2
                ? _value.solarRadWm2
                : solarRadWm2 // ignore: cast_nullable_to_non_nullable
                    as double,
        windSpeedMs:
            null == windSpeedMs
                ? _value.windSpeedMs
                : windSpeedMs // ignore: cast_nullable_to_non_nullable
                    as double,
        rainfallMm:
            null == rainfallMm
                ? _value.rainfallMm
                : rainfallMm // ignore: cast_nullable_to_non_nullable
                    as double,
        et0MmDay:
            null == et0MmDay
                ? _value.et0MmDay
                : et0MmDay // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherImpl implements _Weather {
  const _$WeatherImpl({
    @IsoDateTimeConverter() required this.timestamp,
    @JsonKey(name: 'temp_c') required this.tempC,
    @JsonKey(name: 'humidity_pct') required this.humidityPct,
    @JsonKey(name: 'solar_rad_wm2') this.solarRadWm2 = 0.0,
    @JsonKey(name: 'wind_speed_ms') this.windSpeedMs = 0.0,
    @JsonKey(name: 'rainfall_mm') this.rainfallMm = 0.0,
    @JsonKey(name: 'et0_mm_day') required this.et0MmDay,
  });

  factory _$WeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherImplFromJson(json);

  @override
  @IsoDateTimeConverter()
  final DateTime timestamp;
  @override
  @JsonKey(name: 'temp_c')
  final double tempC;
  @override
  @JsonKey(name: 'humidity_pct')
  final double humidityPct;
  @override
  @JsonKey(name: 'solar_rad_wm2')
  final double solarRadWm2;
  @override
  @JsonKey(name: 'wind_speed_ms')
  final double windSpeedMs;
  @override
  @JsonKey(name: 'rainfall_mm')
  final double rainfallMm;
  @override
  @JsonKey(name: 'et0_mm_day')
  final double et0MmDay;

  @override
  String toString() {
    return 'Weather(timestamp: $timestamp, tempC: $tempC, humidityPct: $humidityPct, solarRadWm2: $solarRadWm2, windSpeedMs: $windSpeedMs, rainfallMm: $rainfallMm, et0MmDay: $et0MmDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.tempC, tempC) || other.tempC == tempC) &&
            (identical(other.humidityPct, humidityPct) ||
                other.humidityPct == humidityPct) &&
            (identical(other.solarRadWm2, solarRadWm2) ||
                other.solarRadWm2 == solarRadWm2) &&
            (identical(other.windSpeedMs, windSpeedMs) ||
                other.windSpeedMs == windSpeedMs) &&
            (identical(other.rainfallMm, rainfallMm) ||
                other.rainfallMm == rainfallMm) &&
            (identical(other.et0MmDay, et0MmDay) ||
                other.et0MmDay == et0MmDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    timestamp,
    tempC,
    humidityPct,
    solarRadWm2,
    windSpeedMs,
    rainfallMm,
    et0MmDay,
  );

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherImplCopyWith<_$WeatherImpl> get copyWith =>
      __$$WeatherImplCopyWithImpl<_$WeatherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherImplToJson(this);
  }
}

abstract class _Weather implements Weather {
  const factory _Weather({
    @IsoDateTimeConverter() required final DateTime timestamp,
    @JsonKey(name: 'temp_c') required final double tempC,
    @JsonKey(name: 'humidity_pct') required final double humidityPct,
    @JsonKey(name: 'solar_rad_wm2') final double solarRadWm2,
    @JsonKey(name: 'wind_speed_ms') final double windSpeedMs,
    @JsonKey(name: 'rainfall_mm') final double rainfallMm,
    @JsonKey(name: 'et0_mm_day') required final double et0MmDay,
  }) = _$WeatherImpl;

  factory _Weather.fromJson(Map<String, dynamic> json) = _$WeatherImpl.fromJson;

  @override
  @IsoDateTimeConverter()
  DateTime get timestamp;
  @override
  @JsonKey(name: 'temp_c')
  double get tempC;
  @override
  @JsonKey(name: 'humidity_pct')
  double get humidityPct;
  @override
  @JsonKey(name: 'solar_rad_wm2')
  double get solarRadWm2;
  @override
  @JsonKey(name: 'wind_speed_ms')
  double get windSpeedMs;
  @override
  @JsonKey(name: 'rainfall_mm')
  double get rainfallMm;
  @override
  @JsonKey(name: 'et0_mm_day')
  double get et0MmDay;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherImplCopyWith<_$WeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldForecast _$FieldForecastFromJson(Map<String, dynamic> json) {
  return _FieldForecast.fromJson(json);
}

/// @nodoc
mixin _$FieldForecast {
  @JsonKey(name: 'et0_next_7_days')
  List<double> get et0Next7Days => throw _privateConstructorUsedError;
  @JsonKey(name: 'rain_next_7_days')
  List<double> get rainNext7Days => throw _privateConstructorUsedError;

  /// Serializes this FieldForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldForecastCopyWith<FieldForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldForecastCopyWith<$Res> {
  factory $FieldForecastCopyWith(
    FieldForecast value,
    $Res Function(FieldForecast) then,
  ) = _$FieldForecastCopyWithImpl<$Res, FieldForecast>;
  @useResult
  $Res call({
    @JsonKey(name: 'et0_next_7_days') List<double> et0Next7Days,
    @JsonKey(name: 'rain_next_7_days') List<double> rainNext7Days,
  });
}

/// @nodoc
class _$FieldForecastCopyWithImpl<$Res, $Val extends FieldForecast>
    implements $FieldForecastCopyWith<$Res> {
  _$FieldForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? et0Next7Days = null, Object? rainNext7Days = null}) {
    return _then(
      _value.copyWith(
            et0Next7Days:
                null == et0Next7Days
                    ? _value.et0Next7Days
                    : et0Next7Days // ignore: cast_nullable_to_non_nullable
                        as List<double>,
            rainNext7Days:
                null == rainNext7Days
                    ? _value.rainNext7Days
                    : rainNext7Days // ignore: cast_nullable_to_non_nullable
                        as List<double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldForecastImplCopyWith<$Res>
    implements $FieldForecastCopyWith<$Res> {
  factory _$$FieldForecastImplCopyWith(
    _$FieldForecastImpl value,
    $Res Function(_$FieldForecastImpl) then,
  ) = __$$FieldForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'et0_next_7_days') List<double> et0Next7Days,
    @JsonKey(name: 'rain_next_7_days') List<double> rainNext7Days,
  });
}

/// @nodoc
class __$$FieldForecastImplCopyWithImpl<$Res>
    extends _$FieldForecastCopyWithImpl<$Res, _$FieldForecastImpl>
    implements _$$FieldForecastImplCopyWith<$Res> {
  __$$FieldForecastImplCopyWithImpl(
    _$FieldForecastImpl _value,
    $Res Function(_$FieldForecastImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? et0Next7Days = null, Object? rainNext7Days = null}) {
    return _then(
      _$FieldForecastImpl(
        et0Next7Days:
            null == et0Next7Days
                ? _value._et0Next7Days
                : et0Next7Days // ignore: cast_nullable_to_non_nullable
                    as List<double>,
        rainNext7Days:
            null == rainNext7Days
                ? _value._rainNext7Days
                : rainNext7Days // ignore: cast_nullable_to_non_nullable
                    as List<double>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldForecastImpl implements _FieldForecast {
  const _$FieldForecastImpl({
    @JsonKey(name: 'et0_next_7_days')
    final List<double> et0Next7Days = const [],
    @JsonKey(name: 'rain_next_7_days')
    final List<double> rainNext7Days = const [],
  }) : _et0Next7Days = et0Next7Days,
       _rainNext7Days = rainNext7Days;

  factory _$FieldForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldForecastImplFromJson(json);

  final List<double> _et0Next7Days;
  @override
  @JsonKey(name: 'et0_next_7_days')
  List<double> get et0Next7Days {
    if (_et0Next7Days is EqualUnmodifiableListView) return _et0Next7Days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_et0Next7Days);
  }

  final List<double> _rainNext7Days;
  @override
  @JsonKey(name: 'rain_next_7_days')
  List<double> get rainNext7Days {
    if (_rainNext7Days is EqualUnmodifiableListView) return _rainNext7Days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rainNext7Days);
  }

  @override
  String toString() {
    return 'FieldForecast(et0Next7Days: $et0Next7Days, rainNext7Days: $rainNext7Days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldForecastImpl &&
            const DeepCollectionEquality().equals(
              other._et0Next7Days,
              _et0Next7Days,
            ) &&
            const DeepCollectionEquality().equals(
              other._rainNext7Days,
              _rainNext7Days,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_et0Next7Days),
    const DeepCollectionEquality().hash(_rainNext7Days),
  );

  /// Create a copy of FieldForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldForecastImplCopyWith<_$FieldForecastImpl> get copyWith =>
      __$$FieldForecastImplCopyWithImpl<_$FieldForecastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldForecastImplToJson(this);
  }
}

abstract class _FieldForecast implements FieldForecast {
  const factory _FieldForecast({
    @JsonKey(name: 'et0_next_7_days') final List<double> et0Next7Days,
    @JsonKey(name: 'rain_next_7_days') final List<double> rainNext7Days,
  }) = _$FieldForecastImpl;

  factory _FieldForecast.fromJson(Map<String, dynamic> json) =
      _$FieldForecastImpl.fromJson;

  @override
  @JsonKey(name: 'et0_next_7_days')
  List<double> get et0Next7Days;
  @override
  @JsonKey(name: 'rain_next_7_days')
  List<double> get rainNext7Days;

  /// Create a copy of FieldForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldForecastImplCopyWith<_$FieldForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
