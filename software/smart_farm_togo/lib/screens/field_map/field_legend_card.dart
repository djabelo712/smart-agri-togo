import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/sf_card.dart';

class FieldLegendCard extends StatelessWidget {
  const FieldLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    const moistureItems = [
      ('Sec', '<0.12', Color(0xFFC62828)),
      ('Stress', '0.12–0.18', Color(0xFFE65100)),
      ('Correct', '0.18–0.25', Color(0xFF66BB6A)),
      ('Optimal', '0.25–0.30', Color(0xFF2E7D32)),
      ('Saturé', '>0.30', Color(0xFF0277BD)),
    ];

    const treatmentItems = [
      ('T1-MPC', AppColors.waterBlue),
      ('T2-PID', AppColors.alertOrange),
      ('T3-Manuel', Color(0xFF9E9E9E)),
    ];

    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Légende · Humidité volumique (m³/m³)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: moistureItems
                .map(
                  (e) => _LegendDot(
                    color: e.$3,
                    label: '${e.$1} ${e.$2}',
                  ),
                )
                .toList(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.separator,
            ),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: treatmentItems
                .map(
                  (e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: e.$2,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        e.$1,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
