import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum SfChipVariant { green, blue, orange, grey }

class SfChip extends StatelessWidget {
  const SfChip({
    super.key,
    required this.label,
    this.variant = SfChipVariant.grey,
    this.showDot = true,
    this.pulse = false,
  });

  final String label;
  final SfChipVariant variant;
  final bool showDot;
  final bool pulse;

  Color get _background {
    switch (variant) {
      case SfChipVariant.green:
        return AppColors.primaryPale;
      case SfChipVariant.blue:
        return AppColors.waterBluePale;
      case SfChipVariant.orange:
        return AppColors.alertOrangePale;
      case SfChipVariant.grey:
        return const Color(0xFFF0F0F0);
    }
  }

  Color get _foreground {
    switch (variant) {
      case SfChipVariant.green:
        return AppColors.primary;
      case SfChipVariant.blue:
        return AppColors.waterBlue;
      case SfChipVariant.orange:
        return AppColors.alertOrange;
      case SfChipVariant.grey:
        return AppColors.textSecondary;
    }
  }

  Color get _dotColor {
    switch (variant) {
      case SfChipVariant.green:
        return AppColors.primaryLight;
      case SfChipVariant.blue:
        return AppColors.waterBlue;
      case SfChipVariant.orange:
        return AppColors.alertOrange;
      case SfChipVariant.grey:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
    );

    if (pulse) {
      dot = _PulsingDot(color: _dotColor);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[dot, const SizedBox(width: 6)],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
