import 'package:dio/dio.dart';

/// Message utilisateur à partir d'une erreur Dio.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Délai dépassé. Sur Render, le 1er appel peut prendre jusqu\'à 60 s — réessayez.';
      case DioExceptionType.connectionError:
        return 'Pas de connexion Internet ou URL incorrecte.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 503) {
          return 'Serveur en démarrage (503) — attendez 30 s et réessayez.';
        }
        return 'Réponse serveur : HTTP $code';
      default:
        return error.message ?? 'Erreur réseau';
    }
  }
  return error.toString();
}
