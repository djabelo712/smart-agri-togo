import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage chiffré pour JWT et URL API (ne pas utiliser SharedPreferences).
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _tokenKey = 'jwt_token';
  static const _apiUrlKey = 'api_base_url';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  static Future<void> saveApiUrl(String url) =>
      _storage.write(key: _apiUrlKey, value: url);

  static Future<String?> getApiUrl() => _storage.read(key: _apiUrlKey);

  static Future<void> clearAll() => _storage.deleteAll();
}
