import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/api_provider.dart';
import '../providers/settings_provider.dart';

/// Bandeau informatif quand les données champ ou ML ne sont pas en production.
class DemoDataBanner extends ConsumerWidget {
  const DemoDataBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoModeProvider);
    final apiOk = ref.watch(apiConnectedProvider);

    if (!demo && apiOk) return const SizedBox.shrink();

    final String message;
    if (demo && apiOk) {
      message =
          'Champ simulé · modèles ML connectés au serveur (Réglages pour désactiver la démo)';
    } else if (demo) {
      message =
          'Données simulées — testez la connexion API dans Réglages pour activer les modèles ML';
    } else if (!apiOk) {
      message = 'API non connectée — certaines prévisions utilisent des valeurs par défaut';
    } else {
      return const SizedBox.shrink();
    }

    return Material(
      color: AppColors.primaryPale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
