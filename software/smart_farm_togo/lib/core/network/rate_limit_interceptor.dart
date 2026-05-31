import 'package:dio/dio.dart';

/// Limite le spam client (max 10 requêtes / 5 secondes).
class RateLimitInterceptor extends Interceptor {
  final _timestamps = <int>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skip_rate_limit'] == true) {
      handler.next(options);
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    _timestamps.removeWhere((t) => now - t > 5000);
    if (_timestamps.length >= 10) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Rate limit exceeded. Please wait.',
        ),
      );
      return;
    }
    _timestamps.add(now);
    handler.next(options);
  }
}
