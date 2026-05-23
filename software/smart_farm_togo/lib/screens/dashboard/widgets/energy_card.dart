import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/energy_provider.dart';
import '../../../widgets/error_retry_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/sf_card.dart';
import '../../../widgets/sf_progress_bar.dart';

class EnergyCard extends ConsumerWidget {
  const EnergyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energyStreamProvider);

    return energyAsync.when(
      loading: () => const LoadingSkeleton(height: 100),
      error: (e, _) => ErrorRetryCard(
        message: 'Données énergie indisponibles.',
        onRetry: () => ref.invalidate(energyStreamProvider),
      ),
      data: (energy) {
        if (energy == null) {
          return const SfCard(
            child: Text(
              'Énergie indisponible',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          );
        }

        return SfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Batterie solaire',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${energy.batterySocPct.round()} %',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SfProgressBar(
                value: energy.batterySocPct / 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.bolt_outlined,
                    size: 16,
                    color: AppColors.alertOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${energy.solarPowerW.round()} W solaire',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
