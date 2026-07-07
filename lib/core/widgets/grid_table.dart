import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One row of a CSS-grid-like table. [flexes] mirror the design's
/// `grid-template-columns` fractions (e.g. `2.4fr 1fr 1fr 1fr` → [2.4,1,1,1]).
class GridRow extends StatelessWidget {
  const GridRow({
    super.key,
    required this.flexes,
    required this.cells,
    this.gap = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    this.background,
    this.bottomBorder = true,
    this.borderColor = AppColors.divider,
    this.borderWidth = 1,
  }) : assert(flexes.length == cells.length);

  final List<double> flexes;
  final List<Widget> cells;
  final double gap;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final bool bottomBorder;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < cells.length; i++) {
      children.add(
        Expanded(
          flex: (flexes[i] * 100).round(),
          child: Align(alignment: Alignment.centerLeft, child: cells[i]),
        ),
      );
      if (i != cells.length - 1) children.add(SizedBox(width: gap));
    }
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        border: bottomBorder
            ? Border(
                bottom: BorderSide(color: borderColor, width: borderWidth))
            : null,
      ),
      child: Row(children: children),
    );
  }
}

/// Uppercase table header built on [GridRow].
class GridHeaderRow extends StatelessWidget {
  const GridHeaderRow({
    super.key,
    required this.flexes,
    required this.labels,
    this.gap = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    this.background = AppColors.tableHeadBg,
    this.centered = const <int>{},
    this.fontSize = 11.5,
  });

  final List<double> flexes;
  final List<String> labels;
  final double gap;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Set<int> centered;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GridRow(
      flexes: flexes,
      gap: gap,
      padding: padding,
      background: background,
      borderColor: AppColors.borderLight,
      borderWidth: 1.5,
      cells: [
        for (int i = 0; i < labels.length; i++)
          Container(
            width: double.infinity,
            alignment:
                centered.contains(i) ? Alignment.center : Alignment.centerLeft,
            child: Text(
              labels[i].toUpperCase(),
              style: AppTextStyles.jakarta(
                size: fontSize,
                weight: FontWeight.w800,
                color: AppColors.grey,
                letterSpacing: 0.4,
              ),
            ),
          ),
      ],
    );
  }
}

/// Dashed rounded border (draft module card / upload dropzone).
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.radius = 14,
    this.color = AppColors.dashedBorder,
    this.strokeWidth = 1.5,
    this.background,
  });

  final Widget child;
  final double radius;
  final Color color;
  final double strokeWidth;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(
          radius: radius, color: color, strokeWidth: strokeWidth),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(
      {required this.radius, required this.color, required this.strokeWidth});

  final double radius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
            size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(radius),
      ));

    const double dash = 6, gapLen = 4;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) =>
      old.radius != radius ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
