import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../models/alert_model.dart';
import '../models/cell_model.dart';
import '../models/history_model.dart';

typedef TokenProvider = Future<String?> Function();

/// Client HTTP FastAPI avec JWT automatique et retry sur 401.
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
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
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
    await _dio.post<void>(
      '/control/valve',
      data: {'cell': cell, 'action': action, 'duration_min': durationMin},
    );
  }

  Future<void> controlPump({
    required String action,
    int durationMin = 30,
  }) async {
    await _dio.post<void>(
      '/control/pump',
      data: {'action': action, 'duration_min': durationMin},
    );
  }

  Future<void> setControllerMode(String mode) async {
    await _dio.post<void>('/control/mode', data: {'mode': mode});
  }

  Future<Map<String, dynamic>> getYieldForecast() async {
    final response = await _dio.get<Map<String, dynamic>>('/ml/yield-forecast');
    return response.data ?? {};
  }

  Future<List<double>> getEt0Forecast() async {
    final response = await _dio.get<Map<String, dynamic>>('/ml/et0-forecast');
    final list = response.data?['next_7_days'] as List<dynamic>? ?? [];
    return list.map((e) => (e as num).toDouble()).toList();
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
