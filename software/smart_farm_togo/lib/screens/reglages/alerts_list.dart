import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/alert_model.dart';
import '../../providers/alert_provider.dart';

final dismissedAlertsProvider = StateProvider<Set<String>>((ref) => {});

final visibleAlertsProvider = Provider<List<FarmAlert>>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);
  final dismissed = ref.watch(dismissedAlertsProvider);
  return alertsAsync.maybeWhen(
    data: (list) =>
        list.where((a) => !dismissed.contains(a.id)).toList(growable: false),
    orElse: () => [],
  );
});

class AlertsListSection extends ConsumerWidget {
  const AlertsListSection({super.key});

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.dangerRed;
      case 'warning':
        return AppColors.alertOrange;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(visibleAlertsProvider);

    if (alerts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Aucune alerte récente',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        return Dismissible(
          key: ValueKey(alert.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.primaryPale,
            child: const Icon(
              Icons.check_outlined,
              color: AppColors.primary,
            ),
          ),
          onDismissed: (_) async {
            ref.read(dismissedAlertsProvider.notifier).update(
                  (s) => {...s, alert.id},
                );
            try {
              await ref.read(alertActionsProvider).acknowledge(alert.id);
            } catch (_) {}
          },
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.warning_amber_outlined,
              color: _severityColor(alert.severity),
              size: 22,
            ),
            title: Text(
              alert.message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              formatRelativeDuration(
                DateTime.now().toUtc().difference(alert.timestamp.toUtc()),
              ),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
