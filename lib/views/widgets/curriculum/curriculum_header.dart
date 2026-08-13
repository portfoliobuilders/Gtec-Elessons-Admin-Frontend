import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

/// Page-level header for Screens 1 & 2 — big title + subtitle on the left,
/// filters/search on the right (stacks below the title on phone).
class CurriculumHeader extends StatelessWidget {
  const CurriculumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.jakarta(
              size: 32, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.7),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w600, color: AppColors.muted),
        ),
      ],
    );

    if (trailing == null) return titleColumn;

    if (Responsive.isPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titleColumn, const SizedBox(height: 16), trailing!],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleColumn),
        const SizedBox(width: 20),
        trailing!,
      ],
    );
  }
}
