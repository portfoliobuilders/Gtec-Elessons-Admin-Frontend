import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/payments_controller.dart';
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

/// 10 · Payments & Leads — Admin / Super Admin.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  static const List<double> _flexes = [1.7, 1.4, 1, 1.5, 1, 1, 0.9];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 8,
      user: NavPresets.riyaSuperAdmin,
      title: 'Payments & Leads',
      actions: [
        if (desktop)
          const OutlineButtonX(
              label: 'This month', trailingIconPaths: AppIcons.chevronDown),
        const PrimaryButton(
            label: 'Export CSV', iconPaths: AppIcons.download, iconStroke: 1.8),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiGrid(
              children: [
                for (final kpi in controller.kpis) KpiPlainCard(kpi: kpi),
              ],
            ),
            const SizedBox(height: 22),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < controller.filters.length; i++)
                  AppFilterChip(
                    label: controller.filters[i],
                    active: i == controller.activeFilter,
                    onTap: () => controller.setFilter(i),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Ledger table — horizontally scrollable below desktop widths.
            LayoutBuilder(
              builder: (context, c) {
                final table = Container(
                  clipBehavior: Clip.antiAlias,
                  width: desktop ? c.maxWidth : 1100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      const GridHeaderRow(
                        flexes: _flexes,
                        labels: [
                          'Lead / Student',
                          'Contact',
                          'Source',
                          'Course',
                          'Purchase date',
                          'Amount',
                          'Status'
                        ],
                        fontSize: 11,
                      ),
                      for (int i = 0; i < controller.rows.length; i++)
                        _PaymentRow(
                          row: controller.rows[i],
                          isLast: i == controller.rows.length - 1,
                        ),
                    ],
                  ),
                );
                if (desktop) return table;
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: table,
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Click any row to open the full lead profile — contact, source, '
              'activity timeline, invoices and refund actions.',
              style: AppTextStyles.jakarta(
                  size: 11.5, weight: FontWeight.w500, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.row, required this.isLast});

  final PaymentModel row;
  final bool isLast;

  BadgeStatus get _status => switch (row.status) {
        'PAID' => BadgeStatus.paid,
        'LEAD' => BadgeStatus.lead,
        'TRIAL' => BadgeStatus.trial,
        _ => BadgeStatus.failed,
      };

  Color get _amountColor => switch (row.amountColorKey) {
        PaymentAmountColor.ink => AppColors.ink,
        PaymentAmountColor.muted => AppColors.grey,
        PaymentAmountColor.red => AppColors.red,
      };

  @override
  Widget build(BuildContext context) {
    return GridRow(
      flexes: PaymentsScreen._flexes,
      bottomBorder: !isLast,
      cells: [
        Row(
          children: [
            // 34px hatch avatar via EntityCell without subtitle.
            Expanded(
              child: EntityCell(monogram: row.monogram, name: row.name),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.phone,
                style: AppTextStyles.jakarta(
                    size: 12, weight: FontWeight.w600, color: AppColors.body)),
            Text(row.email,
                overflow: TextOverflow.ellipsis, style: AppTextStyles.cellSub),
          ],
        ),
        Text(row.source,
            style: AppTextStyles.jakarta(
                size: 12, weight: FontWeight.w600, color: AppColors.body)),
        Text(
          row.course,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.jakarta(
            size: 12,
            weight: FontWeight.w600,
            color: row.courseMuted ? AppColors.grey : AppColors.body,
          ),
        ),
        Text(
          row.date,
          style: AppTextStyles.jakarta(
            size: 12,
            weight: FontWeight.w600,
            color: row.dateMuted ? AppColors.grey : AppColors.body,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.amount,
                style: AppTextStyles.jakarta(
                    size: 13, weight: FontWeight.w800, color: _amountColor)),
            if (row.method.isNotEmpty)
              Text(row.method,
                  style: AppTextStyles.jakarta(
                      size: 10.5,
                      weight: FontWeight.w600,
                      color: AppColors.grey)),
          ],
        ),
        StatusBadge.of(_status),
      ],
    );
  }
}
