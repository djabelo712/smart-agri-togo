import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_converters.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

@freezed
class FarmAlert with _$FarmAlert {
  const factory FarmAlert({
    required String id,
    required String type,
    String? cell,
    required String message,
    required String severity,
    @IsoDateTimeConverter() required DateTime timestamp,
    @Default(false) bool acknowledged,
  }) = _FarmAlert;

  factory FarmAlert.fromJson(String id, Map<String, dynamic> json) =>
      _$FarmAlertFromJson(<String, dynamic>{'id': id, ...json});
}
