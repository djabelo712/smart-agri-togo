import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/analytics_charts_provider.dart';
import '../../../widgets/sf_card.dart';

class HistoriqueTab extends ConsumerWidget {
  const HistoriqueTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moisture = ref.watch(moistureHistory7DaysProvider);
    final avgKs = ref.watch(avgFieldStressKsProvider);
    final alertZones = ref.watch(alertZonesCountProvider);

    final spots = List.generate(
      moisture.length,
      (i) => FlSpot(i.toDouble(), moisture[i]),
    );

    final maxY = 0.35;
    final minY = 0.10;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SfCard(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Humidité moyenne — 7 derniers jours',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (moisture.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.05,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.separator,
                        strokeWidth: 0.5,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 0.05,
                          getTitlesWidget: (value, _) => Text(
                            value.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i < 0 || i >= weekDayLabelsFull.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                weekDayLabelsFull[i],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: FieldParams.thetaP,
                          color: AppColors.alertOrange,
                          strokeWidth: 1,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            labelResolver: (_) => 'θp',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.alertOrange,
                            ),
                          ),
                        ),
                        HorizontalLine(
                          y: FieldParams.thetaFc,
                          color: AppColors.primaryLight,
                          strokeWidth: 1,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            labelResolver: (_) => 'θfc',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.primary,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SfCard(
                child: _MetricTile(
                  label: 'Ks moyen',
                  value: avgKs.toStringAsFixed(2),
                  color: avgKs < 0.5
                      ? AppColors.alertOrange
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SfCard(
                child: _MetricTile(
                  label: 'Zones en alerte',
                  value: '$alertZones',
                  color: alertZones > 0
                      ? AppColors.dangerRed
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
