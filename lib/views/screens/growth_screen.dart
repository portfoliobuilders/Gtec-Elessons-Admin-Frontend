import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/growth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/hatch_avatar.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 11 · Growth & Insights — sales · marketing · service.
class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GrowthController>();

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 9,
      user: NavPresets.gtecAdmin,
      title: 'Growth & Insights',
      actions: const [
        OutlineButtonX(
            label: 'Last 30 days', trailingIconPaths: AppIcons.chevronDown),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiGrid(
              children: [
                for (final kpi in controller.kpis) KpiDeltaCard(kpi: kpi),
              ],
            ),
            const SizedBox(height: 22),
            FlexRow(
              items: [
                (12, _FunnelCard(controller: controller)),
                (15, _NeedsAttentionCard(controller: controller)),
              ],
            ),
            const SizedBox(height: 20),
            FlexRow(
              items: [
                (15, _TeacherActivityCard(controller: controller)),
                (12, _ReviewsCard(controller: controller)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FunnelCard extends StatelessWidget {
  const _FunnelCard({required this.controller});

  final GrowthController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales funnel', style: AppTextStyles.cardTitle),
          const SizedBox(height: 18),
          for (int i = 0; i < controller.funnel.length; i++)
            Padding(
              padding: EdgeInsets.only(
                  bottom: i == controller.funnel.length - 1 ? 0 : 11),
              child: FunnelBar(
                label: controller.funnel[i].$1,
                value: controller.funnel[i].$2,
                widthFraction: controller.funnel[i].$3,
                color: switch (i) {
                  0 => AppColors.navy,
                  1 => AppColors.funnel2,
                  2 => AppColors.funnel3,
                  3 => AppColors.funnel4,
                  _ => AppColors.green,
                },
                labelColor: i == 4 ? AppColors.navy : AppColors.body,
                labelWeight: i == 4 ? FontWeight.w700 : FontWeight.w600,
                valueColor: i == 4 ? AppColors.green : AppColors.ink,
              ),
            ),
        ],
      ),
    );
  }
}

class _NeedsAttentionCard extends StatelessWidget {
  const _NeedsAttentionCard({required this.controller});

  final GrowthController controller;

  static const List<double> _flexes = [2, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Needs attention ',
                  style: AppTextStyles.cardTitle,
                  children: [
                    TextSpan(
                      text: '· worst performers',
                      style: AppTextStyles.jakarta(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Text('All courses',
                  style: AppTextStyles.jakarta(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.navy)),
            ],
          ),
          const SizedBox(height: 16),
          const GridHeaderRow(
            flexes: _flexes,
            labels: ['Course', 'Drop-off', 'Rating', 'Refunds'],
            padding: EdgeInsets.only(bottom: 11),
            background: null,
            fontSize: 10.5,
          ),
          for (int i = 0; i < controller.needsAttention.length; i++)
            GridRow(
              flexes: _flexes,
              padding: const EdgeInsets.symmetric(vertical: 13),
              bottomBorder: i != controller.needsAttention.length - 1,
              cells: [
                Text(controller.needsAttention[i].name,
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.ink)),
                Text(controller.needsAttention[i].dropOff ?? '',
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w800,
                        color: controller.needsAttention[i].dropOffCritical
                            ? AppColors.red
                            : AppColors.amber)),
                Text(controller.needsAttention[i].rating ?? '',
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w700,
                        color: _ratingColor(
                            controller.needsAttention[i].rating ?? ''))),
                Text(controller.needsAttention[i].refunds ?? '',
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w700,
                        color: _refundColor(
                            controller.needsAttention[i].refunds ?? ''))),
              ],
            ),
        ],
      ),
    );
  }

  Color _ratingColor(String rating) {
    final double value = double.tryParse(rating.replaceAll('★', '')) ?? 5;
    return value >= 4.5 ? AppColors.green : AppColors.amber;
  }

  Color _refundColor(String refunds) {
    final double value = double.tryParse(refunds.replaceAll('%', '')) ?? 0;
    if (value >= 3) return AppColors.red;
    if (value >= 2) return AppColors.amber;
    return AppColors.body;
  }
}

class _TeacherActivityCard extends StatelessWidget {
  const _TeacherActivityCard({required this.controller});

  final GrowthController controller;

  static const List<double> _flexes = [1.6, 1, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teacher activity', style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          const GridHeaderRow(
            flexes: _flexes,
            labels: ['Teacher', 'Live', 'Graded', 'Doubt SLA', 'Rating'],
            padding: EdgeInsets.only(bottom: 11),
            background: null,
            fontSize: 10.5,
          ),
          for (int i = 0; i < controller.teacherActivity.length; i++)
            GridRow(
              flexes: _flexes,
              padding: const EdgeInsets.symmetric(vertical: 13),
              bottomBorder: i != controller.teacherActivity.length - 1,
              cells: [
                Row(
                  children: [
                    HatchAvatar(
                        label: controller.teacherActivity[i].monogram,
                        size: 30,
                        radius: 8,
                        fontSize: 9,
                        stripe: 5),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(controller.teacherActivity[i].name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.jakarta(
                              size: 13,
                              weight: FontWeight.w700,
                              color: AppColors.ink)),
                    ),
                  ],
                ),
                Text(controller.teacherActivity[i].live,
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.body)),
                Text(controller.teacherActivity[i].graded,
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.body)),
                Text(controller.teacherActivity[i].sla,
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w700,
                        color: controller.teacherActivity[i].slaGood
                            ? AppColors.green
                            : AppColors.red)),
                Text(controller.teacherActivity[i].rating,
                    style: AppTextStyles.jakarta(
                        size: 13,
                        weight: FontWeight.w800,
                        color: controller.teacherActivity[i].ratingGood
                            ? AppColors.green
                            : AppColors.amber)),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.controller});

  final GrowthController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Latest reviews', style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          for (int i = 0; i < controller.reviews.length; i++)
            Container(
              margin: EdgeInsets.only(
                  bottom: i == controller.reviews.length - 1 ? 0 : 13),
              padding: EdgeInsets.only(
                  bottom: i == controller.reviews.length - 1 ? 0 : 12),
              decoration: BoxDecoration(
                border: i == controller.reviews.length - 1
                    ? null
                    : const Border(
                        bottom:
                            BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(controller.reviews[i].author,
                          style: AppTextStyles.jakarta(
                              size: 12.5,
                              weight: FontWeight.w700,
                              color: AppColors.ink)),
                      Text(controller.reviews[i].rating,
                          style: AppTextStyles.jakarta(
                              size: 12,
                              weight: FontWeight.w800,
                              color: controller.reviews[i].ratingGood
                                  ? AppColors.green
                                  : AppColors.amber)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(controller.reviews[i].text,
                      style: AppTextStyles.jakarta(
                          size: 12,
                          weight: FontWeight.w500,
                          color: AppColors.softGrey,
                          height: 1.45)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
