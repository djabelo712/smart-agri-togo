import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/rate_limit_interceptor.dart';
import '../models/alert_model.dart';
import '../models/cell_model.dart';
import '../models/history_model.dart';

typedef TokenProvider = Future<String?> Function();

/// Client HTTP FastAPI avec JWT, validation des entrées et limites réseau.
class ApiDatasource {
  ApiDatasource({
    String? baseUrl,
    TokenProvider? tokenProvider,
    Dio? dio,
  })  : _tokenProvider = tokenProvider,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConstants.defaultApiBaseUrl,
                connectTimeout: AppConstants.apiConnectTimeout,
                receiveTimeout: AppConstants.apiReceiveTimeout,
                sendTimeout: AppConstants.apiSendTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'X-App-Version': AppConstants.appVersion,
                  'X-Platform': Platform.operatingSystem,
                },
              ),
            ) {
    if (dio == null) {
      _dio.interceptors.add(RateLimitInterceptor());
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['_retried'] != true) {
            error.requestOptions.extra['_retried'] = true;
            final token = await _tokenProvider?.call();
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenProvider? _tokenProvider;

  static final _cellIdRegex = RegExp(r'^C[0-4][0-4]$');

  void _validateCellId(String cell) {
    if (!_cellIdRegex.hasMatch(cell)) {
      throw ValidationException(
        'Identifiant de zone invalide : $cell. Format attendu : C00–C44',
      );
    }
  }

  void _validateKsValues(List<double> ks) {
    if (ks.isEmpty) {
      throw const ValidationException('ks_daily ne peut pas être vide');
    }
    if (ks.length < 10) {
      throw const ValidationException(
        'ks_daily doit contenir au moins 10 valeurs',
      );
    }
    if (ks.any((v) => v < 0 || v > 1)) {
      throw const ValidationException(
        'Toutes les valeurs Ks doivent être entre 0 et 1',
      );
    }
  }

  void _validateCropName(String crop) {
    if (!AppConstants.validCropNames.contains(crop)) {
      throw ValidationException(
        'Culture invalide : $crop. Valides : ${AppConstants.validCropNames}',
      );
    }
  }

  void _validateMode(String mode) {
    if (!AppConstants.controllerModes.contains(mode)) {
      throw ValidationException('Mode invalide : $mode');
    }
  }

  Future<Map<String, dynamic>> getFieldHealth() async {
    final healthOptions = Options(
      extra: {'skip_rate_limit': true},
      connectTimeout: AppConstants.apiHealthConnectTimeout,
      sendTimeout: AppConstants.apiHealthConnectTimeout,
      receiveTimeout: AppConstants.apiHealthReceiveTimeout,
    );

    DioException? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/field/health',
          options: healthOptions,
        );
        return response.data ?? {};
      } on DioException catch (e) {
        lastError = e;
        final retryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.response?.statusCode == 503;
        if (!retryable || attempt == 2) rethrow;
        await Future<void>.delayed(Duration(seconds: 5 * (attempt + 1)));
      }
    }
    throw lastError ?? DioException(requestOptions: RequestOptions());
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getFieldStatus() async {
    final response = await _dio.get<Map<String, dynamic>>('/field/status');
    return response.data ?? {};
  }

  Future<void> controlValve({
    required String cell,
    required String action,
    int durationMin = 15,
  }) async {
    _validateCellId(cell);
    if (action != 'open' && action != 'close') {
      throw ValidationException('Action vanne invalide : $action');
    }
    await _dio.post<void>(
      '/control/valve',
      data: {'cell': cell, 'action': action, 'duration_min': durationMin},
    );
  }

  Future<void> controlPump({
    required String action,
    int durationMin = 30,
  }) async {
    if (action != 'start' && action != 'stop') {
      throw ValidationException('Action pompe invalide : $action');
    }
    await _dio.post<void>(
      '/control/pump',
      data: {'action': action, 'duration_min': durationMin},
    );
  }

  Future<void> setControllerMode(String mode) async {
    _validateMode(mode);
    await _dio.post<void>('/control/mode', data: {'mode': mode});
  }

  Future<double> getEt0Today() async {
    final response = await _dio.get<Map<String, dynamic>>('/ml/et0-today');
    return (response.data?['et0_mm_day'] as num?)?.toDouble() ?? 4.2;
  }

  Future<Map<String, dynamic>> getEt0Forecast() async {
    final response = await _dio.get<Map<String, dynamic>>('/ml/et0-forecast');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getYieldForecastForCell({
    required String cropName,
    required List<double> ksDailyValues,
    required String treatment,
  }) async {
    _validateCropName(cropName);
    _validateKsValues(ksDailyValues);
    final response = await _dio.post<Map<String, dynamic>>(
      '/ml/yield-forecast',
      data: {
        'crop_name': cropName,
        'ks_daily': ksDailyValues,
        'treatment_name': treatment,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getFullFieldYieldForecast(
    Map<String, List<double>> ksSensors,
  ) async {
    for (final entry in ksSensors.entries) {
      _validateCellId(entry.key);
      _validateKsValues(entry.value);
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/ml/yield-forecast/full-field',
      data: {'ks_sensors': ksSensors},
    );
    return response.data ?? {};
  }

  Future<List<DailyHistory>> getDailyHistory({int days = 30}) async {
    final response = await _dio.get<List<dynamic>>(
      '/history/daily',
      queryParameters: {'days': days},
    );
    final data = response.data ?? [];
    return data
        .map((e) => DailyHistory.fromJson(
              (e as Map<String, dynamic>)['date'] as String? ?? '',
              e,
            ))
        .toList();
  }

  Future<List<FarmAlert>> getAlerts({bool unread = true}) async {
    final response = await _dio.get<List<dynamic>>(
      '/alerts',
      queryParameters: {'unread': unread},
    );
    final data = response.data ?? [];
    return data.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return FarmAlert.fromJson(map['id'] as String? ?? '', map);
    }).toList();
  }

  Future<void> acknowledgeAlert(String id) async {
    await _dio.post<void>('/alerts/$id/acknowledge');
  }

  Future<Map<String, dynamic>> getResearchComparison() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/research/comparison');
    return response.data ?? {};
  }

  Map<String, FieldCell> parseCellsFromStatus(Map<String, dynamic> data) {
    final cellsRaw = data['cells'] as Map<String, dynamic>? ?? {};
    return cellsRaw.map(
      (k, v) => MapEntry(
        k,
        FieldCell.fromJson(k, Map<String, dynamic>.from(v as Map)),
      ),
    );
  }
}
