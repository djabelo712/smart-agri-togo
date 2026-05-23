import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';

/// Barres ET₀ sur 7 jours (CustomPaint léger).
class ForecastStrip extends StatelessWidget {
  const ForecastStrip({
    super.key,
    required this.values,
  });

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final data = values.length >= 7
        ? values.take(7).toList()
        : List<double>.filled(7, 0);

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final scale = maxVal > 0 ? maxVal : 1.0;

    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = data[i];
          final barH = (v / scale) * 48;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barH.clamp(4, 48),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekDayLabelsShort[i],
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    v.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
