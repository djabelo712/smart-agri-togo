import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/energy_provider.dart';
import '../../../widgets/error_retry_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/sf_card.dart';
import '../../../widgets/sf_progress_bar.dart';

class WaterBudgetCard extends ConsumerWidget {
  const WaterBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemStreamProvider);

    return systemAsync.when(
      loading: () => const LoadingSkeleton(height: 100),
      error: (e, _) => ErrorRetryCard(
        message: 'Budget eau indisponible.',
        onRetry: () => ref.invalidate(systemStreamProvider),
      ),
      data: (system) {
        if (system == null) {
          return const _EmptyCard();
        }

        final used = system.dailyWaterUsedMm;
        final budget = system.dailyWaterBudgetMm;
        final pct = budget > 0 ? (used / budget * 100).round() : 0;
        final progress = budget > 0 ? used / budget : 0.0;

        return SfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Volume journalier',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${used.toStringAsFixed(1)} / ${budget.toStringAsFixed(1)} mm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SfProgressBar(value: progress),
              const SizedBox(height: 6),
              Text(
                '$pct % du budget',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return const SfCard(
      child: Text(
        'Données eau indisponibles',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
