import 'package:flutter/foundation.dart';

/// Journalisation sans fuite de secrets en production.
class AppLogger {
  AppLogger._();

  static String _sanitize(String message) => message.replaceAll(
        RegExp(r'Bearer [A-Za-z0-9._-]+'),
        'Bearer [REDACTED]',
      );

  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] ${_sanitize(message)}');
  }

  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] ${_sanitize(message)}');
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[ERROR] ${_sanitize(message)}');
      if (error != null) debugPrint('  → $error');
    }
  }
}
