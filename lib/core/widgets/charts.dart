import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Donut equivalent of `conic-gradient(#16244A 0 72%, #E63946 72% 100%)`
/// with a white inner circle holding the total.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    required this.centerTitle,
    required this.centerCaption,
    this.size = 148,
    this.innerSize = 96,
  });

  /// Fractions (0–1) → color, in draw order from 12 o'clock.
  final List<MapEntry<double, Color>> segments;
  final String centerTitle;
  final String centerCaption;
  final double size;
  final double innerSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(segments),
        child: Center(
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  centerTitle,
                  style: AppTextStyles.jakarta(
                    size: 21,
                    weight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  centerCaption,
                  style: AppTextStyles.jakarta(
                    size: 10.5,
                    weight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments);

  final List<MapEntry<double, Color>> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    double start = -math.pi / 2; // 12 o'clock, matching conic-gradient.
    for (final seg in segments) {
      final sweep = seg.key * 2 * math.pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = seg.value);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}

/// One month of the "Enrollments · last 8 months" stacked bar chart.
class StackedBarData {
  const StackedBarData({
    required this.label,
    required this.total, // total column height as fraction of chart height
    required this.topFraction, // red segment fraction of the column
  });

  final String label;
  final double total;
  final double topFraction;
}

/// Stacked bar chart — 30px columns, red on top of navy, 6px top radius,
/// labels underneath. Column heights are fractions of the chart height,
/// exactly as in the design.
class StackedBarChart extends StatelessWidget {
  const StackedBarChart({
    super.key,
    required this.bars,
    this.height = 200,
    this.barWidth = 30,
  });

  final List<StackedBarData> bars;
  final double height;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 8 + 16, // bars + gap + label line
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < bars.length; i++) ...[
            if (i != 0) const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: bars[i].total),
                    duration: Duration(milliseconds: 500 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                      child: SizedBox(
                        width: barWidth,
                        height: height * t,
                        child: Column(
                          children: [
                            Expanded(
                              flex: (bars[i].topFraction * 100).round(),
                              child: Container(color: AppColors.red),
                            ),
                            Expanded(
                              flex: ((1 - bars[i].topFraction) * 100).round(),
                              child: Container(color: AppColors.navy),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bars[i].label,
                    style: AppTextStyles.jakarta(
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Legend dot + label used next to charts.
class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label,
      this.fontSize = 11.5});

  final Color color;
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.jakarta(
            size: fontSize,
            weight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// Horizontal funnel bar with label + value above (Growth screen).
class FunnelBar extends StatelessWidget {
  const FunnelBar({
    super.key,
    required this.label,
    required this.value,
    required this.widthFraction,
    required this.color,
    this.labelColor = AppColors.body,
    this.valueColor = AppColors.ink,
    this.labelWeight = FontWeight.w600,
  });

  final String label;
  final String value;
  final double widthFraction;
  final Color color;
  final Color labelColor;
  final Color valueColor;
  final FontWeight labelWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.jakarta(
                    size: 12.5, weight: labelWeight, color: labelColor)),
            Text(value,
                style: AppTextStyles.jakarta(
                    size: 12.5, weight: FontWeight.w800, color: valueColor)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, c) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: widthFraction),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => Container(
              height: 30,
              width: c.maxWidth * t,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
