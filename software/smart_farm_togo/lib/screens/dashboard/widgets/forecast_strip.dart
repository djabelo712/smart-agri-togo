import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';

/// Barres ET₀ sur 7 jours avec indicateur pluie optionnel.
class ForecastStrip extends StatelessWidget {
  const ForecastStrip({
    super.key,
    required this.et0Values,
    this.rainValues,
  });

  final List<double> et0Values;
  final List<double>? rainValues;

  @override
  Widget build(BuildContext context) {
    final data = et0Values.length >= 7
        ? et0Values.take(7).toList()
        : List<double>.filled(7, 0);
    final rain = rainValues != null && rainValues!.length >= 7
        ? rainValues!.take(7).toList()
        : List<double>.filled(7, 0);

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final scale = maxVal > 0 ? maxVal : 1.0;

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = data[i];
          final barH = (v / scale) * 48;
          final hasRain = rain[i] > 0.1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasRain)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(
                        Icons.water_drop_outlined,
                        size: 10,
                        color: AppColors.waterBlue,
                      ),
                    ),
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
