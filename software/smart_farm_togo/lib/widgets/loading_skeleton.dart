import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.height = 80,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAE8),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          LoadingSkeleton(height: 56),
          SizedBox(height: 12),
          LoadingSkeleton(height: 140),
          SizedBox(height: 12),
          LoadingSkeleton(height: 72),
          SizedBox(height: 12),
          LoadingSkeleton(height: 200),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: LoadingSkeleton(height: 100)),
              SizedBox(width: 12),
              Expanded(child: LoadingSkeleton(height: 100)),
            ],
          ),
        ],
      ),
    );
  }
}
