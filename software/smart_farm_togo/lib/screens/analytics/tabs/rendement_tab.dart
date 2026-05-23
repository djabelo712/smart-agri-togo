import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/analytics_charts_provider.dart';
import '../../../widgets/sf_card.dart';
import '../../../widgets/sf_chip.dart';
import '../../../widgets/sf_progress_bar.dart';

class RendementTab extends ConsumerWidget {
  const RendementTab({super.key});

  SfChipVariant _statusVariant(String status) {
    switch (status) {
      case 'Bon':
        return SfChipVariant.green;
      case 'Moyen':
        return SfChipVariant.orange;
      default:
        return SfChipVariant.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crops = ref.watch(cropYieldsProvider);
    final revenue = ref.watch(estimatedRevenueProvider);
    final satisfaction = ref.watch(hydricSatisfactionProvider);

    final revenueFmt = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    ).format(revenue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rendement prévu par culture (t/ha)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...crops.map((c) {
                final crop = c['crop'] as String;
                final yield = (c['yield_t_ha'] as num).toDouble();
                final status = c['status'] as String;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          crop,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${yield.toStringAsFixed(1)} t/ha',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SfChip(
                        label: status,
                        variant: _statusVariant(status),
                        showDot: false,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revenu net estimé',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                revenueFmt,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Satisfaction hydrique globale',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SfProgressBar(
                value: satisfaction,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '${(satisfaction * 100).round()} %',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
