import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/moisture_utils.dart';
import '../../../data/models/cell_model.dart';
import '../../../providers/field_provider.dart';
import '../../../widgets/error_retry_card.dart';
import '../../../widgets/loading_skeleton.dart';
import '../../../widgets/sf_card.dart';

class MiniFieldHeatmap extends ConsumerWidget {
  const MiniFieldHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellsAsync = ref.watch(cellsStreamProvider);

    return cellsAsync.when(
      loading: () => const LoadingSkeleton(height: 140),
      error: (e, _) => ErrorRetryCard(
        message: 'Impossible de charger la carte du champ.',
        onRetry: () => ref.invalidate(cellsStreamProvider),
      ),
      data: (cells) => SfCard(
        onTap: () => context.go('/app/carte'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Carte du champ — 25×25 m',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'Voir',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HeatmapGrid(cells: cells),
            const SizedBox(height: 10),
            const _MoistureLegend(),
          ],
        ),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.cells});

  final Map<String, FieldCell> cells;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 3.0;
        const rows = FieldLayout.rows;
        const cols = FieldLayout.cols;
        final cellSize =
            (constraints.maxWidth - gap * (cols - 1)) / cols;

        return SizedBox(
          height: cellSize * rows + gap * (rows - 1),
          child: Column(
            children: List.generate(rows, (row) {
              return Padding(
                padding: EdgeInsets.only(bottom: row < rows - 1 ? gap : 0),
                child: Row(
                  children: List.generate(cols, (col) {
                    final id = FieldLayout.cellId(row, col);
                    final cell = cells[id];
                    final theta = cell?.theta ?? 0.2;
                    final valveOpen = cell?.valveOpen ?? false;

                    return Padding(
                      padding:
                          EdgeInsets.only(right: col < cols - 1 ? gap : 0),
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: moistureColor(theta),
                          borderRadius: BorderRadius.circular(5),
                          border: valveOpen
                              ? Border.all(
                                  color: AppColors.waterBlue,
                                  width: 2,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _MoistureLegend extends StatelessWidget {
  const _MoistureLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Sec', Color(0xFFC62828)),
      ('Stress', Color(0xFFE65100)),
      ('Optimal', Color(0xFF2E7D32)),
      ('Saturé', Color(0xFF0277BD)),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: items
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.$2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  e.$1,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
