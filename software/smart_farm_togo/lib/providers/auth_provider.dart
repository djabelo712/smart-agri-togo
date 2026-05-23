import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/api_datasource.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final apiDatasourceProvider = Provider<ApiDatasource>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return ApiDatasource(tokenProvider: auth.getIdToken);
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
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository, this._api) : super(const AsyncData(null));

  final AuthRepository _repository;
  final ApiDatasource _api;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signIn(email, password);
      try {
        await _api.login(email, password);
      } catch (_) {
        // API FastAPI optionnelle si indisponible.
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.signOut);
  }
}
