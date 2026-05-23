import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/system_model.dart';
import '../../../providers/energy_provider.dart';
import '../../../widgets/error_retry_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/sf_card.dart';
import '../../../widgets/sf_chip.dart';

class SystemStatusCard extends ConsumerWidget {
  const SystemStatusCard({super.key});

  bool _isOnline(SystemStatus system) {
    final hb = system.lastHeartbeat;
    if (hb == null) return false;
    return DateTime.now().toUtc().difference(hb.toUtc()) <
        AppConstants.offlineThreshold;
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'MPC':
        return 'MPC Actif';
      case 'PID':
        return 'PID Actif';
      default:
        return 'Manuel';
    }
  }

  SfChipVariant _modeVariant(String mode) {
    switch (mode) {
      case 'MPC':
        return SfChipVariant.blue;
      case 'PID':
        return SfChipVariant.orange;
      default:
        return SfChipVariant.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemStreamProvider);

    return systemAsync.when(
      loading: () => const LoadingSkeleton(height: 56),
      error: (e, _) => ErrorRetryCard(
        message: 'Impossible de charger le statut système.',
        onRetry: () => ref.invalidate(systemStreamProvider),
      ),
      data: (system) {
        if (system == null) {
          return const SfCard(
            child: Text(
              'Statut système indisponible',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          );
        }

        final online = _isOnline(system);
        final valveLabel = system.activeValvesCount <= 1
            ? '${system.activeValvesCount} vanne ouverte'
            : '${system.activeValvesCount} vannes ouvertes';

        return SfCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SfChip(
                label: online ? 'En ligne' : 'Hors ligne',
                variant: online ? SfChipVariant.green : SfChipVariant.orange,
              ),
              SfChip(
                label: _modeLabel(system.controllerMode),
                variant: _modeVariant(system.controllerMode),
              ),
              SfChip(
                label: system.pumpRunning ? 'Pompe active' : 'Pompe arrêtée',
                variant:
                    system.pumpRunning ? SfChipVariant.green : SfChipVariant.grey,
                pulse: system.pumpRunning,
              ),
              SfChip(
                label: valveLabel,
                variant: SfChipVariant.grey,
                showDot: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
