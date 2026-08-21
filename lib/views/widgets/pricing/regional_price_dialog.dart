import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/pricing_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/admin/admin_models.dart';
import '../curriculum/curriculum_form_fields.dart';
import '../curriculum/regional_pricing_section.dart' show kRegionCurrency, regionLabelFor;
import '../curriculum/save_action_bar.dart';

/// Add/Edit one regional price directly against the backend (unlike
/// Curriculum's staged add/edit form — this dialog calls
/// `PricingController.createRegionalPrice`/`updateRegionalPrice`
/// immediately, since the global Pricing page has no separate "Save"
/// step). Region/currency are shown read-only when editing an existing
/// price — the backend's PATCH endpoint only accepts amount/compareAt
/// (confirmed in UpdateProductPriceRequest's doc comment); changing a
/// region is delete-and-recreate, same as Curriculum's reconciliation.
/// Returns true if the price was created/updated.
Future<bool> showRegionalPriceDialog(
  BuildContext context, {
  required String productId,
  AdminProductPriceModel? existing,
  required Set<String> usedRegions,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _RegionalPriceDialog(productId: productId, existing: existing, usedRegions: usedRegions),
  );
  return result ?? false;
}

class _RegionalPriceDialog extends StatefulWidget {
  const _RegionalPriceDialog({required this.productId, this.existing, required this.usedRegions});

  final String productId;
  final AdminProductPriceModel? existing;
  final Set<String> usedRegions;

  @override
  State<_RegionalPriceDialog> createState() => _RegionalPriceDialogState();
}

class _RegionalPriceDialogState extends State<_RegionalPriceDialog> {
  late String? _region = widget.existing?.region;
  late final TextEditingController _amountController =
      TextEditingController(text: widget.existing == null ? '' : '${widget.existing!.amount}');
  late final TextEditingController _compareAtController =
      TextEditingController(text: widget.existing?.compareAt == null ? '' : '${widget.existing!.compareAt}');
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  List<String> get _availableRegions {
    // Editing: only the current region (read-only, shown for context).
    if (_isEditing) return [widget.existing!.region];
    // Adding: every known region not already configured on this product.
    return [for (final r in kRegionCurrency.keys) if (!widget.usedRegions.contains(r)) r];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _compareAtController.dispose();
    super.dispose();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    if (_saving) return;
    final region = _region;
    if (region == null) {
      _showMessage('Select a region.');
      return;
    }
    final currency = kRegionCurrency[region]!;

    final amount = num.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid price.');
      return;
    }

    num? compareAt;
    final compareAtText = _compareAtController.text.trim();
    if (compareAtText.isNotEmpty) {
      compareAt = num.tryParse(compareAtText);
      if (compareAt == null || compareAt <= 0) {
        _showMessage('Compare-at price must be a valid number.');
        return;
      }
    }

    setState(() => _saving = true);
    final controller = context.read<PricingController>();
    final bool ok;
    if (_isEditing) {
      ok = await controller.updateRegionalPrice(
        widget.productId,
        widget.existing!.priceId!,
        UpdateProductPriceRequest(amount: amount, compareAt: compareAt),
      );
    } else {
      ok = await controller.createRegionalPrice(
        widget.productId,
        CreatePriceRequest(region: region, currency: currency, amount: amount, compareAt: compareAt),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      _showMessage(controller.priceError ?? 'Unable to save this price. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = _region == null ? null : kRegionCurrency[_region];
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Regional Price' : 'Add Regional Price'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('${regionLabelFor(_region!)} · $currency',
                    style: AppTextStyles.jakarta(size: 13, weight: FontWeight.w800, color: AppColors.ink)),
              )
            else
              LabeledDropdownField<String>(
                'Region',
                value: _region,
                items: _availableRegions,
                itemLabel: (r) => '${regionLabelFor(r)} (${kRegionCurrency[r]})',
                onChanged: (v) => setState(() => _region = v),
                hint: _availableRegions.isEmpty ? 'Every region is already configured' : 'Select a region',
                required: true,
              ),
            const SizedBox(height: 16),
            LabeledTextField('Price${currency != null ? ' ($currency)' : ''}',
                required: true,
                controller: _amountController,
                hint: 'e.g., 12000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            LabeledTextField('Compare at${currency != null ? ' ($currency)' : ''}',
                controller: _compareAtController,
                hint: 'Optional — shown struck through',
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SaveActionBar(
          onCancel: () => Navigator.of(context).pop(false),
          onSave: _saving ? () {} : _save,
          saveLabel: _saving ? 'Saving…' : 'Save',
        ),
      ],
    );
  }
}
