import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap/api_bootstrap.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/date_utils.dart';
import 'providers/settings_provider.dart';
import 'widgets/notification_listener_scope.dart';
import 'widgets/session_activity_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSharedPreferences();
  await initializeFrenchLocale();
  await bootstrapFirebase();
  await bootstrapApiConnection();
  await NotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: SessionActivityScope(
        child: NotificationListenerScope(
          child: SmartFarmApp(),
        ),
      ),
    ),
  );
}

class SmartFarmApp extends ConsumerWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SmartFarm Togo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('fr', 'FR'),
      routerConfig: router,
    );
  }
}
