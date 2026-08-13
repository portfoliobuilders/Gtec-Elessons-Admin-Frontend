import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/pricing_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/models.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 03 · Pricing Manager — INR vs GCC.
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  static const List<double> _flexes = [2.2, 1.1, 1.1, 1.1, 0.9];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PricingController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 2,
      user: NavPresets.riyaContentAdmin,
      title: 'Pricing Manager',
      actions: [
        if (desktop)
          SegmentedControl(
            segments: const ['Recorded', 'Live + Recorded'],
            selected: controller.planSegment,
            onChanged: controller.setSegment,
          ),
        if (desktop)
          OutlineButtonX(
            label: controller.classFilter,
            trailingIconPaths: AppIcons.chevronDown,
            color: AppColors.body,
          ),
        const PrimaryButton(
            label: 'Save changes', iconPaths: AppIcons.check, iconStroke: 1.9),
      ],
      body: PageBody(
        topPadding: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const InfoBanner(
              text:
                  'Set list prices per region. GCC prices auto-suggest from the '
                  'live FX rate — override any cell to lock a manual price.',
            ),
            const SizedBox(height: 20),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  const GridHeaderRow(
                    flexes: _flexes,
                    gap: 14,
                    padding:
                        EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    labels: [
                      'Course / Item',
                      'India · ₹ INR',
                      'GCC · AED',
                      r'GCC · $ USD',
                      'Status'
                    ],
                  ),
                  for (int i = 0; i < controller.items.length; i++)
                    _PricingRow(
                      item: controller.items[i],
                      isLast: i == controller.items.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({required this.item, required this.isLast});

  final PricingItemModel item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GridRow(
      flexes: PricingScreen._flexes,
      gap: 14,
      bottomBorder: !isLast,
      cells: [
        EntityCell(monogram: item.code, name: item.name, subtitle: item.type),
        _PriceCell(value: item.inr),
        _PriceCell(value: item.aed),
        _PriceCell(value: item.usd, overridden: item.usdOverridden),
        StatusBadge.of(item.isLive ? BadgeStatus.live : BadgeStatus.draft,
            horizontal: 10),
      ],
    );
  }
}

class _PriceCell extends StatelessWidget {
  const _PriceCell({required this.value, this.overridden = false});

  final String value;
  final bool overridden;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: overridden ? AppColors.inputBg : AppColors.white,
        border: Border.all(
          color: overridden ? AppColors.navy : AppColors.border,
          width: overridden ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: overridden
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.jakarta(
                  size: 13.5, weight: FontWeight.w700, color: AppColors.ink),
            ),
          ),
          if (overridden)
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  color: AppColors.red, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
