import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'sf_card.dart';

class ErrorRetryCard extends StatelessWidget {
  const ErrorRetryCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SfCard(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 32),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 40),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
