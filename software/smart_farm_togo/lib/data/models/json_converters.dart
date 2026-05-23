import 'package:json_annotation/json_annotation.dart';

DateTime? nullableDateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

String? nullableDateTimeToJson(DateTime? value) => value?.toUtc().toIso8601String();

DateTime dateTimeFromJson(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

String dateTimeToJson(DateTime value) => value.toUtc().toIso8601String();

class IsoDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const IsoDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) => dateTimeFromJson(json);

  @override
  dynamic toJson(DateTime object) => dateTimeToJson(object);
}

class IsoDateTimeNullableConverter implements JsonConverter<DateTime?, dynamic> {
  const IsoDateTimeNullableConverter();

  @override
  DateTime? fromJson(dynamic json) => nullableDateTimeFromJson(json);

  @override
  dynamic toJson(DateTime? object) => nullableDateTimeToJson(object);
}
