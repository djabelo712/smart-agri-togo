import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Carte standard SmartFarm (radius 14, bordure fine, fond blanc).
class SfCard extends StatelessWidget {
  const SfCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: card,
    );
  }
}

/// Ligne de séparation fine (pas de tirets texte).
class SfDivider extends StatelessWidget {
  const SfDivider({super.key, this.verticalPadding = 12});

  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: const Divider(height: 0.5, thickness: 0.5, color: AppColors.separator),
    );
  }
}
