import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/ml_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../widgets/error_retry_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/sf_card.dart';
import 'forecast_strip.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherStreamProvider);
    final et0TodayAsync = ref.watch(et0TodayProvider);
    final forecastAsync = ref.watch(et0ForecastProvider);

    if (weatherAsync.isLoading) {
      return const LoadingSkeleton(height: 200);
    }
    if (weatherAsync.hasError) {
      return ErrorRetryCard(
        message: 'Impossible de charger la météo.',
        onRetry: () {
          ref.invalidate(weatherStreamProvider);
          ref.invalidate(et0TodayProvider);
          ref.invalidate(et0ForecastProvider);
        },
      );
    }

    final weather = weatherAsync.value;
    if (weather == null) {
      return const SfCard(
        child: Text(
          'Données météo indisponibles',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    final et0Today = et0TodayAsync.maybeWhen(
      data: (v) => v,
      orElse: () => weather.et0MmDay,
    );

    final forecastData = forecastAsync.maybeWhen(
      data: (m) => m,
      orElse: () => <String, dynamic>{},
    );
    final forecastFallback = ref.watch(forecastStreamProvider).valueOrNull;
    final et0Days = (forecastData['et0_7days'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        forecastFallback?.et0Next7Days ??
        [4.2, 4.5, 3.9, 4.7, 4.3, 4.1, 4.6];
    final rainDays = (forecastData['rain_7days'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        forecastFallback?.rainNext7Days ??
        [0.0, 0.0, 2.1, 0.0, 0.0, 0.0, 0.0];

    return SfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 20,
                color: AppColors.waterBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Météo ${AppConstants.locationLabel.split(',').first}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricColumn(
                label: 'Temp. (°C)',
                value: weather.tempC.toStringAsFixed(1),
              ),
              _MetricColumn(
                label: 'Humidité (%)',
                value: weather.humidityPct.toStringAsFixed(0),
              ),
              _MetricColumn(
                label: 'ET₀/jour (mm)',
                value: et0Today.toStringAsFixed(1),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Model 1 · XGBoost R²=0.96',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.separator,
            ),
          ),
          const Text(
            'Prévisions ET₀ — 7 jours (mm/j)',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ForecastStrip(et0Values: et0Days, rainValues: rainDays),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
