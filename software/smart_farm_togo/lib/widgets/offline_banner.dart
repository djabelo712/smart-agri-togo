import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/connectivity_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isDeviceOnlineProvider);
    if (online) return const SizedBox.shrink();

    return Material(
      color: AppColors.alertOrangePale,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_outlined,
                size: 18,
                color: AppColors.alertOrange,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Hors ligne — Affichage des dernières données disponibles',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
