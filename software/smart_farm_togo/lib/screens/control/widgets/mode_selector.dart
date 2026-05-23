import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/control_provider.dart';
import '../../../providers/energy_provider.dart';
import '../../../widgets/confirm_dialog.dart';

final controllerModeOverrideProvider = StateProvider<String?>((ref) => null);

class ModeSelector extends ConsumerWidget {
  const ModeSelector({super.key});

  static const _modes = ['MPC', 'PID', 'Manuel'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemStreamProvider);
    final override = ref.watch(controllerModeOverrideProvider);

    final currentMode = override ??
        systemAsync.maybeWhen(
          data: (s) => s?.controllerMode,
          orElse: () => null,
        ) ??
        'MPC';

    return Row(
      children: _modes.map((mode) {
        final active = currentMode == mode;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: mode != 'Manuel' ? 8 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onModeTap(context, ref, mode, currentMode),
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : AppColors.inputBorder,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      mode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                        color: active
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _onModeTap(
    BuildContext context,
    WidgetRef ref,
    String mode,
    String current,
  ) async {
    if (mode == current) return;

    final message = mode == 'Manuel'
        ? 'Le passage en Manuel désactive le contrôle automatique. Êtes-vous sûr ?'
        : 'Passer le contrôleur en mode $mode ?';

    final ok = await showConfirmDialog(
      context: context,
      title: 'Changer de mode',
      message: message,
    );
    if (ok != true || !context.mounted) return;

    ref.read(controllerModeOverrideProvider.notifier).state = mode;

    await ref.read(controlControllerProvider.notifier).setMode(mode);

    if (!context.mounted) return;
    ref.read(controlControllerProvider).whenOrNull(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mode $mode activé'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      error: (_, __) {
        ref.read(controllerModeOverrideProvider.notifier).state = null;
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
