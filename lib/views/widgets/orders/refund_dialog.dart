import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/admin/admin_models.dart';
import '../curriculum/curriculum_form_fields.dart';
import '../curriculum/save_action_bar.dart';
import 'order_money.dart';

/// Refund confirmation — shows order number, customer, and amount/currency
/// (Section 4), plus an optional reason field (the backend accepts
/// `{reason?}` on `POST /admin/orders/:id/refund`, confirmed live). Returns
/// the reason to send (possibly empty string) or null if cancelled.
Future<String?> showRefundDialog(BuildContext context, {required AdminOrderDetailModel order}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _RefundDialog(order: order),
  );
}

class _RefundDialog extends StatefulWidget {
  const _RefundDialog({required this.order});

  final AdminOrderDetailModel order;

  @override
  State<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<_RefundDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return AlertDialog(
      title: const Text('Refund order?'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This reverses the payment (if any), marks the order REFUNDED, and cancels its enrollments. '
              'This cannot be undone from here.',
              style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w600, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.searchBg, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(label: 'Order', value: order.orderNumber),
                  _Row(label: 'Customer', value: order.userName ?? order.billingName ?? 'Unknown'),
                  _Row(label: 'Amount', value: formatOrderMoney(order.totalCents, order.currency)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LabeledTextField('Reason', controller: _reasonController, hint: 'Optional', maxLines: 2),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SaveActionBar(
          onCancel: () => Navigator.of(context).pop(),
          onSave: () => Navigator.of(context).pop(_reasonController.text.trim()),
          saveLabel: 'Refund Order',
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.jakarta(size: 12, weight: FontWeight.w600, color: AppColors.grey)),
          Text(value, style: AppTextStyles.jakarta(size: 12.5, weight: FontWeight.w800, color: AppColors.ink)),
        ],
      ),
    );
  }
}
