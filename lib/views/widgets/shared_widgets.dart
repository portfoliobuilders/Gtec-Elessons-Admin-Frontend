import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/hatch_avatar.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/models.dart';

/// KPI card with icon tile + delta pill (Dashboard variant).
class KpiIconCard extends StatelessWidget {
  const KpiIconCard({super.key, required this.kpi});

  final KpiModel kpi;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.kpiPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kpi.accent ? AppColors.redIconBg : AppColors.navyChipBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: AppIcon(
                    kpi.iconPaths ?? AppIcons.user,
                    size: 20,
                    color: kpi.accent ? AppColors.red : AppColors.navy,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
              if (kpi.delta != null)
                DeltaBadge(kpi.delta!, positive: kpi.deltaPositive),
            ],
          ),
          const SizedBox(height: 14),
          Text(kpi.value, style: AppTextStyles.kpiValue),
          const SizedBox(height: 5),
          Text(kpi.caption, style: AppTextStyles.kpiCaption),
        ],
      ),
    );
  }
}

/// Plain KPI card — caption over value (Teacher / Payments variant).
class KpiPlainCard extends StatelessWidget {
  const KpiPlainCard({super.key, required this.kpi, this.valueSize = 26});

  final KpiModel kpi;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final Color valueColor = kpi.accent
        ? AppColors.red
        : (kpi.caption == 'Converted' ? AppColors.green : AppColors.ink);
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.kpiPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kpi.caption, style: AppTextStyles.kpiCaption),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: kpi.value,
              style: AppTextStyles.jakarta(
                size: valueSize,
                weight: FontWeight.w800,
                color: valueColor,
                letterSpacing: -0.5,
              ),
              children: [
                if (kpi.valueSuffix != null)
                  TextSpan(
                    text: ' ${kpi.valueSuffix}',
                    style: AppTextStyles.jakarta(
                      size: 14,
                      weight: FontWeight.w800,
                      color: AppColors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// KPI card with inline delta arrow (Growth variant, padding 18).
class KpiDeltaCard extends StatelessWidget {
  const KpiDeltaCard({super.key, required this.kpi});

  final KpiModel kpi;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kpi.caption,
              style: AppTextStyles.jakarta(
                  size: 12, weight: FontWeight.w600, color: AppColors.grey)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                kpi.value,
                style: AppTextStyles.jakarta(
                  size: 24,
                  weight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                kpi.delta ?? '',
                style: AppTextStyles.jakarta(
                  size: 12,
                  weight: FontWeight.w800,
                  color:
                      kpi.deltaPositive ? AppColors.green : AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Responsive KPI grid — 4 → 2 → 1 columns.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children, this.gap = AppSizes.gridGap});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final int columns = Responsive.kpiColumns(context);
    return LayoutBuilder(
      builder: (context, c) {
        final double w = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: w, child: child),
          ],
        );
      },
    );
  }
}

/// Avatar + name (+ optional subtitle) — first cell of most tables.
class EntityCell extends StatelessWidget {
  const EntityCell({
    super.key,
    required this.monogram,
    required this.name,
    this.subtitle,
    this.avatarSize = 34,
    this.avatarRadius = 9,
    this.monoSize = 9,
  });

  final String monogram;
  final String name;
  final String? subtitle;
  final double avatarSize;
  final double avatarRadius;
  final double monoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HatchAvatar(
            label: monogram,
            size: avatarSize,
            radius: avatarRadius,
            fontSize: monoSize),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cellStrong),
              if (subtitle != null)
                Text(subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cellSub),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rounded info banner — `background:#EAEEF6; radius:12; padding:13 16`.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const AppIcon(AppIcons.info,
              size: 17, color: AppColors.navy, strokeWidth: 1.8),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.jakarta(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-or-more-pane row: on desktop children sit side by side with equal
/// heights (like CSS grid stretch); below desktop they stack vertically.
class FlexRow extends StatelessWidget {
  const FlexRow({super.key, required this.items, this.gap = 20});

  /// (flex, child) — flexes mirror the design's fr units × 10.
  final List<(int, Widget)> items;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i != 0) SizedBox(width: gap),
              Expanded(flex: items[i].$1, child: items[i].$2),
            ],
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) SizedBox(height: gap),
          items[i].$2,
        ],
      ],
    );
  }
}

/// Standard page body padding — `padding:28px 30px` (24 top on some screens).
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.topPadding = 28});

  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final bool phone = Responsive.isPhone(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        phone ? 16 : AppSizes.pagePaddingH,
        topPadding,
        phone ? 16 : AppSizes.pagePaddingH,
        AppSizes.pagePaddingH,
      ),
      child: child,
    );
  }
}
