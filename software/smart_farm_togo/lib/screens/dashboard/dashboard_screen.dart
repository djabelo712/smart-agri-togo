import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/alert_provider.dart';
import '../../providers/energy_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/weather_provider.dart';
import 'widgets/alert_banner.dart';
import 'widgets/energy_card.dart';
import 'widgets/mini_field_heatmap.dart';
import 'widgets/system_status_card.dart';
import 'widgets/water_budget_card.dart';
import 'widgets/weather_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadAlertsProvider);
    final hasUnread = unread.isNotEmpty;
    final dateLabel = formatDashboardDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tableau de bord'),
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.alertOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.go('/app/reglages'),
            tooltip: 'Alertes',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(cellsStreamProvider);
          ref.invalidate(systemStreamProvider);
          ref.invalidate(weatherStreamProvider);
          ref.invalidate(forecastStreamProvider);
          ref.invalidate(energyStreamProvider);
          ref.invalidate(alertsStreamProvider);
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SystemStatusCard(),
              SizedBox(height: 12),
              MiniFieldHeatmap(),
              SizedBox(height: 12),
              AlertBanner(),
              SizedBox(height: 12),
              WeatherCard(),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: WaterBudgetCard()),
                  SizedBox(width: 12),
                  Expanded(child: EnergyCard()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
