import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Navy filled button — `height:42; radius:11; background:#16244A`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.iconPaths,
    this.iconFilled = false,
    this.iconStroke = 2.2,
    this.onTap,
    this.background = AppColors.navy,
    this.glow = false,
    this.height = AppSizes.buttonHeight,
    this.fontSize = 13.5,
  });

  final String label;
  final String? iconPaths;
  final bool iconFilled;
  final double iconStroke;
  final VoidCallback? onTap;
  final Color background;
  final bool glow;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            boxShadow: glow ? AppTheme.glow(background) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPaths != null) ...[
                AppIcon(iconPaths!,
                    size: 16,
                    color: AppColors.white,
                    strokeWidth: iconStroke,
                    filled: iconFilled),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.jakarta(
                  size: fontSize,
                  weight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordered ghost button — `border:1.5px solid #E0E4EC`.
class OutlineButtonX extends StatelessWidget {
  const OutlineButtonX({
    super.key,
    required this.label,
    this.iconPaths,
    this.trailingIconPaths,
    this.onTap,
    this.color = AppColors.body,
    this.height = AppSizes.buttonHeight,
  });

  final String label;
  final String? iconPaths;
  final String? trailingIconPaths;
  final VoidCallback? onTap;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPaths != null) ...[
                AppIcon(iconPaths!, size: 16, color: color, strokeWidth: 2.2),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.jakarta(
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (trailingIconPaths != null) ...[
                const SizedBox(width: 8),
                AppIcon(trailingIconPaths!,
                    size: 14, color: AppColors.grey, strokeWidth: 2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
