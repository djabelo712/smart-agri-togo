import 'package:freezed_annotation/freezed_annotation.dart';

part 'energy_model.freezed.dart';
part 'energy_model.g.dart';

@freezed
class EnergyStatus with _$EnergyStatus {
  const factory EnergyStatus({
    @JsonKey(name: 'battery_soc_pct') required double batterySocPct,
    @JsonKey(name: 'solar_power_w') required double solarPowerW,
    @JsonKey(name: 'load_power_w') required double loadPowerW,
    @JsonKey(name: 'daily_generation_kwh')
    @Default(0.0)
    double dailyGenerationKwh,
    @JsonKey(name: 'daily_consumption_kwh')
    @Default(0.0)
    double dailyConsumptionKwh,
  }) = _EnergyStatus;

  factory EnergyStatus.fromJson(Map<String, dynamic> json) =>
      _$EnergyStatusFromJson(json);
}
