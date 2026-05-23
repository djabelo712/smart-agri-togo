import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cell_model.dart';
import '../../providers/field_provider.dart';
import '../../widgets/error_retry_card.dart';
import '../../widgets/loading_skeleton.dart';
import 'cell_detail_panel.dart';
import 'field_legend_card.dart';
import 'field_painter.dart';

class FieldMapScreen extends ConsumerWidget {
  const FieldMapScreen({super.key});

  static const double _cellHeight = 58;
  static const double _gap = 4;
  static const double _hPadding = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellsAsync = ref.watch(cellsStreamProvider);
    final selected = ref.watch(selectedCellProvider);
    final valveOverrides = ref.watch(valveOptimisticProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Carte du champ'),
            Text(
              '25 × 25 m · 25 zones de 5×5 m',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: const [
          _TreatmentBadge(label: 'T1', color: AppColors.waterBlue),
          _TreatmentBadge(label: 'T2', color: AppColors.alertOrange),
          _TreatmentBadge(label: 'T3', color: Color(0xFF9E9E9E)),
          SizedBox(width: 8),
        ],
      ),
      body: cellsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(height: 320),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorRetryCard(
            message: 'Impossible de charger la carte du champ.',
            onRetry: () => ref.invalidate(cellsStreamProvider),
          ),
        ),
        data: (cells) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final gridWidth = constraints.maxWidth - _hPadding * 2;
              final cellSize =
                  (gridWidth - _gap * (FieldLayout.cols - 1)) / FieldLayout.cols;
              final gridHeight =
                  _cellHeight * FieldLayout.rows + _gap * (FieldLayout.rows - 1);

              FieldCell? selectedCell;
              if (selected != null) {
                selectedCell = cells[selected.id] ?? selected;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _hPadding,
                  12,
                  _hPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final id = cellIdAtOffset(
                          localPosition: details.localPosition,
                          cellWidth: cellSize,
                          cellHeight: _cellHeight,
                          gap: _gap,
                        );
                        if (id == null) return;
                        final cell = cells[id];
                        if (cell != null) {
                          ref.read(selectedCellProvider.notifier).state = cell;
                        }
                      },
                      child: SizedBox(
                        width: gridWidth,
                        height: gridHeight,
                        child: CustomPaint(
                          painter: FieldPainter(
                            cells: cells,
                            cellWidth: cellSize,
                            cellHeight: _cellHeight,
                            gap: _gap,
                            selectedId: selected?.id,
                            valveOverrides: valveOverrides,
                          ),
                          size: Size(gridWidth, gridHeight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: selectedCell == null
                          ? const SizedBox.shrink(key: ValueKey('empty'))
                          : CellDetailPanel(
                              key: ValueKey(selectedCell.id),
                              cell: selectedCell,
                              valveOpenOverride: valveOverrides[selectedCell.id],
                            ),
                    ),
                    const SizedBox(height: 12),
                    const FieldLegendCard(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TreatmentBadge extends StatelessWidget {
  const _TreatmentBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
