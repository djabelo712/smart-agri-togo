import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/analytics_provider.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/sf_card.dart';

class RechercheTab extends ConsumerWidget {
  const RechercheTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(researchComparisonProvider);

    return comparison.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingSkeleton(height: 280),
      ),
      error: (e, _) => Center(
        child: Text(
          'Données de recherche indisponibles.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SfCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const _TableHeader(),
                _TableRow(
                  label: 'Ks moyen',
                  mpc: _fmtNum(data['MPC']?['avg_ks']),
                  pid: _fmtNum(data['PID']?['avg_ks']),
                  manuel: _fmtNum(data['Manuel']?['avg_ks']),
                ),
                const Divider(height: 0.5, thickness: 0.5),
                _TableRow(
                  label: 'Eau utilisée (mm)',
                  mpc: _fmtNum(data['MPC']?['water_mm']),
                  pid: _fmtNum(data['PID']?['water_mm']),
                  manuel: _fmtNum(data['Manuel']?['water_mm']),
                ),
                const Divider(height: 0.5, thickness: 0.5),
                _TableRow(
                  label: 'Jours de stress',
                  mpc: '${data['MPC']?['stress_days'] ?? ''}',
                  pid: '${data['PID']?['stress_days'] ?? ''}',
                  manuel: '${data['Manuel']?['stress_days'] ?? ''}',
                ),
                const Divider(height: 0.5, thickness: 0.5),
                _TableRow(
                  label: 'Bilan',
                  mpc: '${data['MPC']?['balance'] ?? ''}',
                  pid: '${data['PID']?['balance'] ?? ''}',
                  manuel: '${data['Manuel']?['balance'] ?? ''}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Publication cible',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Agricultural Water Management',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.waterBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Comparaison des traitements T1 (MPC), T2 (PID) et T3 (Manuel) '
                  'sur le pilote SmartFarm Lomé.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtNum(dynamic v) {
    if (v == null) return '';
    if (v is num) return v.toStringAsFixed(v is int ? 0 : 2);
    return '$v';
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: _HeaderCell('T1-MPC', AppColors.waterBluePale, AppColors.waterBlue),
          ),
          SizedBox(width: 4),
          Expanded(
            child: _HeaderCell(
              'T2-PID',
              AppColors.alertOrangePale,
              AppColors.alertOrange,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: _HeaderCell(
              'T3-Manuel',
              Color(0xFFF0F0F0),
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.label,
    required this.mpc,
    required this.pid,
    required this.manuel,
  });

  final String label;
  final String mpc;
  final String pid;
  final String manuel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(child: _DataCell(mpc, AppColors.waterBluePale)),
          const SizedBox(width: 4),
          Expanded(child: _DataCell(pid, AppColors.alertOrangePale)),
          const SizedBox(width: 4),
          Expanded(child: _DataCell(manuel, const Color(0xFFF0F0F0))),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.value, this.bg);

  final String value;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
