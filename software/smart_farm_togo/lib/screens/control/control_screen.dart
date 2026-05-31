import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/control_provider.dart';
import '../../providers/field_provider.dart';
import '../../core/security/hardware_confirmation.dart';
import 'widgets/mode_selector.dart';
import 'widgets/pump_card.dart';
import 'widgets/valve_matrix.dart';

class ControlScreen extends ConsumerWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contrôle'),
            Text(
              'Gestion des vannes et de la pompe',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ModeSelector(),
            const SizedBox(height: 16),
            const PumpCard(),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Vannes — 25 zones',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _closeAllValves(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerRed,
                    side: const BorderSide(color: AppColors.dangerRed),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Tout fermer',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ValveMatrix(),
          ],
        ),
      ),
    );
  }

  Future<void> _closeAllValves(BuildContext context, WidgetRef ref) async {
    final ok = await requireDoubleConfirmation(
      context,
      action: 'Tout fermer',
      detail: 'Fermer toutes les vannes ouvertes et arrêter toute irrigation.',
    );
    if (!ok || !context.mounted) return;

    final cells = ref.read(cellsStreamProvider).valueOrNull ?? {};
    final overrides = ref.read(valveOptimisticProvider);
    final openIds = cells.entries
        .where((e) => overrides[e.key] ?? e.value.valveOpen)
        .map((e) => e.key)
        .toList();

    if (openIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune vanne ouverte'),
          backgroundColor: AppColors.textSecondary,
        ),
      );
      return;
    }

    ref.read(valveOptimisticProvider.notifier).state = {
      for (final id in openIds) id: false,
    };

    for (final id in openIds) {
      await ref.read(controlControllerProvider.notifier).closeValve(id);
    }

    if (!context.mounted) return;
    ref.read(controlControllerProvider).whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${openIds.length} vanne(s) fermée(s)'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      error: (_, __) {
        ref.read(valveOptimisticProvider.notifier).state = {};
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
