import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Named badge variants used across the design.
enum BadgeStatus { live, draft, active, invited, inactive, paid, lead, trial, failed, superAdmin, admin, teacher, expiring, refunded }

/// Small uppercase pill badge, e.g. LIVE / DRAFT / ACTIVE / PAID …
class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.text, {
    super.key,
    required this.color,
    required this.background,
    this.fontSize = 10.5,
    this.horizontal = 9,
  });

  /// Convenience factory from a semantic status.
  factory StatusBadge.of(BadgeStatus status,
      {double fontSize = 10.5, double horizontal = 9}) {
    switch (status) {
      case BadgeStatus.live:
        return StatusBadge('LIVE',
            color: AppColors.green, background: AppColors.greenBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.active:
        return StatusBadge('ACTIVE',
            color: AppColors.green, background: AppColors.greenBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.paid:
        return StatusBadge('PAID',
            color: AppColors.green, background: AppColors.greenBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.draft:
        return StatusBadge('DRAFT',
            color: AppColors.amber, background: AppColors.amberBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.trial:
        return StatusBadge('TRIAL',
            color: AppColors.amber, background: AppColors.amberBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.expiring:
        return StatusBadge('EXPIRING',
            color: AppColors.amber, background: AppColors.amberBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.teacher:
        return StatusBadge('TEACHER',
            color: AppColors.amber, background: AppColors.amberBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.invited:
        return StatusBadge('INVITED',
            color: AppColors.grey, background: AppColors.greyChipBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.inactive:
        return StatusBadge('INACTIVE',
            color: AppColors.grey, background: AppColors.greyChipBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.refunded:
        return StatusBadge('REFUNDED',
            color: AppColors.grey, background: AppColors.greyChipBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.failed:
        return StatusBadge('FAILED',
            color: AppColors.red, background: AppColors.redBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.superAdmin:
        return StatusBadge('SUPER ADMIN',
            color: AppColors.red, background: AppColors.redBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.admin:
        return StatusBadge('ADMIN',
            color: AppColors.navy, background: AppColors.navyChipBg,
            fontSize: fontSize, horizontal: horizontal);
      case BadgeStatus.lead:
        return StatusBadge('LEAD',
            color: AppColors.navy, background: AppColors.navyChipBg,
            fontSize: fontSize, horizontal: horizontal);
    }
  }

  final String text;
  final Color color;
  final Color background;
  final double fontSize;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: AppTextStyles.jakarta(
          size: fontSize,
          weight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// Delta pill like `+8.2%` on KPI cards (padding 4x8, radius 7).
class DeltaBadge extends StatelessWidget {
  const DeltaBadge(this.text, {super.key, this.positive = true});

  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? AppColors.greenBg : AppColors.redBg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: AppTextStyles.jakarta(
          size: 12,
          weight: FontWeight.w800,
          color: positive ? AppColors.green : AppColors.red,
        ),
      ),
    );
  }
}
