import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/firebase/firebase_bootstrap.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/energy_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/sf_card.dart';
import 'alerts_list.dart';
import 'widgets/api_connection_section.dart';

class ReglagesScreen extends ConsumerWidget {
  const ReglagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoModeProvider);
    final firebaseOk = firebaseAvailable;
    final auth = ref.watch(authStateProvider);
    final notifs = ref.watch(notificationSettingsProvider);
    final system = ref.watch(systemStreamProvider);

    final userName = auth.maybeWhen(
      data: (u) => u?.displayName ?? u?.email?.split('@').first ?? 'Utilisateur',
      orElse: () => 'Utilisateur démo',
    );
    final userEmail = auth.maybeWhen(
      data: (u) => u?.email ?? 'demo@smartfarm-togo.local',
      orElse: () => 'demo@smartfarm-togo.local',
    );
    final userRole = ref.watch(userRoleLabelProvider);
    final apiConnected = ref.watch(apiConnectedProvider);

    final controllerMode = system.maybeWhen(
      data: (s) => s?.controllerMode ?? 'MPC',
      orElse: () => 'MPC',
    );

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SfCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryPale,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userRole,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('SYSTÈME'),
          SfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ReadOnlyRow(
                  label: 'Contrôleur actif',
                  value: controllerMode,
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                const _ReadOnlyRow(
                  label: 'Actualisation',
                  value: 'Temps réel',
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                _ReadOnlyRow(
                  label: 'Connexion',
                  value: ref.watch(systemConnectionLabelProvider),
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                const _ReadOnlyRow(
                  label: 'Énergie solaire',
                  value: 'Suivi actif',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ApiConnectionSection(),
          const SizedBox(height: 20),
          const _SectionLabel('NOTIFICATIONS'),
          SfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Notification de test'),
                  subtitle: const Text(
                    'Vérifier l\'affichage des alertes sur cet appareil',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () async {
                    await NotificationService.instance.showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification de test envoyée'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                SwitchListTile(
                  title: const Text('Stress hydrique'),
                  value: notifs.stressHydrique,
                  onChanged: (v) =>
                      ref.read(notificationSettingsProvider.notifier).setStress(v),
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                SwitchListTile(
                  title: const Text('Panne de pompe'),
                  value: notifs.pannePompe,
                  onChanged: (v) =>
                      ref.read(notificationSettingsProvider.notifier).setPump(v),
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                SwitchListTile(
                  title: const Text('Pluie détectée'),
                  value: notifs.pluieDetectee,
                  onChanged: (v) =>
                      ref.read(notificationSettingsProvider.notifier).setRain(v),
                ),
                const Divider(height: 0.5, indent: 14, endIndent: 14),
                SwitchListTile(
                  title: const Text('Rapport quotidien 07:00'),
                  value: notifs.rapportQuotidien,
                  onChanged: (v) =>
                      ref.read(notificationSettingsProvider.notifier).setDaily(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SfCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode démo (données simulées)'),
              subtitle: Text(
                apiConnected
                    ? 'Désactivé tant que l\'API est connectée. Réactivez pour simuler le champ.'
                    : !firebaseOk
                        ? 'Requis sans configuration Firebase'
                        : 'Données champ simulées au lieu de Firebase',
                style: const TextStyle(fontSize: 11),
              ),
              value: demo || !firebaseOk,
              onChanged: !firebaseOk
                  ? null
                  : (v) async {
                      await ref
                          .read(demoModeProvider.notifier)
                          .setDemoMode(v);
                      if (v) {
                        await ref
                            .read(apiConnectedProvider.notifier)
                            .setConnected(false);
                      }
                    },
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ALERTES RÉCENTES'),
          SfCard(child: const AlertsListSection()),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout, color: AppColors.dangerRed),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(color: AppColors.dangerRed),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.dangerRed),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context: context,
      title: 'Déconnexion',
      message: 'Confirmer la déconnexion ?',
      confirmLabel: 'Se déconnecter',
      isDanger: true,
    );
    if (ok != true || !context.mounted) return;

    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
