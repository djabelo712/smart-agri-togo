import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_model.freezed.dart';
part 'history_model.g.dart';

@freezed
class DailyHistory with _$DailyHistory {
  const factory DailyHistory({
    required String date,
    @JsonKey(name: 'total_irrigation_mm') required double totalIrrigationMm,
    @JsonKey(name: 'avg_stress_ks') required double avgStressKs,
    @JsonKey(name: 'et0_mm') required double et0Mm,
    @JsonKey(name: 'rain_mm') @Default(0.0) double rainMm,
  }) = _DailyHistory;

  factory DailyHistory.fromJson(String date, Map<String, dynamic> json) =>
      _$DailyHistoryFromJson(<String, dynamic>{'date': date, ...json});
}
