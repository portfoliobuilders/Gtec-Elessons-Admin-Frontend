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
import '../../routes/app_routes.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/orders/order_money.dart';
import '../widgets/orders/order_status.dart';
import '../widgets/shared_widgets.dart';
import 'students_screen.dart' show studentMonogram;

const List<double> _orderFlexes = [2, 1, 0.9, 1.1];

/// `PENDING/PAID/FAILED/REFUNDED` — exact backend `OrderStatus` values, plus
/// `null` for "All". A real server-side filter (confirmed live against
/// `GET /admin/orders?status=`).
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

/// Order Management (Phase 7A) — real transactions via `GET /admin/orders`.
/// Read-only: no refund, no status/amount edits (Phase 7B).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersController>().loadOrders();
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
      titleWidget: Text.rich(
        TextSpan(
          text: 'Orders ',
          style: AppTextStyles.pageTitle,
          children: [
            TextSpan(
              text: '· ${controller.total}',
              style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w600, color: AppColors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (desktop)
          AppSearchField(hint: 'Search order # or customer…', width: 260, onChanged: controller.setSearch),
        OutlineButtonX(label: 'Refresh', iconPaths: AppIcons.arrowRight, onTap: controller.refreshOrders),
      ],
      body: PageBody(
        topPadding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 18),
            _OrdersBody(controller: controller, desktop: desktop, onTap: (o) => _openOrder(context, o)),
          ],
        ),
      ),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({required this.controller, required this.desktop, required this.onTap});

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
                Text('Unable to load orders.',
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
                ? 'No orders yet.'
                : 'No orders match "${controller.searchQuery.trim()}".',
          );
        }
        return desktop ? _OrdersTable(orders: orders, onTap: onTap) : _OrdersCards(orders: orders, onTap: onTap);
    }
  }
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({required this.orders, required this.onTap});

  final List<AdminOrderListItemModel> orders;
  final ValueChanged<AdminOrderListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          const GridHeaderRow(flexes: _orderFlexes, labels: ['Order', 'Amount', 'Status', 'Date']),
          for (int i = 0; i < orders.length; i++)
            GestureDetector(
              onTap: () => onTap(orders[i]),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GridRow(
                  flexes: _orderFlexes,
                  bottomBorder: i != orders.length - 1,
                  cells: [
                    EntityCell(
                      monogram: studentMonogram(orders[i].userName ?? orders[i].billingName, orders[i].userEmail),
                      name: orders[i].orderNumber,
                      subtitle: orders[i].userName ?? orders[i].billingName ?? '—',
                    ),
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
  }
}

class _OrdersCards extends StatelessWidget {
  const _OrdersCards({required this.orders, required this.onTap});

  final List<AdminOrderListItemModel> orders;
  final ValueChanged<AdminOrderListItemModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < orders.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == orders.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () => onTap(orders[i]),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: EntityCell(
                              monogram:
                                  studentMonogram(orders[i].userName ?? orders[i].billingName, orders[i].userEmail),
                              name: orders[i].orderNumber,
                              subtitle: orders[i].userName ?? orders[i].billingName ?? '—',
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusBadge.of(orderStatusBadge(orders[i].status)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatOrderMoney(orders[i].totalCents, orders[i].currency),
                              style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w800, color: AppColors.ink)),
                          Text(_shortDate(orders[i].createdAt),
                              style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
