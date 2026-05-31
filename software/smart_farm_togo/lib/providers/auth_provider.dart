import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/firebase/firebase_bootstrap.dart';
import '../data/datasources/api_datasource.dart';
import '../data/repositories/auth_repository.dart';
import 'api_provider.dart';
import 'settings_provider.dart';

/// Authentification Firebase + JWT FastAPI, session 30 min.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.maybeWhen(data: (u) => u != null, orElse: () => false);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(apiDatasourceProvider),
    ref,
  );
});

/// Déconnexion automatique après inactivité.
final sessionTimeoutProvider =
    NotifierProvider<SessionTimeoutNotifier, void>(SessionTimeoutNotifier.new);

class SessionTimeoutNotifier extends Notifier<void> {
  Timer? _timer;

  @override
  void build() {
    ref.onDispose(() => _timer?.cancel());
    _resetTimer();
  }

  void recordActivity() {
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(AppConstants.sessionTimeout, () {
      ref.read(authControllerProvider.notifier).signOut();
    });
  }
}

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository, this._api, this._ref)
      : super(const AsyncData(null));

  final AuthRepository _repository;
  final ApiDatasource _api;
  final Ref _ref;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (firebaseAvailable) {
        await _repository.signIn(email, password);
      }
      try {
        final data = await _api.login(email, password);
        final token = data['access_token'] as String?;
        if (token != null && token.isNotEmpty) {
          await _repository.saveApiToken(token);
          await _ref.read(apiConnectedProvider.notifier).setConnected(true);
          await _ref.read(demoModeProvider.notifier).setDemoMode(false);
        }
      } catch (_) {
        if (!firebaseAvailable) rethrow;
      }
      _ref.read(sessionTimeoutProvider.notifier).recordActivity();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.signOut);
  }
}
