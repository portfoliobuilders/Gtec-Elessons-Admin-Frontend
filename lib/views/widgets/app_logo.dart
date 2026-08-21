import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// The official G-TEC eLessons.net Hybrid School logo — a wide horizontal
/// wordmark (transparent background, dark ink + navy blue), the single
/// source of truth for this app's visual branding. Colored for a light
/// background, so every current placement (sidebar, login brand panel,
/// splash) sits on this app's dark navy chrome and wraps it in a white
/// rounded card for contrast rather than placing it directly on navy.
///
/// Display only — no navigation/auth/business logic here.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.radius = 10,
  });

  /// The rendered image height; width is computed from the asset's actual
  /// pixel dimensions (1999×507) rather than left for `Image` to derive
  /// from the decoded image after the fact — with only `height` set,
  /// `Image`'s RenderBox reports zero width until its ImageStream resolves
  /// and triggers a relayout, which visibly stalled for this asset (a large
  /// 4.9 MB PNG) in testing. Computing both dimensions upfront makes layout
  /// correct on the very first frame, independent of decode timing.
  static const double _aspectRatio = 1999 / 507;

  final double height;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Image.asset(
        'assets/images/gtec_logo.png',
        width: height * _aspectRatio,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
