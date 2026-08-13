import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/grid_table.dart';
import '../layouts/admin_shell.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/nav_presets.dart';
import '../widgets/shared_widgets.dart';

/// 01 · Analytics Dashboard.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 0,
      user: NavPresets.riyaContentAdmin,
      title: 'Dashboard',
      actions: [
        if (desktop) const AppSearchField(),
        const SizedBox(width: 4),
        const NotificationBell(),
      ],
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI row.
            KpiGrid(
              children: [
                for (final kpi in controller.kpis) KpiIconCard(kpi: kpi),
              ],
            ),
            const SizedBox(height: 24),

            // Charts row — 1.7fr : 1fr.
            FlexRow(
              gap: 18,
              items: [
                (17, _EnrollmentsCard(controller: controller)),
                (10, _RevenueSplitCard(controller: controller)),
              ],
            ),
            const SizedBox(height: 24),

            // Top courses table.
            _TopCoursesCard(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentsCard extends StatelessWidget {
  const _EnrollmentsCard({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enrollments · last 8 months',
                  style: AppTextStyles.cardTitle),
              const Row(
                children: [
                  LegendDot(color: AppColors.navy, label: 'India'),
                  SizedBox(width: 14),
                  LegendDot(color: AppColors.red, label: 'GCC'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StackedBarChart(bars: controller.enrollmentBars),
          ),
        ],
      ),
    );
  }
}

class _RevenueSplitCard extends StatelessWidget {
  const _RevenueSplitCard({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final double india = controller.revenueIndiaShare;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue split', style: AppTextStyles.cardTitle),
          const SizedBox(height: 20),
          Center(
            child: DonutChart(
              segments: [
                MapEntry(india, AppColors.navy),
                MapEntry(1 - india, AppColors.red),
              ],
              centerTitle: controller.revenueTotal,
              centerCaption: 'total',
            ),
          ),
          const SizedBox(height: 20),
          _legendRow(AppColors.navy, 'India (INR)', '${(india * 100).round()}%'),
          const SizedBox(height: 10),
          _legendRow(
              AppColors.red, 'GCC (AED/USD)', '${((1 - india) * 100).round()}%'),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.cell),
          ],
        ),
        Text(value,
            style: AppTextStyles.jakarta(
                size: 13, weight: FontWeight.w800, color: AppColors.ink)),
      ],
    );
  }
}

class _TopCoursesCard extends StatelessWidget {
  const _TopCoursesCard({required this.controller});

  final DashboardController controller;

  static const List<double> _flexes = [2.4, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top courses', style: AppTextStyles.cardTitle),
          const SizedBox(height: 18),
          const GridHeaderRow(
            flexes: _flexes,
            labels: ['Course', 'Enrollments', 'Revenue', 'Drop-off'],
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 12),
            background: null,
          ),
          for (int i = 0; i < controller.topCourses.length; i++)
            GridRow(
              flexes: _flexes,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              bottomBorder: i != controller.topCourses.length - 1,
              cells: [
                EntityCell(
                  monogram: controller.topCourses[i].code,
                  name: controller.topCourses[i].name,
                ),
                Text(controller.topCourses[i].enrollments ?? '',
                    style: AppTextStyles.jakarta(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: AppColors.body)),
                Text(controller.topCourses[i].revenue ?? '',
                    style: AppTextStyles.jakarta(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: AppColors.body)),
                Text(
                  controller.topCourses[i].dropOff ?? '',
                  style: AppTextStyles.jakarta(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: controller.topCourses[i].dropOffCritical
                        ? AppColors.red
                        : AppColors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
