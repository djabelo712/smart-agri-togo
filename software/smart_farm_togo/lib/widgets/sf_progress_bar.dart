import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SfProgressBar extends StatelessWidget {
  const SfProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.trackColor = AppColors.primaryPale,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: trackColor,
        color: color,
      ),
    );
  }
}
