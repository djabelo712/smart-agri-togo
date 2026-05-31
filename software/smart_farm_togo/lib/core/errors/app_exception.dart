/// Erreurs métier SmartFarm Togo.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Erreur réseau']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentification refusée']);
}

class HardwareException extends AppException {
  const HardwareException([super.message = 'Commande matériel refusée']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
