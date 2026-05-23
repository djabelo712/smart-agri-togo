import 'package:firebase_auth/firebase_auth.dart';

import '../../core/firebase/firebase_bootstrap.dart';

class AuthRepository {
  AuthRepository();

  bool get _canUseFirebase => firebaseAvailable;

  Stream<User?> authStateChanges() {
    if (!_canUseFirebase) return Stream<User?>.value(null);
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser {
    if (!_canUseFirebase) return null;
    return FirebaseAuth.instance.currentUser;
  }

  bool get isAuthenticated => currentUser != null;

  Future<void> signIn(String email, String password) async {
    if (!_canUseFirebase) {
      throw const AuthException(
        'Firebase non configuré. Utilisez le mode démo ou configurez Firebase.',
      );
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    if (!_canUseFirebase) return;
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> getIdToken() async {
    if (!_canUseFirebase) return null;
    final user = currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
