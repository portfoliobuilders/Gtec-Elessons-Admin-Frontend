import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Replicates the design's placeholder avatars:
/// `repeating-linear-gradient(135deg, c1 0 6px, c2 6px 12px)`
/// with a JetBrains Mono monogram centered on top.
class HatchAvatar extends StatelessWidget {
  const HatchAvatar({
    super.key,
    required this.label,
    this.size = 34,
    this.radius = 9,
    this.dark = false,
    this.stripe = 6,
    this.fontSize = 10,
  });

  final String label;
  final double size;
  final double radius;
  final bool dark;
  final double stripe;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _HatchPainter(
            c1: dark ? AppColors.hatchDark1 : AppColors.hatchLight1,
            c2: dark ? AppColors.hatchDark2 : AppColors.hatchLight2,
            stripe: stripe,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.mono(
                size: fontSize,
                color: dark ? AppColors.sidebarAvatarText : AppColors.hatchLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bare hatched box (no monogram) — used for video thumbnails etc.
class HatchBox extends StatelessWidget {
  const HatchBox({
    super.key,
    this.radius = 11,
    this.stripe = 9,
    this.child,
  });

  final double radius;
  final double stripe;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _HatchPainter(
          c1: AppColors.hatchLight1,
          c2: AppColors.hatchLight2,
          stripe: stripe,
        ),
        child: child,
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  _HatchPainter({required this.c1, required this.c2, required this.stripe});

  final Color c1;
  final Color c2;
  final double stripe;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()..color = c2;
    canvas.drawRect(Offset.zero & size, bg);

    final Paint fg = Paint()
      ..color = c1
      ..strokeWidth = stripe;

    // 135deg diagonal stripes.
    final double extent = size.width + size.height;
    for (double d = -extent; d < extent; d += stripe * 2) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        fg,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter old) =>
      old.c1 != c1 || old.c2 != c2 || old.stripe != stripe;
}
