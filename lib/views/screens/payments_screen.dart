import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/orders_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_inputs.dart';
import '../../core/widgets/grid_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/admin/admin_models.dart';
import '../../models/kpi_model.dart';
import '../../routes/app_routes.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/orders/order_money.dart';
import '../widgets/orders/order_status.dart';
import '../widgets/shared_widgets.dart';
import 'students_screen.dart' show studentMonogram;

const List<double> _paymentFlexes = [1.8, 1.6, 1, 1, 0.9];

const List<String?> _statusFilters = [null, 'PENDING', 'PAID', 'FAILED', 'REFUNDED'];

String _statusFilterLabel(String? status) => switch (status) {
      null => 'All',
      'PENDING' => 'Pending',
      'PAID' => 'Paid',
      'FAILED' => 'Failed',
      'REFUNDED' => 'Refunded',
      _ => status,
    };

String _shortDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// 10 · Payments & Leads — real order/payment transactions via
/// `GET /admin/orders` (same [OrdersController] as the old standalone Orders
/// screen; that nav entry was merged into this one, see nav_presets.dart).
/// There is no real "leads" (abandoned-cart/pre-purchase) tracking on the
/// backend, so this shows what actually exists: PENDING/PAID/FAILED/REFUNDED
/// order transactions, in this screen's KPI-row + filter-chip layout.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    final controller = context.read<OrdersController>();
    controller.loadOrders();
    controller.loadStatusCounts();
  }

  void _openOrder(BuildContext context, AdminOrderListItemModel order) {
    context.read<OrdersController>().loadOrder(order.id);
    Navigator.of(context).pushNamed(AppRoutes.orderDetail);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersController>();
    final bool desktop = Responsive.isDesktop(context);

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 5,
      user: NavPresets.gtecAdmin,
      title: 'Payments & Leads',
      actions: [
        if (desktop)
          AppSearchField(hint: 'Search order # or customer…', width: 260, onChanged: controller.setSearch),
        OutlineButtonX(
          label: 'Refresh',
          iconPaths: AppIcons.arrowRight,
          onTap: () {
            controller.refreshOrders();
            controller.loadStatusCounts();
          },
        ),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiGrid(children: [for (final kpi in _kpisFrom(controller)) KpiPlainCard(kpi: kpi)]),
            const SizedBox(height: 22),
            if (!desktop) ...[
              AppSearchField(hint: 'Search order # or customer…', onChanged: controller.setSearch),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in _statusFilters)
                  AppFilterChip(
                    label: _statusFilterLabel(s),
                    active: controller.statusFilter == s,
                    onTap: () => controller.setStatusFilter(s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _PaymentsBody(controller: controller, desktop: desktop, onTap: (o) => _openOrder(context, o)),
            const SizedBox(height: 14),
            Text(
              'Click any row to open the full order — customer, billing details, items and refund actions.',
              style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w500, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  List<KpiModel> _kpisFrom(OrdersController controller) {
    String countOf(String status) => controller.statusCounts[status]?.toString() ?? '—';
    return [
      KpiModel(caption: 'Pending', value: countOf('PENDING')),
      KpiModel(caption: 'Paid', value: countOf('PAID')),
      KpiModel(caption: 'Failed', value: countOf('FAILED'), accent: true),
      KpiModel(caption: 'Refunded', value: countOf('REFUNDED')),
    ];
  }
}

class _PaymentsBody extends StatelessWidget {
  const _PaymentsBody({required this.controller, required this.desktop, required this.onTap});

  final OrdersController controller;
  final bool desktop;
  final ValueChanged<AdminOrderListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case OrdersLoadStatus.initial:
      case OrdersLoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy),
            ),
          ),
        );
      case OrdersLoadStatus.error:
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load payments.',
                    style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(controller.error ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
                const SizedBox(height: 16),
                OutlineButtonX(label: 'Retry', iconPaths: AppIcons.arrowRight, onTap: () => controller.loadOrders()),
              ],
            ),
          ),
        );
      case OrdersLoadStatus.loaded:
        final orders = controller.filteredOrders;
        if (orders.isEmpty) {
          return InfoBanner(
            text: controller.searchQuery.trim().isEmpty
                ? 'No payments yet.'
                : 'No payments match "${controller.searchQuery.trim()}".',
          );
        }
        return _PaymentsTable(orders: orders, desktop: desktop, onTap: onTap);
    }
  }
}

class _PaymentsTable extends StatelessWidget {
  const _PaymentsTable({required this.orders, required this.desktop, required this.onTap});

  final List<AdminOrderListItemModel> orders;
  final bool desktop;
  final ValueChanged<AdminOrderListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final table = Container(
          clipBehavior: Clip.antiAlias,
          width: desktop ? c.maxWidth : 760,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              const GridHeaderRow(
                flexes: _paymentFlexes,
                labels: ['Customer', 'Order', 'Amount', 'Status', 'Date'],
                fontSize: 11,
              ),
              for (int i = 0; i < orders.length; i++)
                GestureDetector(
                  onTap: () => onTap(orders[i]),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GridRow(
                      flexes: _paymentFlexes,
                      bottomBorder: i != orders.length - 1,
                      cells: [
                        EntityCell(
                          monogram: studentMonogram(orders[i].userName ?? orders[i].billingName, orders[i].userEmail),
                          name: orders[i].userName ?? orders[i].billingName ?? '—',
                          subtitle: orders[i].userEmail ?? orders[i].billingPhone,
                        ),
                        Text(orders[i].orderNumber,
                            style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.body)),
                        Text(formatOrderMoney(orders[i].totalCents, orders[i].currency), style: AppTextStyles.cell),
                        StatusBadge.of(orderStatusBadge(orders[i].status)),
                        Text(_shortDate(orders[i].createdAt), style: AppTextStyles.cell),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
        if (desktop) return table;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: table),
        );
      },
    );
  }
}
