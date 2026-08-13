import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';

/// Floating circular action button — the "open this level" affordance on
/// grade and subject cards.
class CircleArrowButton extends StatelessWidget {
  const CircleArrowButton({
    super.key,
    this.onTap,
    this.size = 40,
    this.background = AppColors.navy,
    this.iconColor = AppColors.white,
  });

  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: AppTheme.glow(background),
          ),
          child: Center(
            child: AppIcon(AppIcons.arrowUpRight,
                size: size * 0.42, color: iconColor, strokeWidth: 2.2),
          ),
        ),
      ),
    );
  }
}

/// Three-dot overflow menu (Edit / Archive) styled with app tokens.
class OverflowMenuButton extends StatelessWidget {
  const OverflowMenuButton({super.key, this.onEdit, this.onArchive, this.color});

  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 28),
      color: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'archive') onArchive?.call();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          height: 38,
          child: Text('Edit', style: AppTextStyles.cell),
        ),
        PopupMenuItem(
          value: 'archive',
          height: 38,
          child: Text('Archive',
              style: AppTextStyles.jakarta(
                  size: 13, weight: FontWeight.w600, color: AppColors.red)),
        ),
      ],
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (color ?? AppColors.ink).withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AppIcon(AppIcons.moreVertical,
              size: 16, color: color ?? AppColors.softGrey, strokeWidth: 2),
        ),
      ),
    );
  }
}
