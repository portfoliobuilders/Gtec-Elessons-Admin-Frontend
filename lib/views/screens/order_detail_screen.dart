import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/orders_controller.dart';
import '../../controllers/students_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/admin/admin_models.dart';
import '../../routes/app_routes.dart';
import '../layouts/admin_shell.dart';
import '../widgets/nav_presets.dart';
import '../widgets/orders/order_money.dart';
import '../widgets/orders/order_status.dart';
import '../widgets/orders/refund_dialog.dart';
import '../widgets/shared_widgets.dart';

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Order Detail — Phase 7A (read-only order/customer/items/payment fields)
/// plus Phase 7B (Refund — the only mutation this screen supports; no
/// status/amount/customer edits).
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _refunding = false;

  void _openStudent(BuildContext context, String userId) {
    context.read<StudentsController>().loadStudent(userId);
    Navigator.of(context).pushNamed(AppRoutes.studentDetail);
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _refund(AdminOrderDetailModel order) async {
    if (_refunding) return;
    final reason = await showRefundDialog(context, order: order);
    if (reason == null || !mounted) return;

    setState(() => _refunding = true);
    final controller = context.read<OrdersController>();
    final ok = await controller.refundOrder(order.id, reason: reason.isEmpty ? null : reason);
    if (!mounted) return;
    setState(() => _refunding = false);
    _showMessage(ok ? 'Order refunded.' : controller.refundError ?? 'Unable to refund this order.');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersController>();
    final order = controller.selectedOrder;

    return AdminShell(
      navItems: NavPresets.admin,
      activeIndex: 5,
      user: NavPresets.gtecAdmin,
      title: 'Order Details',
      actions: [
        OutlineButtonX(label: 'Back', iconPaths: AppIcons.chevronLeft, onTap: () => Navigator.of(context).pop()),
      ],
      body: PageBody(topPadding: 26, child: _buildBody(context, controller, order)),
    );
  }

  Widget _buildBody(BuildContext context, OrdersController controller, AdminOrderDetailModel? order) {
    if (controller.isDetailLoading || (order == null && controller.detailStatus != OrdersLoadStatus.error)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.navy)),
        ),
      );
    }

    if (controller.detailStatus == OrdersLoadStatus.error || order == null) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load this order.',
                  style: AppTextStyles.jakarta(size: 14.5, weight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(controller.detailError ?? 'Please try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.orderNumber,
                        style: AppTextStyles.jakarta(size: 17, weight: FontWeight.w800, color: AppColors.ink)),
                  ),
                  StatusBadge.of(orderStatusBadge(order.status)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 32,
                runSpacing: 16,
                children: [
                  _InfoStat(label: 'Created', value: _formatDate(order.createdAt)),
                  _InfoStat(label: 'Updated', value: _formatDate(order.updatedAt)),
                  _InfoStat(label: 'Region', value: order.region),
                  _InfoStat(label: 'Currency', value: order.currency),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Customer',
                      style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                  if (order.userId != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _openStudent(context, order.userId!),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text('View student →',
                            style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w700, color: AppColors.navy)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 32,
                runSpacing: 16,
                children: [
                  _InfoStat(label: 'Name', value: order.userName ?? order.billingName ?? 'Not set'),
                  _InfoStat(label: 'Email', value: order.userEmail ?? 'Not set'),
                  _InfoStat(label: 'Phone', value: order.userPhone ?? order.billingPhone ?? 'Not set'),
                  if (order.billingCity != null || order.billingState != null)
                    _InfoStat(
                      label: 'Billing location',
                      value: [order.billingCity, order.billingState].whereType<String>().join(', '),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Items',
                  style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 14),
              if (order.items.isEmpty)
                Text('No items on this order.',
                    style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.grey))
              else
                Column(
                  children: [
                    for (int i = 0; i < order.items.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i == order.items.length - 1 ? 0 : 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(order.items[i].titleSnapshot,
                                  style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w700, color: AppColors.ink)),
                            ),
                            Text(formatOrderMoney(order.items[i].priceCents, order.currency),
                                style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w700, color: AppColors.body)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Payment / Transaction',
                      style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
                  const Spacer(),
                  StatusBadge.of(orderStatusBadge(order.status)),
                ],
              ),
              const SizedBox(height: 16),
              _AmountRow(label: 'Subtotal', value: formatOrderMoney(order.subtotalCents, order.currency)),
              if (order.discountCents != 0)
                _AmountRow(label: 'Discount', value: '−${formatOrderMoney(order.discountCents, order.currency)}'),
              _AmountRow(label: 'Tax', value: formatOrderMoney(order.taxCents, order.currency)),
              const SizedBox(height: 10),
              Container(height: 1, color: AppColors.hairline),
              const SizedBox(height: 10),
              _AmountRow(
                label: 'Total',
                value: formatOrderMoney(order.totalCents, order.currency),
                bold: true,
              ),
              if (order.razorpayOrderId != null || order.razorpayPaymentId != null) ...[
                const SizedBox(height: 16),
                Container(height: 1, color: AppColors.hairline),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 32,
                  runSpacing: 16,
                  children: [
                    if (order.razorpayOrderId != null) _InfoStat(label: 'Payment order ref', value: order.razorpayOrderId!),
                    if (order.razorpayPaymentId != null)
                      _InfoStat(label: 'Payment ref', value: order.razorpayPaymentId!),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ActionsCard(order: order, refunding: _refunding, onRefund: () => _refund(order)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.order, required this.refunding, required this.onRefund});

  final AdminOrderDetailModel order;
  final bool refunding;
  final VoidCallback onRefund;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersController>();
    final refundable = controller.canRefund(order);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: AppTextStyles.jakarta(size: 14, weight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 14),
          if (!refundable)
            InfoBanner(
              text: order.status == 'REFUNDED'
                  ? 'This order has already been refunded.'
                  : 'Only PAID orders can be refunded — this order is ${order.status}.',
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: PrimaryButton(
                label: refunding ? 'Refunding…' : 'Refund Order',
                iconPaths: AppIcons.close,
                background: AppColors.red,
                onTap: refunding ? () {} : onRefund,
              ),
            ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.jakarta(
                  size: bold ? 13.5 : 12.5, weight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.grey)),
          Text(value,
              style: AppTextStyles.jakarta(
                  size: bold ? 15 : 13, weight: FontWeight.w800, color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.jakarta(size: 11.5, weight: FontWeight.w700, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.jakarta(size: 13.5, weight: FontWeight.w700, color: AppColors.ink)),
      ],
    );
  }
}
