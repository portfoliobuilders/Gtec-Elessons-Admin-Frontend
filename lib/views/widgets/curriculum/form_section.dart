import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';

/// Labeled section inside a [CurriculumFormCard] — icon avatar, title,
/// subtitle, a hairline divider, then the section's fields.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.navyChipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AppIcon(icon, size: 20, color: AppColors.navy, strokeWidth: 1.8),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.jakarta(
                        size: 15.5, weight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.2)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.hairline),
        const SizedBox(height: 22),
        ...children,
      ],
    );
  }
}
