import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/grid_table.dart';
import '../../models/admin/admin_models.dart';
import '../../models/kpi_model.dart';
import '../layouts/admin_shell.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/nav_presets.dart';
import '../widgets/orders/order_money.dart';
import '../widgets/shared_widgets.dart';
import 'students_screen.dart' show studentMonogram;

/// 01 · Analytics Dashboard — real data via `GET /admin/analytics/*`
/// (overview, top-courses, recent-orders). No mock/hardcoded values.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<DashboardController>().load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 0,
      user: NavPresets.gtecAdmin,
      title: 'Dashboard',
      actions: [
        if (desktop) const AppSearchField(),
        const SizedBox(width: 4),
        if (controller.status == DashboardLoadStatus.loaded) ...[
          OutlineButtonX(
            label: 'Refresh',
            iconPaths: AppIcons.arrowRight,
            onTap: () => controller.refresh(),
          ),
          const SizedBox(width: 10),
        ],
        const NotificationBell(),
      ],
      body: PageBody(
        child: _DashboardBody(controller: controller),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case DashboardLoadStatus.initial:
      case DashboardLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 120),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.8, color: AppColors.navy),
            ),
          ),
        );
      case DashboardLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load dashboard data.',
                    style: AppTextStyles.jakarta(size: 15, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.error ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: () => controller.load()),
              ],
            ),
          ),
        );
      case DashboardLoadStatus.loaded:
        final overview = controller.overview;
        if (overview == null) {
          // Shouldn't happen (loaded implies overview was set), but avoid a
          // null crash over showing something misleading.
          return const InfoBanner(text: 'No dashboard data available.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiGrid(children: [for (final kpi in _kpisFrom(overview)) KpiIconCard(kpi: kpi)]),
            const SizedBox(height: 24),
            FlexRow(
              gap: 18,
              items: [
                (17, _EnrollmentTrendCard(overview: overview)),
                (10, _RevenueByCurrencyCard(overview: overview)),
              ],
            ),
            const SizedBox(height: 24),
            _TopCoursesCard(topCourses: controller.topCourses),
            const SizedBox(height: 24),
            _RecentOrdersCard(orders: controller.recentOrders),
          ],
        );
    }
  }

  List<KpiModel> _kpisFrom(DashboardOverviewModel overview) => [
        KpiModel(caption: 'Total Students', value: '${overview.students}', iconPaths: AppIcons.students),
        KpiModel(caption: 'Active Enrollments', value: '${overview.activeEnrollments}', iconPaths: AppIcons.userGroup),
        KpiModel(caption: 'Paid Orders', value: '${overview.paidOrders}', iconPaths: AppIcons.pricing),
        KpiModel(caption: 'Completion Rate', value: '${overview.completionRate}%', iconPaths: AppIcons.assessments),
      ];
}

/// Single-series daily enrollment count — real `enrollmentsOverTime`, no
/// fabricated India/GCC split (the backend doesn't return enrollments
/// broken down by region per day, only revenue). Reuses [StackedBarChart]
/// with an all-navy column (`topFraction: 0`) rather than introducing a
/// new chart widget.
class _EnrollmentTrendCard extends StatelessWidget {
  const _EnrollmentTrendCard({required this.overview});

  final DashboardOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final days = overview.enrollmentsOverTime;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enrollments · last 30 days', style: AppTextStyles.cardTitle),
              const LegendDot(color: AppColors.navy, label: 'Enrollments'),
            ],
          ),
          const SizedBox(height: 22),
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: InfoBanner(text: 'No enrollments recorded in the last 30 days.')),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: StackedBarChart(bars: _barsFrom(days)),
            ),
        ],
      ),
    );
  }

  List<StackedBarData> _barsFrom(List<EnrollmentDayCountModel> days) {
    final maxCount = days.map((d) => d.count).fold<int>(0, (m, c) => c > m ? c : m);
    return [
      for (final d in days)
        StackedBarData(
          label: _dayLabel(d.date),
          total: maxCount == 0 ? 0 : d.count / maxCount,
          topFraction: 0,
        ),
    ];
  }

  /// `yyyy-MM-dd` → the day number, so 30 daily bars stay legible.
  String _dayLabel(String date) {
    final parts = date.split('-');
    return parts.length == 3 ? int.parse(parts[2]).toString() : date;
  }
}

