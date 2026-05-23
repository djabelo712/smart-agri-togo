import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../firebase/firebase_bootstrap.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/control/control_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/field_map/field_map_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/reglages/reglages_screen.dart';
import '../../screens/splash/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final demoMode = ref.watch(demoModeProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(_authRefreshStream(ref)),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == '/';
      final isLogin = loc == '/login';
      final isApp = loc.startsWith('/app');

      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final allowApp = isLoggedIn || demoMode || !firebaseAvailable;

      if (isSplash) return null;
      if (!allowApp && isApp) return '/login';
      if (allowApp && isLogin) return '/app/accueil';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/accueil',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/carte',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FieldMapScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/controle',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ControlScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/analyses',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AnalyticsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/reglages',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReglagesScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

Stream<dynamic> _authRefreshStream(Ref ref) {
  if (!firebaseAvailable) {
    return const Stream.empty();
  }
  return ref.read(authRepositoryProvider).authStateChanges();
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
