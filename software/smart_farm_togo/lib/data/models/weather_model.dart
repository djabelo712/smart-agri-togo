import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'weather_model.freezed.dart';
part 'weather_model.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    @IsoDateTimeConverter() required DateTime timestamp,
    @JsonKey(name: 'temp_c') required double tempC,
    @JsonKey(name: 'humidity_pct') required double humidityPct,
    @JsonKey(name: 'solar_rad_wm2') @Default(0.0) double solarRadWm2,
    @JsonKey(name: 'wind_speed_ms') @Default(0.0) double windSpeedMs,
    @JsonKey(name: 'rainfall_mm') @Default(0.0) double rainfallMm,
    @JsonKey(name: 'et0_mm_day') required double et0MmDay,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);
}

@freezed
class FieldForecast with _$FieldForecast {
  const factory FieldForecast({
    @JsonKey(name: 'et0_next_7_days') @Default([]) List<double> et0Next7Days,
    @JsonKey(name: 'rain_next_7_days') @Default([]) List<double> rainNext7Days,
  }) = _FieldForecast;

  factory FieldForecast.fromJson(Map<String, dynamic> json) =>
      _$FieldForecastFromJson(json);
}