/// Revenue grouped by currency — the backend returns `revenueByCurrency`
/// (and `revenueByRegion`) specifically because currencies can't be summed
/// into one number without misrepresenting the total. No conversion, no
/// combined figure.
class _RevenueByCurrencyCard extends StatelessWidget {
  const _RevenueByCurrencyCard({required this.overview});

  final DashboardOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final entries = overview.revenueByCurrency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue by currency', style: AppTextStyles.cardTitle),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            const InfoBanner(text: 'No paid orders recorded yet.')
          else
            for (int i = 0; i < entries.length; i++) ...[
              if (i != 0) const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entries[i].key,
                      style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w700, color: AppColors.body)),
                  Text(formatOrderMoney(entries[i].value, entries[i].key),
                      style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

/// Top courses by active enrollment — real `subject`/`grade`/`enrollments`
/// only. The backend's top-courses endpoint has no revenue or drop-off
/// figures per course, so those columns from the old mock layout are
/// dropped rather than filled with invented numbers.
class _TopCoursesCard extends StatelessWidget {
  const _TopCoursesCard({required this.topCourses});

  final List<TopCourseModel> topCourses;

  static const List<double> _flexes = [3, 1.4, 1];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top courses', style: AppTextStyles.cardTitle),
          const SizedBox(height: 18),
          if (topCourses.isEmpty)
            const InfoBanner(text: 'No enrollment data yet.')
          else ...[
            const GridHeaderRow(
              flexes: _flexes,
              labels: ['Course', 'Grade', 'Enrollments'],
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 12),
              background: null,
            ),
            for (int i = 0; i < topCourses.length; i++)
              GridRow(
                flexes: _flexes,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                bottomBorder: i != topCourses.length - 1,
                cells: [
                  EntityCell(
                    monogram: studentMonogram(topCourses[i].subject, null),
                    name: topCourses[i].subject ?? 'Unknown subject',
                  ),
                  Text(topCourses[i].grade ?? '—',
                      style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w600, color: AppColors.grey)),
                  Text('${topCourses[i].enrollments}',
                      style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.body)),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

/// Most recent paid orders — real `GET /admin/analytics/recent-orders`.
/// Same money formatting as Orders (`formatOrderMoney`), no currency
/// conversion.
class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({required this.orders});

  final List<RecentOrderModel> orders;

  static const List<double> _flexes = [2.4, 1, 1];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent orders', style: AppTextStyles.cardTitle),
          const SizedBox(height: 18),
          if (orders.isEmpty)
            const InfoBanner(text: 'No paid orders yet.')
          else ...[
            const GridHeaderRow(
              flexes: _flexes,
              labels: ['Order', 'Amount', 'Date'],
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 12),
              background: null,
            ),
            for (int i = 0; i < orders.length; i++)
              GridRow(
                flexes: _flexes,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                bottomBorder: i != orders.length - 1,
                cells: [
                  EntityCell(
                    monogram: studentMonogram(orders[i].userName ?? orders[i].billingName, orders[i].userEmail),
                    name: orders[i].userName ?? orders[i].billingName ?? orders[i].orderNumber,
                    subtitle: orders[i].orderNumber,
                  ),
                  Text(formatOrderMoney(orders[i].totalCents, orders[i].currency),
                      style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.body)),
                  Text(_shortDate(orders[i].createdAt),
                      style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                ],
              ),
          ],
        ],
      ),
    );
  }

  String _shortDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
