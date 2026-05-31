import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/control_provider.dart';
import '../../../providers/energy_provider.dart';
import '../../../core/security/hardware_confirmation.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/sf_card.dart';
import '../../../widgets/sf_chip.dart';

final pumpRunningOverrideProvider = StateProvider<bool?>((ref) => null);

class PumpCard extends ConsumerStatefulWidget {
  const PumpCard({super.key});

  @override
  ConsumerState<PumpCard> createState() => _PumpCardState();
}

class _PumpCardState extends ConsumerState<PumpCard> {
  int _durationMin = 30;

  @override
  Widget build(BuildContext context) {
    final systemAsync = ref.watch(systemStreamProvider);
    final override = ref.watch(pumpRunningOverrideProvider);

    final running = override ??
        systemAsync.maybeWhen(
          data: (s) => s?.pumpRunning ?? false,
          orElse: () => false,
        ) ??
        false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: running
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pompe principale',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '0.5 HP · 200 L/h',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SfChip(
                  label: running ? 'En marche' : 'Arrêtée',
                  variant:
                      running ? SfChipVariant.green : SfChipVariant.grey,
                  pulse: running,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: running ? null : () => _startPump(context),
                    child: const Text('Démarrer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: !running ? null : () => _stopPump(context),
                    child: const Text('Arrêter'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Durée (min)',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Row(
              children: [15, 30, 60].map((min) {
                final selected = _durationMin == min;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: min != 60 ? 8 : 0),
                    child: ChoiceChip(
                      label: Text('$min'),
                      selected: selected,
                      onSelected: (_) => setState(() => _durationMin = min),
                      selectedColor: AppColors.primaryPale,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : AppColors.inputBorder,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPump(BuildContext context) async {
    final ok = await requireDoubleConfirmation(
      context,
      action: 'Démarrer la pompe',
      detail:
          'Démarrer la pompe principale pendant $_durationMin minutes.',
    );
    if (!ok || !context.mounted) return;

    ref.read(pumpRunningOverrideProvider.notifier).state = true;
    await ref
        .read(controlControllerProvider.notifier)
        .startPump(durationMin: _durationMin);

    if (!context.mounted) return;
    _showResult(context, success: 'Pompe démarrée ($_durationMin min)');
  }

  Future<void> _stopPump(BuildContext context) async {
    final ok = await showConfirmDialog(
      context: context,
      title: 'Arrêter la pompe',
      message: 'Arrêter la pompe principale immédiatement ?',
    );
    if (ok != true || !context.mounted) return;

    ref.read(pumpRunningOverrideProvider.notifier).state = false;
    await ref.read(controlControllerProvider.notifier).stopPump();

    if (!context.mounted) return;
    _showResult(context, success: 'Pompe arrêtée');
  }

  void _showResult(BuildContext context, {required String success}) {
    ref.read(controlControllerProvider).whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      error: (_, __) {
        ref.read(pumpRunningOverrideProvider.notifier).state = null;
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
