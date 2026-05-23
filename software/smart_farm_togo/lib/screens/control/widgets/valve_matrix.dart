import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cell_model.dart';
import '../../../providers/control_provider.dart';
import '../../../providers/field_provider.dart';
import '../../../widgets/confirm_dialog.dart';

String _cropAbbr(String crop) {
  if (crop.length <= 3) return crop;
  return crop.substring(0, 3);
}

class ValveMatrix extends ConsumerWidget {
  const ValveMatrix({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellsAsync = ref.watch(cellsStreamProvider);
    final overrides = ref.watch(valveOptimisticProvider);

    return cellsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Text(
        'Impossible de charger les vannes.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      data: (cells) {
        final sorted = FieldLayout.allCellIds
            .map((id) => cells[id])
            .whereType<FieldCell>()
            .toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final cell = sorted[index];
            final open = overrides[cell.id] ?? cell.valveOpen;
            return _ValveTile(
              cell: cell,
              isOpen: open,
              onTap: () => _onValveTap(context, ref, cell, open),
            );
          },
        );
      },
    );
  }

  Future<void> _onValveTap(
    BuildContext context,
    WidgetRef ref,
    FieldCell cell,
    bool isOpen,
  ) async {
    if (isOpen) {
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
      _snackResult(context, ref, cell.id, success: 'Vanne ${cell.id} fermée');
    } else {
      final ok = await showConfirmDialog(
        context: context,
        title: 'Ouvrir la vanne',
        message: 'Ouvrir la vanne ${cell.id} pendant 15 minutes ?',
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
      _snackResult(
        context,
        ref,
        cell.id,
        success: 'Vanne ${cell.id} ouverte (15 min)',
      );
    }
  }

  void _snackResult(
    BuildContext context,
    WidgetRef ref,
    String cellId, {
    required String success,
  }) {
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
        ref.read(valveOptimisticProvider.notifier).update((m) {
          final copy = Map<String, bool>.from(m)..remove(cellId);
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

class _ValveTile extends StatelessWidget {
  const _ValveTile({
    required this.cell,
    required this.isOpen,
    required this.onTap,
  });

  final FieldCell cell;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOpen ? AppColors.waterBluePale : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOpen ? AppColors.waterBlue : AppColors.cardBorder,
              width: isOpen ? 1 : 0.5,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cell.id,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppColors.waterBlue
                          : AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _cropAbbr(cell.crop),
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
