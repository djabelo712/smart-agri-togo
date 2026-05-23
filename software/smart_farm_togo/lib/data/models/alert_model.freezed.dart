// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FarmAlert _$FarmAlertFromJson(Map<String, dynamic> json) {
  return _FarmAlert.fromJson(json);
}

/// @nodoc
mixin _$FarmAlert {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get cell => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  @IsoDateTimeConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get acknowledged => throw _privateConstructorUsedError;

  /// Serializes this FarmAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FarmAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FarmAlertCopyWith<FarmAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FarmAlertCopyWith<$Res> {
  factory $FarmAlertCopyWith(FarmAlert value, $Res Function(FarmAlert) then) =
      _$FarmAlertCopyWithImpl<$Res, FarmAlert>;
  @useResult
  $Res call({
    String id,
    String type,
    String? cell,
    String message,
    String severity,
    @IsoDateTimeConverter() DateTime timestamp,
    bool acknowledged,
  });
}

/// @nodoc
class _$FarmAlertCopyWithImpl<$Res, $Val extends FarmAlert>
    implements $FarmAlertCopyWith<$Res> {
  _$FarmAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FarmAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? cell = freezed,
    Object? message = null,
    Object? severity = null,
    Object? timestamp = null,
    Object? acknowledged = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            cell:
                freezed == cell
                    ? _value.cell
                    : cell // ignore: cast_nullable_to_non_nullable
                        as String?,
            message:
                null == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String,
            severity:
                null == severity
                    ? _value.severity
                    : severity // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            acknowledged:
                null == acknowledged
                    ? _value.acknowledged
                    : acknowledged // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FarmAlertImplCopyWith<$Res>
    implements $FarmAlertCopyWith<$Res> {
  factory _$$FarmAlertImplCopyWith(
    _$FarmAlertImpl value,
    $Res Function(_$FarmAlertImpl) then,
  ) = __$$FarmAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String? cell,
    String message,
    String severity,
    @IsoDateTimeConverter() DateTime timestamp,
    bool acknowledged,
  });
}

/// @nodoc
class __$$FarmAlertImplCopyWithImpl<$Res>
    extends _$FarmAlertCopyWithImpl<$Res, _$FarmAlertImpl>
    implements _$$FarmAlertImplCopyWith<$Res> {
  __$$FarmAlertImplCopyWithImpl(
    _$FarmAlertImpl _value,
    $Res Function(_$FarmAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FarmAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? cell = freezed,
    Object? message = null,
    Object? severity = null,
    Object? timestamp = null,
    Object? acknowledged = null,
  }) {
    return _then(
      _$FarmAlertImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        cell:
            freezed == cell
                ? _value.cell
                : cell // ignore: cast_nullable_to_non_nullable
                    as String?,
        message:
            null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String,
        severity:
            null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        acknowledged:
            null == acknowledged
                ? _value.acknowledged
                : acknowledged // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FarmAlertImpl implements _FarmAlert {
  const _$FarmAlertImpl({
    required this.id,
    required this.type,
    this.cell,
    required this.message,
    required this.severity,
    @IsoDateTimeConverter() required this.timestamp,
    this.acknowledged = false,
  });

  factory _$FarmAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$FarmAlertImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String? cell;
  @override
  final String message;
  @override
  final String severity;
  @override
  @IsoDateTimeConverter()
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool acknowledged;

  @override
  String toString() {
    return 'FarmAlert(id: $id, type: $type, cell: $cell, message: $message, severity: $severity, timestamp: $timestamp, acknowledged: $acknowledged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FarmAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.cell, cell) || other.cell == cell) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.acknowledged, acknowledged) ||
                other.acknowledged == acknowledged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    cell,
    message,
    severity,
    timestamp,
    acknowledged,
  );

  /// Create a copy of FarmAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FarmAlertImplCopyWith<_$FarmAlertImpl> get copyWith =>
      __$$FarmAlertImplCopyWithImpl<_$FarmAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FarmAlertImplToJson(this);
  }
}

abstract class _FarmAlert implements FarmAlert {
  const factory _FarmAlert({
    required final String id,
    required final String type,
    final String? cell,
    required final String message,
    required final String severity,
    @IsoDateTimeConverter() required final DateTime timestamp,
    final bool acknowledged,
  }) = _$FarmAlertImpl;

  factory _FarmAlert.fromJson(Map<String, dynamic> json) =
      _$FarmAlertImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String? get cell;
  @override
  String get message;
  @override
  String get severity;
  @override
  @IsoDateTimeConverter()
  DateTime get timestamp;
  @override
  bool get acknowledged;

  /// Create a copy of FarmAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FarmAlertImplCopyWith<_$FarmAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
