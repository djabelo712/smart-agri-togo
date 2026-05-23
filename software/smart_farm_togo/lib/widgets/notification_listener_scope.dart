import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/notification_service.dart';
import '../providers/energy_provider.dart';
import '../providers/field_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/weather_provider.dart';

/// Écoute les flux champ/météo et déclenche les notifications locales.
class NotificationListenerScope extends ConsumerStatefulWidget {
  const NotificationListenerScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationListenerScope> createState() =>
      _NotificationListenerScopeState();
}

class _NotificationListenerScopeState
    extends ConsumerState<NotificationListenerScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyNotificationPrefs();
    });
  }

  void _applyNotificationPrefs() {
    final settings = ref.read(notificationSettingsProvider);
    NotificationService.instance.scheduleDailySummary(
      enabled: settings.rapportQuotidien,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);

    ref.listen(notificationSettingsProvider, (prev, next) {
      if (prev?.rapportQuotidien != next.rapportQuotidien) {
        NotificationService.instance.scheduleDailySummary(
          enabled: next.rapportQuotidien,
        );
      }
    });

    ref.listen(cellsStreamProvider, (prev, next) {
      next.whenData((cells) {
        NotificationService.instance.checkStressFromCells(
          cells: cells,
          enabled: settings.stressHydrique,
        );
      });
    });

    ref.listen(weatherStreamProvider, (prev, next) {
      next.whenData((weather) {
        if (weather == null) return;
        NotificationService.instance.checkRainAlert(
          rainfallMm: weather.rainfallMm,
          enabled: settings.pluieDetectee,
        );
      });
    });

    ref.listen(systemStreamProvider, (prev, next) {
      final wasRunning = prev?.valueOrNull?.pumpRunning ?? false;
      next.whenData((system) {
        if (system == null) return;
        if (wasRunning && !system.pumpRunning && settings.pannePompe) {
          NotificationService.instance.showPumpAlert(enabled: true);
        }
      });
    });

    return widget.child;
  }
}
