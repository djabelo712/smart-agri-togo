import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_farm_togo/core/utils/date_utils.dart';
import 'package:smart_farm_togo/main.dart';
import 'package:smart_farm_togo/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'demo_mode': true});
    await initializeSharedPreferences();
    await initializeFrenchLocale();
  });

  testWidgets('Application démarre', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartFarmApp()));
    await tester.pump();
    expect(find.byType(SmartFarmApp), findsOneWidget);

    // SplashScreen : Future.delayed(1500 ms) — avancer le temps pour éviter un timer en attente
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
  });
}
