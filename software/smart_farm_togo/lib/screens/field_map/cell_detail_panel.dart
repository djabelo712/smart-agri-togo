import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/moisture_utils.dart';
import '../../data/models/cell_model.dart';
import '../../providers/control_provider.dart';
import '../../providers/field_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/sf_card.dart';
import '../../widgets/sf_chip.dart';
import '../../widgets/sf_progress_bar.dart';

class CellDetailPanel extends ConsumerWidget {
  const CellDetailPanel({
    super.key,
    required this.cell,
    this.valveOpenOverride,
  });

  final FieldCell cell;
  final bool? valveOpenOverride;

  bool get _valveOpen => valveOpenOverride ?? cell.valveOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = moistureColor(cell.theta).withValues(alpha: 0.2);
    final thetaPct = (cell.theta / FieldParams.thetaSat).clamp(0.0, 1.0);
    final ksPct = cell.stressKs.clamp(0.0, 1.0);
    final ksColor = cell.stressKs < 0.5
        ? AppColors.alertOrange
        : AppColors.primary;

    String irrigationLabel = 'Dernière irrigation : inconnue';
    if (cell.lastIrrigatedAt != null) {
      final diff = DateTime.now().toUtc().difference(cell.lastIrrigatedAt!.toUtc());
      irrigationLabel =
          'Dernière irrigation : ${formatRelativeDuration(diff)}';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zone ${cell.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cell.treatment} · ${cell.crop}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SfChip(
                  label: 'θ ${cell.theta.toStringAsFixed(2)}',
                  variant: _chipVariantForTheta(cell.theta),
                  showDot: false,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricBar(
                    label: 'Humidité θ',
                    value: cell.theta.toStringAsFixed(2),
                    progress: thetaPct,
                    color: moistureColor(cell.theta),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBar(
                    label: 'Stress Ks',
                    value: cell.stressKs.toStringAsFixed(2),
                    progress: ksPct,
                    color: ksColor,
                  ),
                ),
              ],
            ),
            const SfDivider(verticalPadding: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    irrigationLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '+${cell.cumulativeIrrigationMm.toStringAsFixed(0)} mm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.waterBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _valveOpen
                        ? null
                        : () => _onOpenValve(context, ref),
                    child: const Text('Ouvrir 15 min'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        !_valveOpen ? null : () => _onCloseValve(context, ref),
                    child: const Text('Fermer vanne'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SfChipVariant _chipVariantForTheta(double theta) {
    if (theta < 0.18) return SfChipVariant.orange;
    if (theta < 0.25) return SfChipVariant.green;
    return SfChipVariant.blue;
  }

  Future<void> _onOpenValve(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context: context,
      title: 'Ouvrir la vanne',
      message:
          'Ouvrir la vanne de la zone ${cell.id} pendant 15 minutes ?',
    );
    if (ok != true || !context.mounted) return;

    ref.read(valveOptimisticProvider.notifier).update((m) => {
          ...m,
          cell.id: true,
        });

    await ref
        .read(controlControllerProvider.notifier)
        .openValve(cell.id, durationMin: 15);

    if (!context.mounted) return;
    final state = ref.read(controlControllerProvider);
    state.whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vanne ${cell.id} ouverte (15 min)'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      error: (_, __) {
        ref.read(valveOptimisticProvider.notifier).update((m) {
          final copy = Map<String, bool>.from(m)..remove(cell.id);
          return copy;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion — réessayer'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      },
    );
  }

  Future<void> _onCloseValve(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context: context,
      title: 'Fermer la vanne',
      message: 'Fermer la vanne de la zone ${cell.id} ?',
    );
    if (ok != true || !context.mounted) return;

    ref.read(valveOptimisticProvider.notifier).update((m) => {
          ...m,
          cell.id: false,
        });

    await ref.read(controlControllerProvider.notifier).closeValve(cell.id);

    if (!context.mounted) return;
    final state = ref.read(controlControllerProvider);
    state.whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vanne ${cell.id} fermée'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      error: (_, __) {
        ref.read(valveOptimisticProvider.notifier).update((m) {
          final copy = Map<String, bool>.from(m)..remove(cell.id);
          return copy;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion — réessayer'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      },
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        SfProgressBar(value: progress, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}
