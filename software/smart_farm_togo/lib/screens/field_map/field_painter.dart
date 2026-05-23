import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/moisture_utils.dart';
import '../../data/models/cell_model.dart';

/// Dessin de la grille 5×5 du champ (CustomPainter).
class FieldPainter extends CustomPainter {
  FieldPainter({
    required this.cells,
    required this.cellWidth,
    required this.cellHeight,
    required this.gap,
    this.selectedId,
    this.valveOverrides = const {},
  });

  final Map<String, FieldCell> cells;
  final double cellWidth;
  final double cellHeight;
  final double gap;
  final String? selectedId;
  final Map<String, bool> valveOverrides;

  static const double _radius = 10;

  @override
  void paint(Canvas canvas, Size size) {
    for (var row = 0; row < FieldLayout.rows; row++) {
      for (var col = 0; col < FieldLayout.cols; col++) {
        final id = FieldLayout.cellId(row, col);
        final cell = cells[id];
        final theta = cell?.theta ?? 0.2;
        final treatment = cell?.treatment ?? 'Manuel';
        final valveOpen = valveOverrides[id] ?? cell?.valveOpen ?? false;
        final isSelected = id == selectedId;

        final left = col * (cellWidth + gap);
        final top = row * (cellHeight + gap);
        final rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

        if (valveOpen) {
          final outlineRect = rect.inflate(3);
          final outlineRrect = RRect.fromRectAndRadius(
            outlineRect,
            const Radius.circular(_radius + 2),
          );
          canvas.drawRRect(
            outlineRrect,
            Paint()
              ..color = AppColors.waterBlue
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }

        canvas.drawRRect(
          rrect,
          Paint()..color = moistureColor(theta),
        );

        if (isSelected) {
          canvas.drawRRect(
            rrect,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }

        _paintText(
          canvas,
          id,
          Offset(left + 6, top + 5),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        );

        _paintText(
          canvas,
          theta.toStringAsFixed(2),
          Offset(left + cellWidth - 6, top + cellHeight - 14),
          fontSize: 8,
          align: TextAlign.right,
          maxWidth: cellWidth - 12,
        );

        canvas.drawCircle(
          Offset(left + cellWidth - 10, top + 10),
          3.5,
          Paint()..color = treatmentColor(treatment),
        );
      }
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    TextAlign align = TextAlign.left,
    double maxWidth = 80,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    var dx = offset.dx;
    if (align == TextAlign.right) {
      dx = offset.dx - painter.width;
    }

    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant FieldPainter old) {
    return old.cells != cells ||
        old.cellWidth != cellWidth ||
        old.cellHeight != cellHeight ||
        old.selectedId != selectedId ||
        old.valveOverrides != valveOverrides;
  }
}

/// Calcule l'identifiant de cellule touchée (null si hors grille).
String? cellIdAtOffset({
  required Offset localPosition,
  required double cellWidth,
  required double cellHeight,
  required double gap,
}) {
  final strideX = cellWidth + gap;
  final strideY = cellHeight + gap;
  final col = (localPosition.dx / strideX).floor();
  final row = (localPosition.dy / strideY).floor();

  if (row < 0 ||
      row >= FieldLayout.rows ||
      col < 0 ||
      col >= FieldLayout.cols) {
    return null;
  }

  final inCellX = localPosition.dx - col * strideX;
  final inCellY = localPosition.dy - row * strideY;
  if (inCellX > cellWidth || inCellY > cellHeight) return null;

  return FieldLayout.cellId(row, col);
}
